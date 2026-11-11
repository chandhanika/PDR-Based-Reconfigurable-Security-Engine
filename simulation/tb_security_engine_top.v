`timescale 1ns / 1ps

// Integration testbench for security_engine_top (static region).
// NOTE: the top file instantiates rm_xor, so this simulates the XOR
// configuration only. It checks the static logic: heartbeat counter,
// LED wiring and reset. It cannot simulate partial reconfiguration;
// that is demonstrated on the board.
module tb_security_engine_top;

    reg         clk  = 1'b0;
    reg         btnC = 1'b1;
    reg  [15:0] sw   = 16'h0000;
    wire [15:0] led;

    integer    errors = 0;
    integer    i;
    reg [26:0] hb_before;
    reg [7:0]  expected;

    security_engine_top dut (
        .clk  (clk),
        .btnC (btnC),
        .sw   (sw),
        .led  (led)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    // Inputs change on falling edges, outputs are sampled on the next
    // falling edge, so exactly one rising edge happens in between.
    initial begin
        // Test 1: reset holds everything at zero
        sw = 16'hA5C3;
        repeat (3) @(negedge clk);
        if (led !== 16'h0000 || dut.hb_cnt !== 27'd0) begin
            errors = errors + 1;
            $display("FAIL reset: led=%h hb_cnt=%h", led, dut.hb_cnt);
        end

        // Test 2: random switch values after reset is released
        btnC = 1'b0;
        for (i = 0; i < 2000; i = i + 1) begin
            sw = $urandom;
            hb_before = dut.hb_cnt;
            @(negedge clk);
            expected = sw[7:0] ^ sw[15:8];
            if (led[7:0] !== expected) begin
                errors = errors + 1;
                if (errors < 10)
                    $display("FAIL result: sw=%h led[7:0]=%h expected=%h",
                             sw, led[7:0], expected);
            end
            if (led[14:13] !== 2'b01) begin
                errors = errors + 1;
                if (errors < 10) $display("FAIL rm_id: led[14:13]=%b", led[14:13]);
            end
            if (led[12:8] !== 5'b00000) begin
                errors = errors + 1;
                if (errors < 10) $display("FAIL unused LEDs: %b", led[12:8]);
            end
            if (dut.hb_cnt !== hb_before + 27'd1) begin
                errors = errors + 1;
                if (errors < 10) $display("FAIL counter did not step by 1");
            end
        end

        // Test 3: heartbeat LED follows counter bit 26 (set the counter
        // just before each change instead of simulating 67M cycles)
        dut.hb_cnt = 27'h3FFFFFF;
        @(negedge clk);
        if (dut.hb_cnt !== 27'h4000000 || led[15] !== 1'b1) begin
            errors = errors + 1;
            $display("FAIL heartbeat rise: hb_cnt=%h led15=%b", dut.hb_cnt, led[15]);
        end
        dut.hb_cnt = 27'h7FFFFFF;
        @(negedge clk);
        if (dut.hb_cnt !== 27'd0 || led[15] !== 1'b0) begin
            errors = errors + 1;
            $display("FAIL heartbeat fall: hb_cnt=%h led15=%b", dut.hb_cnt, led[15]);
        end

        // Test 4: reset in the middle of operation clears counter and LEDs
        btnC = 1'b1;
        @(negedge clk);
        if (led !== 16'h0000 || dut.hb_cnt !== 27'd0) begin
            errors = errors + 1;
            $display("FAIL mid-run reset: led=%h hb_cnt=%h", led, dut.hb_cnt);
        end

        if (errors == 0) $display("PASS: security_engine_top, all tests OK");
        else             $display("FAIL: security_engine_top, %0d errors", errors);
        $finish;
    end

endmodule
