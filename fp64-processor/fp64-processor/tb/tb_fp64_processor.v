// Self-checking system testbench: runs programs/program.hex and checks data memory
`timescale 1ns/1ps
module tb_fp64_processor;
    reg clk = 0, rst = 1;
    wire halted;
    wire [7:0] pc;
    integer errors = 0, cycles = 0;

    fp64_processor_top dut (.clk(clk), .rst(rst), .halted(halted), .pc_out(pc));

    always #5 clk = ~clk;   // 100 MHz

    task check(input [7:0] addr, input [63:0] expected, input [127:0] name);
        begin
            if (dut.dmem.mem[addr] !== expected) begin
                errors = errors + 1;
                $display("FAIL  DMEM[%0d] (%0s) = %h, expected %h", addr, name, dut.dmem.mem[addr], expected);
            end else
                $display("PASS  DMEM[%0d] (%0s) = %h", addr, name, dut.dmem.mem[addr]);
        end
    endtask

    initial begin
        $dumpfile("sim/fp64_processor.vcd");
        $dumpvars(0, tb_fp64_processor);
        repeat (3) @(posedge clk);
        @(negedge clk);   // release reset away from the active edge (avoids a race)
        rst = 0;
        while (!halted && cycles < 1000) begin @(posedge clk); cycles = cycles + 1; end
        #1;
        $display("Program halted at PC=%0d after %0d cycles", pc, cycles);
        check(16, 64'h400e000000000000, "a+b");
        check(17, 64'hbfe8000000000000, "a-b");
        check(18, 64'hc006800000000000, "(a+b)*(a-b)");
        check(19, 64'h0000000000000000, "skipped by BEQ");
        check(20, 64'h4006800000000000, "FNEG");
        check(21, 64'h4006800000000000, "FABS");
        check(22, 64'h3ff0000000000000, "FLT flag");
        check(23, 64'h0000000000000000, "FXOR x,x");
        if (!halted) begin errors = errors + 1; $display("FAIL: processor did not halt"); end
        if (errors == 0) $display("PROCESSOR TEST PASSED"); else $display("PROCESSOR TEST FAILED (%0d errors)", errors);
        $finish;
    end
endmodule
