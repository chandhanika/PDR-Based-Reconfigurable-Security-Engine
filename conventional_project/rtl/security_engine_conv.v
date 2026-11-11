`timescale 1ns / 1ps

// CONVENTIONAL comparison design: all three operations are always
// present in the FPGA and a multiplexer picks one.
// sel = {btnL, btnR}: 00 = XOR, 01 = rotate, 10 = checksum.
module security_engine_conv(
    input  wire        clk,
    input  wire        btnC,
    input  wire        btnL,
    input  wire        btnR,
    input  wire [15:0] sw,
    output wire [15:0] led
);

    wire [7:0] res_xor, res_rot, res_sum;
    wire [1:0] id_xor,  id_rot,  id_sum;

    reg [26:0] hb_cnt = 27'd0;
    always @(posedge clk) begin
        if (btnC) hb_cnt <= 27'd0;
        else      hb_cnt <= hb_cnt + 1'b1;
    end

    rm_xor      u_xor (.clk(clk), .rst(btnC), .data_in(sw[7:0]), .key(sw[15:8]),
                       .result(res_xor), .rm_id(id_xor));
    rm_rotate   u_rot (.clk(clk), .rst(btnC), .data_in(sw[7:0]), .key(sw[15:8]),
                       .result(res_rot), .rm_id(id_rot));
    rm_checksum u_sum (.clk(clk), .rst(btnC), .data_in(sw[7:0]), .key(sw[15:8]),
                       .result(res_sum), .rm_id(id_sum));

    reg [7:0] result;
    reg [1:0] rm_id;
    always @(*) begin
        case ({btnL, btnR})
            2'b01:   begin result = res_rot; rm_id = id_rot; end
            2'b10:   begin result = res_sum; rm_id = id_sum; end
            default: begin result = res_xor; rm_id = id_xor; end
        endcase
    end

    assign led = {hb_cnt[26], rm_id, 5'b00000, result};

endmodule