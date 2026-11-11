`timescale 1ns / 1ps

// Reconfigurable Module 2: circular left rotation of data_in
// by key[2:0] positions (0 to 7). Lightweight transformation,
// NOT secure encryption.
module rm_rotate(
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] data_in,
    input  wire [7:0] key,
    output reg  [7:0] result,
    output reg  [1:0] rm_id
);

    wire [15:0] doubled = {data_in, data_in};
    wire [15:0] shifted = doubled << key[2:0];

    always @(posedge clk) begin
        if (rst) begin
            result <= 8'h00;
            rm_id  <= 2'b00;
        end else begin
            result <= shifted[15:8];
            rm_id  <= 2'b10;   // 10 = rotate module
        end
    end

endmodule