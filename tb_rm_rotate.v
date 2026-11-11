`timescale 1ns / 1ps

// Self-checking testbench for rm_rotate.
// Expected value comes from an independent model:
// rotate-left of data_in by key[2:0] positions (0 to 7).
module tb_rm_rotate;

    reg        clk     = 1'b0;
    reg        rst     = 1'b1;
    reg  [7:0] data_in = 8'hA5;
    reg  [7:0] key     = 8'h03;
    wire [7:0] result;
    wire [1:0] rm_id;

    integer errors = 0;
    integer i;
    integer d, k;
    integer expected;

    rm_rotate dut (
        .clk     (clk),
        .rst     (rst),
        .data_in (data_in),
        .key     (key),
        .result  (result),
        .rm_id   (rm_id)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        // Test 1: reset forces result and rm_id to zero
        repeat (2) @(posedge clk);
        #1;
        if (result !== 8'h00 || rm_id !== 2'b00) begin
            errors = errors + 1;
            $display("FAIL reset: result=%h rm_id=%b", result, rm_id);
        end

        // Test 2: a few hand-checked cases
        rst = 1'b0;
        data_in = 8'b00000001; key = 8'd1; @(posedge clk); #1;
        if (result !== 8'b00000010) begin errors = errors + 1; $display("FAIL 01 rot1: %b", result); end
        data_in = 8'b00000001; key = 8'd3; @(posedge clk); #1;
        if (result !== 8'b00001000) begin errors = errors + 1; $display("FAIL 01 rot3: %b", result); end
        data_in = 8'b10000000; key = 8'd1; @(posedge clk); #1;
        if (result !== 8'b00000001) begin errors = errors + 1; $display("FAIL wrap: %b", result); end
        data_in = 8'hA5;       key = 8'd0; @(posedge clk); #1;
        if (result !== 8'hA5) begin errors = errors + 1; $display("FAIL rot0: %h", result); end
        data_in = 8'hA5;       key = 8'd7; @(posedge clk); #1;
        if (result !== 8'hD2) begin errors = errors + 1; $display("FAIL rot7: %h", result); end

        // Test 3: exhaustive sweep, upper key bits must be ignored
        for (i = 0; i < 65536; i = i + 1) begin
            {key, data_in} = i[15:0];
            @(posedge clk);
            #1;
            d = data_in;
            k = key[2:0];
            expected = ((d << k) | (d >> (8 - k))) & 8'hFF;
            if (result !== expected[7:0] || rm_id !== 2'b10) begin
                errors = errors + 1;
                if (errors < 10)
                    $display("FAIL data=%h key=%h result=%h expected=%h rm_id=%b",
                             data_in, key, result, expected[7:0], rm_id);
            end
        end

        // Test 4: reset in the middle of operation
        rst = 1'b1;
        @(posedge clk);
        #1;
        if (result !== 8'h00 || rm_id !== 2'b00) begin
            errors = errors + 1;
            $display("FAIL mid-run reset");
        end

        if (errors == 0) $display("PASS: rm_rotate, all tests OK");
        else             $display("FAIL: rm_rotate, %0d errors", errors);
        $finish;
    end

endmodule