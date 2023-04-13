`timescale 1ns / 1ps


module systolic_ip #(
    parameter DATA_NUM = 10,  //total data input
    parameter DATA_WIDTH = 16  //width of the data
    )
    (
    input clk,
    input rst,
    input [1:0] fsm_state,
    input [DATA_WIDTH-1:0] right_in,  //data right input, one input for each clock cycle
    input tag_right_in,  //tag of the right group
    output [DATA_WIDTH-1:0] left_out, //data left output, one output for each clock cycle
    output  tag_right_out,  //tag of the right group

    input [DATA_WIDTH-1:0] left_in,  //data left input, one input for each clock cycle
    input tag_left_in,  //tag of the left group
    output [DATA_WIDTH-1:0] right_out, //data right output, one output for each clock cycle
    output  tag_left_out   //tag of the left group
   
    );
    
    
    localparam RIGHT_IN_LEFT_OUT = 1'b1;  

    localparam LEFT_IN_RIGHT_OUT = 1'b0;    

    reg[DATA_WIDTH-1 : 0] data [1 : 0];  
    reg[1 : 0] tag [1 : 0];
    
    
    
    
    assign left_out  = data[1];
    assign right_out = data[0];
    assign tag_left_out  = tag[0];
    assign tag_right_out = tag[1];
    
    always @(posedge clk) begin
        if(rst) begin
                data[0] <= {DATA_WIDTH{1'b1}};
                data[1] <= {DATA_WIDTH{1'b1}};
            end
         case (fsm_state)
            RIGHT_IN_LEFT_OUT:
                if (tag_right_in==tag[0]) begin
                    {data[0], data[1]} <= (right_in < data[0] ) ? {right_in , data[0]} : {data[0] , right_in};
                
                end //end RIGHT_IN_LEFT_OUT
                else begin
                tag[1] <= tag[0];
                tag[0] <= tag_left_in;
                end
            LEFT_IN_RIGHT_OUT: begin
                if (tag_left_in==tag[1]) begin
                    {data[1], data[0]} <= (left_in < data[1] ) ? {left_in , data[1]} : {data[1] , left_in};
                end //end LEFT_IN_RIGHT_OUT
                else begin
                tag[0] <= tag[1];
                tag[1] <= tag_right_in;
                end
            end
        endcase
    end
    
    
endmodule
