`timescale 1ns / 1ps

// STATIC REGION: switches in, LEDs out, heartbeat counter.
// The reconfigurable partition will be the instance u_rm.
module security_engine_top(
    input  wire        clk,
    input  wire        btnC,
    input  wire [15:0] sw,
    output wire [15:0] led
);

    wire [7:0] rm_result;
    wire [1:0] rm_id;

    // Heartbeat counter (static logic, always running)
    reg [26:0] hb_cnt = 27'd0;

    always @(posedge clk) begin
        if (btnC)
            hb_cnt <= 27'd0;
        else
            hb_cnt <= hb_cnt + 1'b1;
    end

    // Reconfigurable partition instance
    rm_xor u_rm (
        .clk     (clk),
        .rst     (btnC),
        .data_in (sw[7:0]),
        .key     (sw[15:8]),
        .result  (rm_result),
        .rm_id   (rm_id)
    );

    // led[15]    = heartbeat (static region alive)
    // led[14:13] = which module is loaded
    // led[12:8]  = unused (off)
    // led[7:0]   = result from the reconfigurable module
    assign led = {hb_cnt[26], rm_id, 5'b00000, rm_result};

endmodule