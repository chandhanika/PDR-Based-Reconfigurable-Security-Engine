`timescale 1ns / 1ps

// Reconfigurable Module 3: 8-bit additive checksum of the two
// input bytes: (data_in + key) mod 256. An integrity-style
// operation, NOT a cryptographic one.
module rm_checksum(
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
            result <= data_in + key;
            rm_id  <= 2'b11;   // 11 = checksum module
        end
    end

endmodule