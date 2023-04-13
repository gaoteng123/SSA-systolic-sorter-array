`timescale 1ns / 1ps


module tb(
    );
    reg clk;
    
    always  #2 clk = ~clk;
    
    reg rst;
    
    reg[15:0] DATAright_in;  //待排序数据，一次输入一个
    reg data_in_renable;  //高电平表示有数据输入
    wire [15:0] DATAleft_out;
    wire data_out_lenable;  //高电平表示有数据输出

    reg [15:0] DATAleft_in;
    reg data_in_lenable;  //高电平表示有数据输入
    wire [15:0] DATAright_out;
    wire data_out_renable;  //高电平表示有数据输出
    
    top_systolic_sort t(clk, rst, DATAright_in, data_in_renable, DATAleft_out, data_out_lenable, DATAleft_in, data_in_lenable, DATAright_out, data_out_renable);
    
    integer i; 
    initial
    begin
        clk = 0;
        rst = 1;
        data_in_renable = 0;
        data_in_lenable = 0;
        #120 rst = 0;
        #1 
        /**右进数**/
        for (i = 0; i < 15; i = i + 1) begin
            transmit(data_in_renable, DATAright_in);
            #4;
        end
        /**左进数**/
        data_in_renable = 0;
        #4
        for (i = 0; i < 15; i = i + 1) begin
            transmit(data_in_lenable, DATAleft_in);
            #4;
        end
        /**右进数**/
        data_in_lenable = 0;    
        #4
        for (i = 0; i < 15; i = i + 1) begin
            transmit(data_in_renable, DATAright_in);
            #4;
        end
        #100 $finish ;
    end
    task transmit;
        output  triger;
        output [15:0] data;
        begin
            triger = 1;
            data = {$random}%60;
           //data = 1;
        end
    endtask

    
endmodule

