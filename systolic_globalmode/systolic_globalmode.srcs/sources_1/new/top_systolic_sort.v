`timescale 1ns / 1ps


module top_systolic_sort  #(parameter   DATA_WIDTH = 16,//total data input
                                         DATA_NUM = 8 )//width of the data)

    (
    input clk,
    input rst,

    input [DATA_WIDTH-1:0] right_in,  //data right input, one input for each clock cycle
    input tag_right_in,  //tag of the right group
    output [DATA_WIDTH-1:0] left_out, //data left output, one output for each clock cycle
    output tag_right_out,  //高电平表示有数据输出,即此时left_out数据有效

    input [DATA_WIDTH-1:0] DATAleft_in,  //data left input, one input for each clock cycle
    input tag_left_in,  //tag of the left group
    output [DATA_WIDTH-1:0] DATAright_out, //data right output, one output for each clock cycle
    output tag_left_out  //高电平表示有数据输出,即此时right_out数据有效
    );
    
    localparam SU_NUM = DATA_NUM  / 2 ;
    wire [DATA_WIDTH-1:0] wINCon[SU_NUM-1:0];
    wire [DATA_WIDTH-1:0] wOUTCon[SU_NUM-1:0];
    
    
    
    reg[1:0] fsm_state ;
    reg[$clog2(DATA_NUM+1)-1 : 0] cnt;
   
    
    systolic_ip#(.DATA_NUM(64), .DATA_WIDTH(16)) ins_sort(
        clk, rst, fsm_state ,right_in, data_in_rEN, left_out, /*data_out_lEN,*/ left_in, data_in_lEN, right_out/*, data_out_rEN*/
    );
    
    generate
    genvar loop_SU;
        for(loop_SU=0;loop_SU<SU_NUM;loop_SU=loop_SU+1) begin: SU
            if(loop_SU == 0) begin
                systolic_ip #(.DATA_NUM(DATA_NUM), .DATA_WIDTH(DATA_WIDTH))
                                     SU ( 
                                     .clk(clk),.rst(rst), 
                                     .fsm_state(fsm_state),
                                     .right_in(DATAright_in),
                                     .tag_right_in(tag_right_in), 
                                     .left_out(wINCon[loop_SU+1]),
                                     .tag_right_out(tag_right_out),
                                     .left_in(wOUTCon[loop_SU+1]),
                                     .tag_left_in(tag_left_in),
                                     .right_out(DATAright_out)
                                    
                                       );
            end
            else if (loop_SU == SU_NUM -1) begin
                systolic_ip #(.DATA_NUM(DATA_NUM), .DATA_WIDTH(DATA_WIDTH))
                                     SU ( 
                                     .clk(clk),.rst(rst),
                                     .fsm_state(fsm_state),
                                     .right_in(wINCon[loop_SU]),
                                     .tag_right_in(tag_right_in), 
                                     .left_out(DATAleft_out),
                                    .tag_right_out(tag_right_out),
                                     .left_in(DATAleft_in),
                                     .tag_left_in(tag_left_in),
                                     .right_out(wOUTCon[loop_SU])
                                    
                                       );
            end
            else begin
                systolic_ip #(.DATA_NUM(DATA_NUM), .DATA_WIDTH(DATA_WIDTH))
                                     SU ( 
                                     .clk(clk),.rst(rst),
                                     .fsm_state(fsm_state),
                                     .right_in(wINCon[loop_SU]),
                                     .tag_right_in(tag_right_in), 
                                     .left_out(wINCon[loop_SU+1]),
                                    .tag_right_out(tag_right_out),
                                     .left_in(wOUTCon[loop_SU+1]),
                                     .tag_left_in(tag_left_in),
                                     .right_out(wOUTCon[loop_SU])
                                    
                                       );
            end
        end
    endgenerate
    
    
    always @(posedge clk) begin
        if(rst)
            begin 
            fsm_state <=1'b1;
            cnt<=0;
            end
            else begin
                if(cnt==DATA_NUM-1) begin
                fsm_state <= !fsm_state;
                cnt<=0;
                end else
                    begin 
                    cnt<=cnt +1 ;
                    end
                end
    
    end
  
       
endmodule
