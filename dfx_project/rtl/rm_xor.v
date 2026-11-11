`timescale 1ns / 1ps

// Reconfigurable Module 1: bitwise XOR transformation.
// A lightweight data transformation, NOT secure encryption.
module rm_xor(
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] data_in,
    input  wire [7:0] key,
    output reg  [7:0] result,
    output reg  [1:0] rm_id
);

    always @(posedge clk) begin
        if (rst) begin
            result <= 8'h00;
            rm_id  <= 2'b00;
        end else begin
            result <= data_in ^ key;
            rm_id  <= 2'b01;   // 01 = XOR module
        end
    end

endmodule