`timescale 1ns/1ps

module iir1 (
    input  wire        clk,
    input  wire        rst_n,     
    input  wire signed [3:0] x_in,
    input  wire signed [3:0] b0,
    input  wire signed [3:0] b1,
    input  wire signed [3:0] a1,
    output reg  signed [7:0] y_out
);

    reg signed [3:0] x_prev;
    reg signed [7:0] y_prev;

    wire signed [7:0]  mult_b0;
    wire signed [7:0]  mult_b1;
    wire signed [11:0] mult_a1;
    wire signed [7:0]  a1_trunc;
    wire signed [7:0]  y_next;

    assign mult_b0 = b0 * x_in;
    assign mult_b1 = b1 * x_prev;
    assign mult_a1 = a1 * y_prev;
    assign a1_trunc = mult_a1 >>> 4;

    assign y_next = mult_b0 + mult_b1 + a1_trunc;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_prev <= 4'sd0;
            y_prev <= 8'sd0;
            y_out  <= 8'sd0;
        end else begin
            y_out  <= y_next;
            x_prev <= x_in;
            y_prev <= y_next; 
        end
    end

endmodule

