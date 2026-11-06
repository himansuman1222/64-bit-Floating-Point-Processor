// Instruction memory : 256 x 32-bit ROM, loaded from a hex file
module instr_mem #(parameter INIT_FILE = "programs/program.hex") (
    input  [7:0]  addr,
    output [31:0] instr
);
    reg [31:0] mem [0:255];
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) mem[i] = 32'h0;   // NOPs
        $readmemh(INIT_FILE, mem);
    end
    assign instr = mem[addr];
endmodule
