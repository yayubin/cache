`include "e203_defines.v"

    `define cache_en //使能后下面才有效
  //...................................



//==========================================================================
  //`define INDEX_LEN 10 //.设置cahce大小，总容为 2^INDEX_LEN * MEMORY_DW * WAY_NUM(bit)
  // `define INDEX_LEN 3 //.设置cahce大小，总容为 2^INDEX_LEN * MEMORY_DW * WAY_NUM(bit)//1k byte
  //`define INDEX_LEN 4 //.设置cahce大小，总容为 2^INDEX_LEN * MEMORY_DW * WAY_NUM(bit)//2k byte
 //`define INDEX_LEN 5 //.设置cahce大小，总容为 2^INDEX_LEN * MEMORY_DW * WAY_NUM(bit)//4k byte
  `define INDEX_LEN 6 //.设置cahce大小，总容为 2^INDEX_LEN * MEMORY_DW * WAY_NUM(bit)//8k byte
   //`define INDEX_LEN 7 //.设置cahce大小，总容为 2^INDEX_LEN * MEMORY_DW * WAY_NUM(bit)//16k byte


  `define ALL_ADDR_LEN  24
   
	`define CPU_DW  32//64 //DW=MW*8 //cpu一次从cache读取多少位宽数据
  `define CPU_MW  `CPU_DW/8//
	`define CPU_BMW  2//2: 2^X=CPU_MW//CPU_DW的地址位宽

  `define MEMORY_DW  256//64//DW=MW*8//cahce一次从主存读取多少位宽数据
  `define MEMORY_MW  `MEMORY_DW/8//



	`define OFFSET_LEN   3// 2^OFFSET_LEN = MEMORY_DW / CPU_DW;//块内有多少个单位数据，cpu一次只读一个单位数据，cache从主存一次读一个单位块。

      //.......................
  //`define INDEX_LEN  2//块，2^INDEX_LEN个块


   //.......设置总线位宽................


   
    `define ADDR_LEN   (`ALL_ADDR_LEN -`CPU_BMW)   //地址总线宽度

    `define TAG_LEN      (`ADDR_LEN - `INDEX_LEN - `OFFSET_LEN)
    `define TAG_DW     24//(TAG_LEN+2(dirty,valid))//位，按8的倍数
    `define TAG_MW     (`TAG_DW/8)//TAG需要多少个字节存(TAG_LEN+2(dirty,valid))
	
	



   //......设置................................
    `define WAY_NUM   4

    `define LRU_DW     8//WAY_NUM=4//LRU_DW=LRU_WAY_DW*WAY_NUM//表示组个数需要多少位*8
    `define LRU_MW     1//LRU_MW=(LRU_DW * WAY_NUM)/8 //存组活跃数据需要多少字节






//========================================================================================
	`define MEMORY_DELAY 1

  `ifdef FPGA_SOURCE


       `define CACHE_DP    (1<<`INDEX_LEN)
       `define MEMORY_DP   ( 1<< (`ADDR_LEN -`OFFSET_LEN ))
       
   `else    
       `define CACHE_DP      5 
       `define MEMORY_DP     5

   `endif


