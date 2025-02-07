
//===============================================================================
//ADDR_LEN = TAG_LEN + INDEX_LEN +OFFSET_LEN;
//块内有多少个单位数据，cpu一次只读一个单位数据（OFFSET），cache从主存一次读一个单位块（INDEX）。
//OFFSET_LEN 表示多少个单位数据



module cache
#(
  //.......设置cahce大小，总容为 2^INDEX_LEN * MEMORY_DW * WAY_NUM(bit) ...................
      parameter INDEX_LEN = 10,//块，2^INDEX_LEN个块//
  //.........................
   parameter ALL_ADDR_LEN =24,//总地址宽度，1地址表示一个字节

    parameter CPU_DW = 32,//64 //DW=MW*8 //cpu一次从cache读取多少位宽数据
    parameter CPU_MW = CPU_DW/8,//8
    parameter CPU_BMW = 2,//2: 2^X=CPU_MW//CPU_DW的地址位宽

    parameter MEMORY_DW = 256,//64//DW=MW*8//cahce一次从主存读取多少位宽数据
    parameter MEMORY_MW = MEMORY_DW/8,//8

    parameter OFFSET_LEN  = 3,// 2^OFFSET_LEN = MEMORY_DW / CPU_DW;//块内有多少个单位数据，cpu一次只读一个单位数据，cache从主存一次读一个单位块。

    //.................................................................................
    
    parameter ADDR_LEN  = ALL_ADDR_LEN - CPU_BMW,   //地址总线宽度//一个地址有CPU_DW位数据
   
    parameter TAG_LEN     = ADDR_LEN - INDEX_LEN - OFFSET_LEN,
    parameter TAG_DW     =8,//(TAG_LEN+2(dirty,valid))//位，按8的倍数
    parameter TAG_MW     =1,//TAG需要多少个字节存(TAG_LEN+2(dirty,valid))
    //.................................................................................
     parameter WAY_NUM    =4,
    parameter LRU_DW     =8,//WAY_NUM=4//LRU_DW=LRU_WAY_DW*WAY_NUM//表示组个数需要多少位*8
    parameter LRU_MW     =1//LRU_MW=(LRU_DW * WAY_NUM)/8 //存组活跃数据需要多少字节

    )

(
  input wire  clk,
  input wire  rst_n,

  input                  cache_en,
//................................
  input                      cpu_cmd_valid, // Handshake valid
  output wire                cpu_cmd_ready, // Handshake ready
  input                      cpu_cmd_read,  // Read or write//1为读
  input  [ALL_ADDR_LEN-1:0]  cpu_cmd_addr, //一个地址为一个字节
  input  [CPU_DW-1:0]        cpu_cmd_wdata, 
  input  [CPU_MW-1:0]        cpu_cmd_wmask, 
  
  output                 cpu_rsp_valid, // Response valid 
  input                  cpu_rsp_ready, // Response ready
  output [CPU_DW-1:0]    cpu_rsp_rdata, 
//..................................
  output                  memory_cmd_valid, // 
  input                   memory_cmd_ready, // 
  output                  memory_cmd_read,  //// Read or write//1为读 
  output  [ALL_ADDR_LEN-1:0]  memory_cmd_addr,//一个地址为一个字节

  output  [MEMORY_DW-1:0] memory_cmd_wdata, //低地址在低位
  output  [MEMORY_MW-1:0] memory_cmd_wmask, 
  
  input                   memory_rsp_valid, // Response valid 
  output  wire            memory_rsp_ready, // Response ready
  input   [MEMORY_DW-1:0] memory_rsp_rdata// //低地址在低位
//..................................  
);

  parameter CACHE_DP  = (1<<INDEX_LEN);
 

  wire    [ADDR_LEN-1:0]  cpu_cmd_addr2;
  wire    [ADDR_LEN-1:0]  memory_cmd_addr2;
  assign  cpu_cmd_addr2 =cpu_cmd_addr[ADDR_LEN-1 : CPU_BMW];//实际使用的地址位宽


    assign  memory_cmd_addr=   { (memory_cmd_addr2 & ( { {(ADDR_LEN-OFFSET_LEN){1'b1}} ,{OFFSET_LEN{1'b0}} })),{CPU_BMW{1'd0}}};//实际使用的地址位宽


//------------------------------------------------------------------------------------
  wire  [TAG_LEN-1:0]     tag               ;//addr = tag + index + offsset;
  wire  [INDEX_LEN-1:0]   index             ;
  wire  [OFFSET_LEN-1:0]  offsset           ;
  wire                    cpu_hit           ;
  wire  [CPU_DW-1:0]      cpu_rdata         ;//cpu读取cache命中的数据
  wire   [CPU_DW-1:0]      cpu_wdata         ;//cpu往cache命中的地方写数据
  wire  [CPU_MW-1:0]      cpu_wmask_write_en;//写使能
  wire                    cahce_full        ; //在相同的index下 4个组是不是满了
  wire                    cahce_dirty       ;//最不活跃组是不是脏了
  wire [MEMORY_DW-1:0]    cahce_wdata       ;//主存往cache写数据//自动找到最佳的组存(最不活跃或空)
  wire                     cahce_write_en    ;//写使能
  wire [MEMORY_DW-1:0]    cahce_rdata       ;//主存读取cache数据//自动找到最不活跃的组读//当不命中的时候送出最不活跃的组

  wire   [TAG_LEN+INDEX_LEN+OFFSET_LEN-1:0]  cache_addr;
  wire   clear_en;

  reg [7:0]step;
  wire      en;
  reg  star;//启动标致，忽略不命中信号


reg read_flag;//有数据标致
reg flag2;//上

reg [ADDR_LEN-1:0]  cpu_cmd_addr2_d1; 
reg [CPU_DW-1:0]    cpu_cmd_wdata_d1;
reg [CPU_MW-1:0]    cpu_cmd_wmask_d1;
reg                 cpu_cmd_read_d1;

reg [INDEX_LEN-1:0] cont;
//.............输入信号.................

assign cpu_cmd_ready =  (
                        step==0 && 
                        (read_flag==0 || cpu_rsp_ready==1) &&
                        (cpu_hit==1 || star==0)
                        )? 1 :0;


assign {tag,index,offsset} =(step==8'hff)? {{TAG_LEN{1'b0}},cont,{OFFSET_LEN{1'b0}}} :
                            (step==0)?     cpu_cmd_addr2 : cpu_cmd_addr2_d1;


 assign cpu_wmask_write_en  = ((step==1) &&(cpu_hit==1 ) || (step==6))?    cpu_cmd_wmask_d1:0; //

 assign cpu_wdata = (step==0)? cpu_cmd_wdata : cpu_cmd_wdata_d1;

//...................................
assign cahce_write_en= (step==6 || step==7)? 1:0;

assign cahce_wdata = memory_rsp_rdata;

assign clear_en = (step==8'hff)? 1:0;
//...................................


always @(posedge clk) begin
        if(rst_n==0) begin
            step <=8'hff;//开机清cache数据
            cont  <=1;
           
           cpu_cmd_read_d1 <=0;
           read_flag <=0;
           star     <=0;
           //memory_rsp_ready <=0;
           flag2 <=0;
         
        end
        else begin
         
             if(cpu_cmd_valid==1 && cpu_cmd_ready==1)
                   read_flag <= 1;           //读写命中都要应答
             else begin
                   if(cpu_rsp_valid==1 && cpu_rsp_ready==1)
                         read_flag <=0;
             end


           if(step==8'hff)begin 
                 cont <= cont+1;
                 if(cont ==0)begin///开机清cache数据计数
                     step <=0;
                 end
           end

          
             if(step==0)begin//cpu流水线读cache
                    // star     <=1;
                      flag2 <=0;
                     if(cpu_cmd_valid==1 && cpu_cmd_ready==1 )begin
                          flag2    <=1;
                          star     <=1;
                          cpu_cmd_read_d1 <=cpu_cmd_read;
                          cpu_cmd_addr2_d1  <= cpu_cmd_addr2 ;
                          cpu_cmd_wdata_d1 <= cpu_cmd_wdata;
                          cpu_cmd_wmask_d1 <= cpu_cmd_wmask;
                        
                          if(cpu_cmd_read==0)begin//写
                                   step <=1;
                                   flag2 <=0;
                          end
                     end 
                      if(flag2==1)begin//上一周期有数据
                              if(cpu_hit==0)begin//读没命中
                                    if(cahce_dirty==1)
                                      step <=2;
                                    else
                                      step <=4;   
                              end
                          //  end  
                      end
                  
                
           end


           if(step==1)begin//cpu写cache
              // if(cpu_hit==0 && cahce_full==1)begin //写没命中//test,测试开机写时不满时不往主存读数据
                if(cpu_hit==0)begin 
                    if(cahce_dirty==1)
                         step <=2; 
                    else
                         step <=4;              
                end
                else begin
                    step <=0;       
                end
                
           end

           if(step==2)begin//写主存
                step <=3;     
           end
           if(step==3)begin
               if(memory_cmd_ready ==1)begin//等写主存完成
                   step <=4; 
               end
          end

           if(step==4)begin//读主存
                step <=5; 
           end
           
            if(step==5)begin//等读主存完成
              if(memory_rsp_valid==1)begin
                  if(cpu_cmd_read_d1==1)begin
                      step <=7; 
                     // flag2 <=1;
                      star     <=0;//忽略不命中信号
                  end
                  else
                      step <=6; 
              end
           end
           if(step==6)begin//写cahce整块、CPU写数据到cache //写没命中
                    step <=1; 
           end
           if(step==7)begin//写cahce整块、数据发给CPU //读没命中
                 // if(cpu_cmd_ready==1) 
                   if(cpu_rsp_ready ==1)
                       step <=0; 
           end
          
        end
end
assign  memory_rsp_ready = (step==4 ||step==5)? 1:0;

//.....主内存接口信号.......................................
assign memory_cmd_valid = (step==2 || step==4)? 1:0;
assign memory_cmd_read  = (step==2)? 0:1;

assign memory_cmd_addr2  = (step==2)?  cache_addr:
                          (step==4)?  cpu_cmd_addr2_d1:
                                      0;

assign memory_cmd_wdata = cahce_rdata;
assign memory_cmd_wmask = {MEMORY_MW{1'd1}};



//.......输出信号.............................
wire [CPU_DW-1:0] memory_rsp_rdata_w [MEMORY_DW/CPU_DW-1:0];
genvar n1;
generate

for(n1 = 0; n1 < MEMORY_DW/CPU_DW; n1 = n1 +1)begin
     assign memory_rsp_rdata_w[n1] =  memory_rsp_rdata[(n1+1)*CPU_DW-1 : n1*CPU_DW ];
end

endgenerate

 assign cpu_rsp_valid =((step==0 && cpu_hit==1)||(step==1 && cpu_hit==1) || step==7 )? read_flag:0;//读写命中都要应答
 
 assign cpu_rsp_rdata =  (step==7)? memory_rsp_rdata_w[cpu_cmd_addr2_d1[OFFSET_LEN-1:0]]  :cpu_rdata;

//------------------------------------------------------------------------------------
assign en =(((cpu_cmd_ready==1) && (cpu_cmd_valid==1)) || (step==1) || (step==6) || (step==7));
//assign en =(cpu_cmd_ready & cpu_cmd_valid);
cache_memory
#(
    .WAY_NUM (WAY_NUM),
    .TAG_DW  (TAG_DW),//(TAG_LEN+2(dirty,valid))//位，按8的倍数
    .TAG_MW  (TAG_MW),//TAG需要多少个字节存(TAG_LEN+2(dirty,valid))
    .LRU_DW  (LRU_DW),//WAY_NUM=4//LRU_DW=LRU_WAY_DW*WAY_NUM//表示组个数需要多少位*8
    .LRU_MW  (LRU_MW),//LRU_MW=(LRU_DW * WAY_NUM)/8 //存组活跃数据需要多少字节
   //......................................
    .TAG_LEN    (TAG_LEN),//addr = tag + index + offsset;
    .INDEX_LEN  (INDEX_LEN),
    .OFFSET_LEN (OFFSET_LEN),

    .CPU_DW     (CPU_DW),////块内中的单位数据位宽
    .CPU_MW     (CPU_MW),

    .MEMORY_DW  (MEMORY_DW),//
    .MEMORY_MW  (MEMORY_MW)

 )


 u0_cache_memory
(
  .clk               (clk),
  .rst_n             (rst_n),
  .en                (en),
//.............................................
  .clear_en          (clear_en),
//..........................................
  .tag               (tag    ),//addr = tag + index + offsset;
  .index             (index  ),
 //  .index             (index & ( { {(INDEX_LEN-3){1'b1}} ,3'b0 })),
  .offsset           (offsset),
//...........................................
  .cpu_hit           (cpu_hit  ),
  .cpu_rdata         (cpu_rdata),//cpu读取cache命中的数据

  .cpu_wdata         (cpu_wdata         ),//cpu往cache命中的地方写数据
  .cpu_wmask_write_en(cpu_wmask_write_en),//写使能
//...........................................
  .cahce_full        (cahce_full ), //在相同的index下 4个组是不是满了
  .cahce_dirty       (cahce_dirty),//最不活跃组是不是脏了
//...........................................
  .cahce_wdata       (cahce_wdata   ),//主存往cache写数据//自动找到最佳的组存(最不活跃或空)
  .cahce_write_en    (cahce_write_en),//写使能

  .cahce_rdata       (cahce_rdata),//主存读取cache数据//自动找到最不活跃的组读//当不命中的时候送出最不活跃的组
  .cache_addr        (cache_addr)//最不活跃组的地址
); 

//------------------------------------------------------------------------------------


endmodule
//===============================================================================

