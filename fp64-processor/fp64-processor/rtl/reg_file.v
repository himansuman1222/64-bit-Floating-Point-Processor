// 32 x 64-bit floating-point register file, 2 async read ports, 1 sync write port
module reg_file (
    input         clk,
    input         we,
    input  [4:0]  raddr1,
    input  [4:0]  raddr2,
    input  [4:0]  waddr,
    input  [63:0] wdata,
    output [63:0] rdata1,
    output [63:0] rdata2
);
    reg [63:0] regs [0:31];
    integer i;
    initial for (i = 0; i < 32; i = i + 1) regs[i] = 64'd0;

    always @(posedge clk) if (we) regs[waddr] <= wdata;

    assign rdata1 = regs[raddr1];
    assign rdata2 = regs[raddr2];
endmodule
