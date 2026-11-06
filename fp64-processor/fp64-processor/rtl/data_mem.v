// Data memory : 256 x 64-bit RAM, sync write / async read, preloadable
module data_mem #(parameter INIT_FILE = "programs/data.hex") (
    input         clk,
    input         we,
    input  [7:0]  addr,
    input  [63:0] wdata,
    output [63:0] rdata
);
    reg [63:0] mem [0:255];
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) mem[i] = 64'd0;
        $readmemh(INIT_FILE, mem);
    end
    always @(posedge clk) if (we) mem[addr] <= wdata;
    assign rdata = mem[addr];
endmodule
