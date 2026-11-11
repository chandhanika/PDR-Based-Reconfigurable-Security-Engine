`timescale 1ns / 1ps

// Self-checking testbench for rm_checksum.
// Expected value: (data_in + key) mod 256.
module tb_rm_checksum;

    reg        clk     = 1'b0;
    reg        rst     = 1'b1;
    reg  [7:0] data_in = 8'h10;
    reg  [7:0] key     = 8'h20;
    wire [7:0] result;
    wire [1:0] rm_id;

    integer errors = 0;
    integer i;
    integer expected;

    rm_checksum dut (
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

        // Test 2: hand-checked cases
        rst = 1'b0;
        data_in = 8'd3;   key = 8'd1;   @(posedge clk); #1;
        if (result !== 8'd4)  begin errors = errors + 1; $display("FAIL 3+1: %0d", result); end
        data_in = 8'd255; key = 8'd1;   @(posedge clk); #1;
        if (result !== 8'd0)  begin errors = errors + 1; $display("FAIL wrap 255+1: %0d", result); end
        data_in = 8'd255; key = 8'd255; @(posedge clk); #1;
        if (result !== 8'd254) begin errors = errors + 1; $display("FAIL 255+255: %0d", result); end
        data_in = 8'd0;   key = 8'd0;   @(posedge clk); #1;
        if (result !== 8'd0)  begin errors = errors + 1; $display("FAIL 0+0: %0d", result); end

        // Test 3: exhaustive sweep of all 65,536 combinations
        for (i = 0; i < 65536; i = i + 1) begin
            {key, data_in} = i[15:0];
            @(posedge clk);
            #1;
            expected = (data_in + key) & 8'hFF;
            if (result !== expected[7:0] || rm_id !== 2'b11) begin
                errors = errors + 1;
                if (errors < 10)
                    $display("FAIL data=%0d key=%0d result=%0d expected=%0d rm_id=%b",
                             data_in, key, result, expected, rm_id);
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

        if (errors == 0) $display("PASS: rm_checksum, all tests OK");
        else             $display("FAIL: rm_checksum, %0d errors", errors);
        $finish;
    end

endmodule
