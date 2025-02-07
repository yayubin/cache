
module main_memory_flash
#(
   parameter ALL_ADDR_LEN =24,
  // parameter ADDR_LEN    = 16 ,   //地址总线宽度
   parameter MEMORY_DW   = 256,//64//DW=MW*8//cahce一次从主存读取多少位宽数据
   parameter MEMORY_MW   = 32 ,//8
   parameter OFFSET_LEN  = 2  ,
   parameter DELAY       = 2    //读写延迟时钟
  /// parameter MEMORY_DP  = ( 1<< (ADDR_LEN -OFFSET_LEN ))
)
//-----------------------------------
(
  input wire                    clk              ,
  input wire                    rst_n            ,

  input wire                    memory_cs        ,

  input                         memory_cmd_valid , // Handshake valid
  output                        memory_cmd_ready , // Handshake ready
  input                         memory_cmd_read  ,  // Read or write
  //input wire  [ADDR_LEN-1:0]    memory_cmd_addr, 
  input wire  [ALL_ADDR_LEN-1:0]    memory_cmd_addr, 
  //  input wire  [ADDR_LEN -OFFSET_LEN-1:0]   memory_cmd_addr  ,  


  input  [MEMORY_DW-1:0]       memory_cmd_wdata , 
  input  [MEMORY_MW-1:0]       memory_cmd_wmask , 
  
  output                       memory_rsp_valid, // Response valid 
  input                        memory_rsp_ready, // Response ready
  output   [MEMORY_DW-1:0]     memory_rsp_rdata,

   //----------yyb,输入总线，控制flash--------------------
  input  wire                     perips_flash_icb_cmd_valid,
  output wire                     perips_flash_icb_cmd_ready,
  input  wire [32-1:0]            perips_flash_icb_cmd_addr ,
  input  wire                     perips_flash_icb_cmd_read , 
  input  wire [32-1:0]            perips_flash_icb_cmd_wdata,

  output wire                     perips_flash_icb_rsp_valid,
  input  wire                     perips_flash_icb_rsp_ready,
  output wire  [32-1:0]           perips_flash_icb_rsp_rdata,

   output                       qspi1_flash_irq, 

//---------spi flash引出模块输出引脚,yyb-------------------------------------
  output  io_port_sck,
  input   io_port_dq_0_i,
  output  io_port_dq_0_o,
  output  io_port_dq_0_oe,
  input   io_port_dq_1_i,
  output  io_port_dq_1_o,
  output  io_port_dq_1_oe,
  input   io_port_dq_2_i,
  output  io_port_dq_2_o,
  output  io_port_dq_2_oe,
  input   io_port_dq_3_i,
  output  io_port_dq_3_o,
  output  io_port_dq_3_oe,
  output  io_port_cs_0,
  output  io_tl_i_0_0 
//----------------------------------------------------

);
//=============================================================================
wire              f_icb_cmd_valid;
wire              f_icb_cmd_ready;
wire  [32-1:0]    f_icb_cmd_addr ;
wire              f_icb_cmd_read ;
wire  [32-1:0]    f_icb_cmd_wdata;
wire              f_icb_rsp_valid;
wire              f_icb_rsp_ready;
wire  [32-1:0]    f_icb_rsp_rdata;


reg [2:0]      step;
reg [2:0]      cont;
reg [256-1 :0] read_da;

//reg [ADDR_LEN-1:0]    memory_cmd_addr_d1;
reg [ALL_ADDR_LEN-1:0]    memory_cmd_addr_d1;


assign  memory_cmd_ready =  (step == 0)? 1:0; 


assign memory_rsp_rdata = read_da;

//assign  f_icb_cmd_addr  = {19'h0,memory_cmd_addr} + 32'h20000000 + {18'b0,cont,1'b0};
//assign  f_icb_cmd_addr  = {19'h0,memory_cmd_addr} + 32'h20000000 + {17'b0,cont,2'b0};
 // assign  f_icb_cmd_addr  = {17'h0,memory_cmd_addr,2'b0} + 32'h20000000 + {17'b0,cont,2'b0};
 //assign  f_icb_cmd_addr  = {16'h0,memory_cmd_addr_d1,3'b0} + 32'h20000000 + {17'b0,cont,2'b0};
// assign  f_icb_cmd_addr  = {15'h0,memory_cmd_addr_d1,4'b0} + 32'h20000000 + {17'b0,cont,2'b0};
//assign  f_icb_cmd_addr  = {4'h0,memory_cmd_addr_d1,4'b0} + 32'h20000000 + {27'b0,cont,2'b0};
//assign  f_icb_cmd_addr  = {3'h0,memory_cmd_addr_d1,5'b0} + 32'h20000000 + {27'b0,cont,2'b0};
//assign  f_icb_cmd_addr  = {6'h0,memory_cmd_addr_d1,2'b0} + 32'h20000000 + {27'b0,cont,2'b0};

//assign  f_icb_cmd_addr  = {6'h0,memory_cmd_addr_d1} + 32'h20000000 + {27'b0,cont,2'b0};
  assign  f_icb_cmd_addr  = {8'h0,memory_cmd_addr_d1} + 32'h20000000 + {27'b0,cont,2'b0};

//assign  f_icb_cmd_addr  = 0;


assign  f_icb_cmd_valid = (step == 1)? 1 :0;

assign   f_icb_cmd_read = 1'b1;
assign f_icb_cmd_wdata =32'd0;

assign  f_icb_rsp_ready  =  (step == 2)? 1 :0;

assign memory_rsp_valid =  (step == 3)? 1 :0;


always @(posedge clk)begin
    if(rst_n==0)begin
         step <=0;
        cont <=0;
    end
    else begin
         if(step==0)begin
              if(memory_cmd_valid ==1 && f_icb_cmd_ready==1)begin
                      step <=1;
                      cont <=0;
                      memory_cmd_addr_d1 <= memory_cmd_addr;
                    // memory_cmd_addr_d1 <=  memory_cmd_addr[ADDR_LEN -1:OFFSET_LEN]; 
              end
         end
         if(step==1)begin 
             if(f_icb_cmd_ready ==1)
                step <=2;
         end
         if(step==2)begin
             // if(f_icb_rsp_valid ==1 && f_icb_rsp_ready==1)begin
                if( f_icb_rsp_valid ==1 )begin
                      cont     <=  cont+1;
                      if(cont ==0)
                          read_da[32-1:0]   <=  f_icb_rsp_rdata;
                      if(cont ==1)
                          read_da[64-1:32]  <=  f_icb_rsp_rdata;
                      if(cont ==2)
                          read_da[96-1:64]  <=  f_icb_rsp_rdata;
                      if(cont ==3)
                          read_da[128-1:96] <=  f_icb_rsp_rdata;
                      if(cont ==4)
                          read_da[160-1:128]   <=  f_icb_rsp_rdata;
                      if(cont ==5)
                          read_da[192-1:160]  <=  f_icb_rsp_rdata;
                      if(cont ==6)
                          read_da[224-1:192]  <=  f_icb_rsp_rdata;
                      if(cont ==7)
                          read_da[256-1:224] <=  f_icb_rsp_rdata;    

                      if(cont  >=  (8-1))begin
                            step <=  3;
                      end
                      else begin
                             step <=  1;
                      end
                end
            end
           if(step==3)begin
                if(memory_rsp_ready==1)
                     step <=  0;
           end

         end

    end



//------------------------------------------------------------


sirv_flash_qspi_top u_sirv_qspi0_top(
    .clk           (clk  ),
    .rst_n         (rst_n),

    .i_icb_cmd_valid (perips_flash_icb_cmd_valid),
    .i_icb_cmd_ready (perips_flash_icb_cmd_ready),
    .i_icb_cmd_addr  (perips_flash_icb_cmd_addr ),
    .i_icb_cmd_read  (perips_flash_icb_cmd_read ),
    .i_icb_cmd_wdata (perips_flash_icb_cmd_wdata),
    
    .i_icb_rsp_valid (perips_flash_icb_rsp_valid),
    .i_icb_rsp_ready (perips_flash_icb_rsp_ready),
    .i_icb_rsp_rdata (perips_flash_icb_rsp_rdata), 


    .f_icb_cmd_valid (f_icb_cmd_valid),
    .f_icb_cmd_ready (f_icb_cmd_ready),
    .f_icb_cmd_addr  (f_icb_cmd_addr ),
    .f_icb_cmd_read  (f_icb_cmd_read ),
    .f_icb_cmd_wdata (f_icb_cmd_wdata),

    .f_icb_rsp_valid (f_icb_rsp_valid),
    .f_icb_rsp_ready (f_icb_rsp_ready),
    .f_icb_rsp_rdata (f_icb_rsp_rdata), 


    .io_port_sck     (io_port_sck    ), 
    .io_port_dq_0_i  (io_port_dq_0_i ),
    .io_port_dq_0_o  (io_port_dq_0_o ),
    .io_port_dq_0_oe (io_port_dq_0_oe),
    .io_port_dq_1_i  (io_port_dq_1_i ),
    .io_port_dq_1_o  (io_port_dq_1_o ),
    .io_port_dq_1_oe (io_port_dq_1_oe),
    .io_port_dq_2_i  (io_port_dq_2_i ),
    .io_port_dq_2_o  (io_port_dq_2_o ),
    .io_port_dq_2_oe (io_port_dq_2_oe),
    .io_port_dq_3_i  (io_port_dq_3_i ),
    .io_port_dq_3_o  (io_port_dq_3_o ),
    .io_port_dq_3_oe (io_port_dq_3_oe),
    .io_port_cs_0    (io_port_cs_0   ),
    //.io_tl_i_0_0     (io_tl_i_0_0    ) 
    .io_tl_i_0_0     (qspi1_flash_irq ) 
);






//----------------------------------------------------

`ifdef main_memory_flash_ila_en
ila_1024_1024 main_memory_flash_ila (
    //  ila_1024_1024 cache_momory_ila (
	.clk(clk), // input wire clk

	.probe0(
          {
             cont,
           
             step,

 memory_cmd_valid ,
 memory_cmd_ready ,
 memory_cmd_read  ,
 memory_cmd_addr, 

memory_cmd_wdata ,
memory_cmd_wmask ,
memory_rsp_valid, 
memory_rsp_ready, 
memory_rsp_rdata,



 f_icb_cmd_valid,
 f_icb_cmd_ready,
 f_icb_cmd_addr ,
 f_icb_cmd_read ,
 f_icb_cmd_wdata,
 f_icb_rsp_valid,
 f_icb_rsp_ready,
 f_icb_rsp_rdata,

perips_flash_icb_cmd_valid,
perips_flash_icb_cmd_ready,
perips_flash_icb_cmd_addr ,
perips_flash_icb_cmd_read ,
perips_flash_icb_cmd_wdata,
perips_flash_icb_rsp_valid,
perips_flash_icb_rsp_ready,
perips_flash_icb_rsp_rdata,

qspi1_flash_irq,
memory_cmd_addr_d1

             
          }
  )
);

`endif 

//==============================================================================

endmodule
//===============================================================================
