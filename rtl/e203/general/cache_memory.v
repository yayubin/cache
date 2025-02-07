
//===============================================================================
//功能：对输入的地址进行译码，命中的话输出数据，没命中的话输出cahce对应的块组有没有空或脏的情况并输出最不活跃的组的数据
//自动寻找最不活跃的组读写(LRU)
//读一个周期出结果
//写之前有读过，和上一个周期相同的tag，index，(LRU)才能计算正确//写之前要先读如果没命中输出需要替换的数据，下一周期才写
module cache_memory
#(
    parameter WAY_NUM    =4,
    parameter TAG_DW     =8,//(TAG_LEN+2(dirty,valid))//位，按8的倍数
    parameter TAG_MW     =1,//TAG需要多少个字节存(TAG_LEN+2(dirty,valid))
    parameter LRU_DW     =8,//WAY_NUM=4//LRU_DW=LRU_WAY_DW*WAY_NUM//表示组个数需要多少位*8
    parameter LRU_MW     =1,//LRU_MW=(LRU_DW * WAY_NUM)/8 //存组活跃数据需要多少字节
   // parameter LRU_WAY_DW =LRU_DW / WAY_NUM,  //WAY_NUM = 2^LRU_WAY_DW
   //......................................
    parameter TAG_LEN    = 4,//addr = tag + index + offsset;
    parameter INDEX_LEN  = 10,
    parameter OFFSET_LEN =2,

    parameter CPU_DW     = 64,////块内中的单位数据位宽
    parameter CPU_MW     = 8,

    parameter MEMORY_DW  = 256,//
    parameter MEMORY_MW  = 32,
    parameter CACHE_DP  = (1<<INDEX_LEN)
)
(
  input wire                   clk               ,
  input wire                   rst_n             ,

  input wire                   en,
//------------------------------------------
  input wire                   clear_en,   //配合index信号清除数据。
//..........................................
  input wire [TAG_LEN-1:0]     tag               ,//addr = tag + index + offsset;
  input wire [INDEX_LEN-1:0]   index             ,
  input wire [OFFSET_LEN-1:0]  offsset           ,
//...........................................
  output reg                   cpu_hit           ,
  output reg [CPU_DW-1:0]      cpu_rdata         ,//cpu读取cache命中的数据
  //output wire [CPU_DW-1:0]      cpu_rdata         ,//cpu读取cache命中的数据

  input  wire [CPU_DW-1:0]     cpu_wdata         ,//cpu往cache命中的地方写数据
  input  wire [CPU_MW-1:0]     cpu_wmask_write_en,//写使能
//...........................................
  output reg                   cahce_full        , //在相同的index下 4个组是不是满了
  output reg                   cahce_dirty       ,//最不活跃组是不是脏了
  //input wire  [WAY_NUM-1:0]    way,//表示以下信号对组进行读写操作,配合index信号
//...........................................
  input  wire [MEMORY_DW-1:0]  cahce_wdata       ,//主存往cache写数据//自动找到最佳的组存(最不活跃或空)
  input  wire                  cahce_write_en    ,//写使能

  output reg [MEMORY_DW-1:0]  cahce_rdata,       //主存读取cache数据//自动找到最不活跃的组读//当不命中的时候送出最不活跃的组

  output   [TAG_LEN+INDEX_LEN+OFFSET_LEN-1:0]    cache_addr //最不活跃组的地址
);

parameter LRU_WAY_DW =LRU_DW / WAY_NUM;  //WAY_NUM = 2^LRU_WAY_DW
//--------------------------------------------------------
reg                 cache_we   [WAY_NUM-1:0];
reg [MEMORY_DW-1:0] cache_din  ;
reg [MEMORY_MW-1:0] cache_wem  [WAY_NUM-1:0];
wire [MEMORY_DW-1:0] cache_dout [WAY_NUM-1:0];

reg                 tag_we     [WAY_NUM-1:0];
reg [TAG_DW-1:0]    tag_din    [WAY_NUM-1:0];
reg [TAG_MW-1:0]    tag_wem    [WAY_NUM-1:0];
wire [TAG_DW-1:0]    tag_dout   [WAY_NUM-1:0];

reg                  lru_we  ;
wire [LRU_DW-1:0]    lru_din ;
wire [LRU_MW-1:0]    lru_wem ;
wire [LRU_DW-1:0]    lru_dout;

wire [TAG_LEN-1 :0]read_tag   [WAY_NUM-1:0];
wire               read_dirty [WAY_NUM-1:0];
wire               read_valid [WAY_NUM-1:0];
wire               read_hit   [WAY_NUM-1:0];

wire set_dirty;
wire set_valid;
//--------------------------------------------------------------
reg [TAG_LEN-1:0]     tag_d1               ;
reg [OFFSET_LEN-1:0]  offsset_d1           ;
always @(posedge clk) begin
        if(rst_n==0) begin
           tag_d1     <= 0;
          // index_d1   <= 0;
           offsset_d1 <= 0;
        end
        else begin
             if(en ==1)begin
               tag_d1     <= tag;   
            // index_d1   <= index;
               offsset_d1 <= offsset;
             end
        end
end

//------LRU算法，计算能替换的组--------------------------------------------------------------

wire [LRU_WAY_DW-1:0]lru;

//assign lru = 2'd3;

 assign lru =  (read_hit[0]==1)?  0: //!!!!!!!!!!!!!!!!!!!!!!!
               (read_hit[1]==1)?  1 :
               (read_hit[2]==1)?  2 :
               (read_hit[3]==1)?  3 : 
               (read_valid[0]==0)?  0 :
               (read_valid[1]==0)?  1 :
               (read_valid[2]==0)?  2 :
               (read_valid[3]==0)?  3 :
               lru_dout[LRU_WAY_DW-1:0];    


//.....写信号...............
integer i;
always@(*)begin
    lru_we = 0;
    for(i = 0; i < WAY_NUM; i = i +1)begin
          lru_we  = lru_we | cache_we[i];

    end
end
assign  lru_wem = {LRU_MW{lru_we}};


assign lru_din = (cpu_hit==0)?              {lru,lru_dout[LRU_DW -1:LRU_WAY_DW]} ://最右边为最不活跃组号//!!!!!!!!!!
                (lru == lru_dout[1:0])?     {lru_dout[1:0],lru_dout[7:2]}:
                (lru == lru_dout[3:2])?     {lru_dout[3:2],lru_dout[7:4],lru_dout[1:0]}:
                (lru == lru_dout[5:4])?     {lru_dout[5:4],lru_dout[7:6],lru_dout[3:0]}:
                (lru == lru_dout[7:6])?     {lru_dout[7:0]}:0;


//-------写cache和TAG-------------------------------------------------

integer i2;
always@(*)begin
      if(cahce_write_en==1)begin
          cache_din = cahce_wdata;
      end
      else begin
      for(i2 = 0; i2 < 2**OFFSET_LEN; i2 = i2 +1)begin
     // for(i = 0; i < 4; i = i +1)begin
           if( i2 == offsset)
              cache_din[i2*CPU_DW +:CPU_DW]  = cpu_wdata;
          else 
             cache_din[i2*CPU_DW +:CPU_DW]  = {CPU_DW{1'd0}};
      end
      end
end


//assign set_dirty =1'd0;
assign  set_dirty = (cahce_write_en==1)? 1'd0 : 1'd1;
assign  set_valid =1'd1;


integer i3;
always@(*)begin
      for(i3 = 0; i3 < WAY_NUM; i3 = i3 +1)begin
           if( i3 == lru)begin
               if(cahce_write_en==1)begin
                       cache_wem[i3] ={MEMORY_MW{1'd1}};
                       cache_we[i3] = 1'd1;

               end
               else begin
                    cache_wem[i3] =0;
                    cache_wem[i3][offsset*CPU_MW +:CPU_MW] = cpu_wmask_write_en;
                    cache_we[i3] = |cache_wem[i3];
                    
                end
                //tag_din[i] = {2'd0,set_valid,set_dirty,tag};//!!!!!!!!!!!!!!!
                tag_din[i3] = {{(TAG_DW-TAG_LEN-2){1'b0}},set_valid,set_dirty,tag};//
               //tag_din[i] = {7'd0,set_valid,set_dirty,tag};//
               //tag_din[i] = {7'd0,1'd1,set_dirty,tag};//
               // tag_wem[i] = |cache_wem[i];
               tag_wem[i3] = {TAG_MW{|cache_wem[i3]}};
                tag_we [i3] = |cache_wem[i3];
               
           end
          else begin
           
                cache_wem[i3] = {MEMORY_MW{1'd0}};
                cache_we[i3] = 1'd0;
                tag_din[i3] =  {TAG_DW{1'd0}};
                tag_wem[i3] =  {TAG_MW{1'd0}};
                tag_we [i3] =  1'd0;
               
           end
      end
end


//---------读cache和TAG-----------------------------------------------

genvar n1;
generate

for(n1 = 0; n1 < WAY_NUM; n1 = n1 +1)begin

    assign read_tag[n1]      =   tag_dout[n1][TAG_LEN-1:0];
    assign read_dirty[n1]    =   tag_dout[n1][TAG_LEN];
    assign read_valid[n1]    =   tag_dout[n1][TAG_LEN+1];

    assign read_hit[n1] = ((tag_d1 == read_tag[n1]) && read_valid[n1]);//dirty,valid,tag
end
endgenerate



integer i4;
always@(*)begin
      cpu_hit     = 1'd0;
      cahce_full  = 1'd1;
      cpu_rdata  = 0;
      cahce_dirty = 0;
      cahce_rdata[i4] =0;
      for(i4 = 0; i4 < WAY_NUM; i4 = i4 +1)begin
           if( i4 == lru)begin
               cpu_rdata   = cache_dout[i4][offsset_d1*CPU_DW +:CPU_DW];
               cahce_dirty = read_dirty[i4];
               cahce_rdata =cache_dout[i4];
           end
           cpu_hit    = cpu_hit |read_hit[i4]; //assign cpu_hit = read_hit[0] | read_hit[1] | read_hit[2] | read_hit[3];//!!!!!!!!!!!!!!!!!!!!!
           cahce_full = read_valid[i4] & cahce_full;
      end
end



//assign cache_addr = {tag_d1,index,offsset_d1};
assign cache_addr = {read_tag[lru],index,offsset_d1};//offsset_d1没有用
//tag    
//index  
//offsset
//--------------------------------------------------------
genvar n;
generate


for(n = 0; n < WAY_NUM; n = n +1)begin:cache
//...........................
`ifdef FPGA_SOURCE
    sirv_gnrl_ram 
    #(
      //.DP           (1<<INDEX_LEN), //数据深度// DP=1<<AW
      .DP            (CACHE_DP), //数据深度// DP=1<<AW
      .DW           (MEMORY_DW)   , //DW=MW*8
      .FORCE_X2ZERO (1'b0)        ,//FPGA时,FORCE_X2ZERO=0。芯片时,FORCE_X2ZERO=1//FORCE_X2ZERO=1时表示1'bx时转为0
      .MW           (MEMORY_MW)   , //数据有几个字节（8位)。 
      .AW           (INDEX_LEN)     //地址宽度
      )
      cache_ram
      (
      .rst_n(rst_n),
      .clk  (clk),
      //.cs   (cache_cs[n]),//1表示使能该芯片
    // .cs   (1'b1),//1表示使能该芯片
      .cs   (en),
      .we   (cache_we[n]),//0为读，1为写
      .addr (index),
    // .din  (cache_din[n]),
      .din  (cache_din),
      .wem  (cache_wem[n]),//对应位1表示操作的字节有效
      .dout (cache_dout[n])
    );
`else 
    sirv_gnrl_ram 
    #(
     // .DP           (1<<INDEX_LEN), //数据深度// DP=1<<AW
      .DP            (CACHE_DP), //数据深度// DP=1<<AW
      .DW           (MEMORY_DW)   , //DW=MW*8
      .FORCE_X2ZERO (1'b1)        ,//FPGA时,FORCE_X2ZERO=0。芯片时,FORCE_X2ZERO=1//FORCE_X2ZERO=1时表示1'bx时转为0
      .MW           (MEMORY_MW)   , //数据有几个字节（8位)。 
      .AW           (INDEX_LEN)     //地址宽度
      )
      cache_ram
      (
      .rst_n(rst_n),
      .clk  (clk),
      //.cs   (cache_cs[n]),//1表示使能该芯片
    // .cs   (1'b1),//1表示使能该芯片
      .cs   (en),
      .we   (cache_we[n]),//0为读，1为写
      .addr (index),
    // .din  (cache_din[n]),
      .din  (cache_din),
      .wem  (cache_wem[n]),//对应位1表示操作的字节有效
      .dout (cache_dout[n])
    );

`endif
//............................
`ifdef FPGA_SOURCE
    sirv_gnrl_ram 
    #(
      //.DP           (1<<INDEX_LEN), //数据深度// DP=1<<AW
      .DP            (CACHE_DP), //数据深度// DP=1<<AW
      .DW           (TAG_DW)   , //DW=MW*8
      .FORCE_X2ZERO (1'b0)        ,//FPGA时,FORCE_X2ZERO=0。芯片时,FORCE_X2ZERO=1//FORCE_X2ZERO=1时表示1'bx时转为0
      .MW           (TAG_MW)   , //数据有几个字节（8位)。 
      .AW           (INDEX_LEN)     //地址宽度
      )
    tag_ram
      (
      .rst_n(rst_n),
      .clk  (clk),
    // .cs   (tag_cs[n]),
    // .cs   (1'b1),//1表示使能该芯片
      .cs   (en | clear_en),
      .we   (tag_we[n]  | clear_en),
      .addr (index),
      .din  (tag_din[n] & {TAG_DW{(!clear_en)}}),
      .wem  (tag_wem[n] | {TAG_MW{clear_en}}),//对应位1表示操作的字节有效
      //.wem  (1'd1),//对应位1表示操作的字节有效
      .dout (tag_dout[n])
    );
`else
 sirv_gnrl_ram 
    #(
     // .DP           (1<<INDEX_LEN), //数据深度// DP=1<<AW
     .DP            (CACHE_DP), //数据深度// DP=1<<AW
      .DW           (TAG_DW)   , //DW=MW*8
      .FORCE_X2ZERO (1'b1)        ,//FPGA时,FORCE_X2ZERO=0。芯片时,FORCE_X2ZERO=1//FORCE_X2ZERO=1时表示1'bx时转为0
      .MW           (TAG_MW)   , //数据有几个字节（8位)。 
      .AW           (INDEX_LEN)     //地址宽度
      )
    tag_ram
      (
      .rst_n(rst_n),
      .clk  (clk),
    // .cs   (tag_cs[n]),
    // .cs   (1'b1),//1表示使能该芯片
      .cs   (en | clear_en),
      .we   (tag_we[n]  | clear_en),
      .addr (index),
      .din  (tag_din[n] & {TAG_DW{(!clear_en)}}),
      .wem  (tag_wem[n] | {TAG_MW{clear_en}}),//对应位1表示操作的字节有效
      //.wem  (1'd1),//对应位1表示操作的字节有效
      .dout (tag_dout[n])
    );

`endif
//...........................
end
endgenerate
//............................
`ifdef FPGA_SOURCE
    sirv_gnrl_ram 
    #(
     // .DP           (1<<INDEX_LEN), //数据深度// DP=1<<AW
      .DP            (CACHE_DP), //数据深度// DP=1<<AW
      .DW           (LRU_DW)   , //DW=MW*8
      .FORCE_X2ZERO (1'b0)        ,//FPGA时,FORCE_X2ZERO=0。芯片时,FORCE_X2ZERO=1//FORCE_X2ZERO=1时表示1'bx时转为0
      .MW           (LRU_MW)   , //数据有几个字节（8位)。 
      .AW           (INDEX_LEN)     //地址宽度
      )
    lru_ram
      (
      .rst_n(rst_n),
      .clk  (clk),
      .cs   (en | clear_en),
      .we   (lru_we | clear_en),
      .addr (index),
      .din  (lru_din & {LRU_DW{(!clear_en)}}),
      .wem  (lru_wem | {LRU_MW{clear_en}}),//对应位1表示操作的字节有效
      .dout (lru_dout)
    );
`else
    sirv_gnrl_ram 
    #(
     // .DP           (1<<INDEX_LEN), //数据深度// DP=1<<AW
       .DP            (CACHE_DP), //数据深度// DP=1<<AW
      .DW           (LRU_DW)   , //DW=MW*8
      .FORCE_X2ZERO (1'b1)        ,//FPGA时,FORCE_X2ZERO=0。芯片时,FORCE_X2ZERO=1//FORCE_X2ZERO=1时表示1'bx时转为0
      .MW           (LRU_MW)   , //数据有几个字节（8位)。 
      .AW           (INDEX_LEN)     //地址宽度
      )
    lru_ram
      (
      .rst_n(rst_n),
      .clk  (clk),
      .cs   (en | clear_en),
      .we   (lru_we | clear_en),
      .addr (index),
      .din  (lru_din & {LRU_DW{(!clear_en)}}),
      .wem  (lru_wem | {LRU_MW{clear_en}}),//对应位1表示操作的字节有效
      .dout (lru_dout)
    );

`endif 




endmodule
//===============================================================================
