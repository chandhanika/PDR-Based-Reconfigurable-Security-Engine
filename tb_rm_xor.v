`timescale 1ns / 1ps

// Self-checking testbench for rm_xor.
// Tests reset, then every one of the 65,536 data/key combinations.
module tb_rm_xor;

    reg        clk     = 1'b0;
    reg        rst     = 1'b1;
    reg  [7:0] data_in = 8'hFF;
    reg  [7:0] key     = 8'h0F;
    wire [7:0] result;
    wire [1:0] rm_id;

    integer errors = 0;
    integer i;

    rm_xor dut (
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

        // Test 2: exhaustive sweep
        rst = 1'b0;
        for (i = 0; i < 65536; i = i + 1) begin
            {key, data_in} = i[15:0];
            @(posedge clk);
            #1;
            if (result !== (data_in ^ key) || rm_id !== 2'b01) begin
                errors = errors + 1;
                if (errors < 10)
                    $display("FAIL data=%h key=%h result=%h rm_id=%b",
                             data_in, key, result, rm_id);
            end
        end

        // Test 3: reset in the middle of operation
        rst = 1'b1;
        @(posedge clk);
        #1;
        if (result !== 8'h00 || rm_id !== 2'b00) begin
            errors = errors + 1;
            $display("FAIL mid-run reset");
        end

        if (errors == 0) $display("PASS: rm_xor, all tests OK");
        else             $display("FAIL: rm_xor, %0d errors", errors);
        $finish;
    end

endmodule