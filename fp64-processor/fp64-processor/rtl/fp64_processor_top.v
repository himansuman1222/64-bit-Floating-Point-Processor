// ---------------------------------------------------------------------------
// fp64_processor_top : single-cycle 64-bit IEEE 754 floating-point processor
//
//   instr[31:27] opcode   instr[26:22] rd    instr[21:17] rs1
//   instr[16:12] rs2      instr[11:0]  imm   (imm[7:0] = absolute address/target)
// ---------------------------------------------------------------------------
`include "fp64_defs.vh"
module fp64_processor_top #(
    parameter IMEM_FILE = "programs/program.hex",
    parameter DMEM_FILE = "programs/data.hex"
)(
    input         clk,
    input         rst,
    output        halted,
    output [7:0]  pc_out
);
    reg  [7:0]  pc;
    wire [31:0] instr;
    wire [4:0]  opcode = instr[31:27];
    wire [4:0]  rd     = instr[26:22];
    wire [4:0]  rs1    = instr[21:17];
    wire [4:0]  rs2    = instr[16:12];
    wire [7:0]  imm8   = instr[7:0];

    wire        reg_write, mem_read, mem_write, jump, branch, halt;
    wire [3:0]  alu_op;
    wire [63:0] rd1, rd2, alu_result, dmem_rdata, wb_data;
    wire        f_zero, f_neg, f_nan, f_inf;

    instr_mem #(.INIT_FILE(IMEM_FILE)) imem (.addr(pc), .instr(instr));

    control_unit cu (
        .opcode(opcode), .reg_write(reg_write), .mem_read(mem_read),
        .mem_write(mem_write), .jump(jump), .branch(branch),
        .halt(halt), .alu_op(alu_op)
    );

    reg_file rf (
        .clk(clk), .we(reg_write & ~rst), .raddr1(rs1), .raddr2(rs2),
        .waddr(rd), .wdata(wb_data), .rdata1(rd1), .rdata2(rd2)
    );

    fp64_alu alu (
        .a(rd1), .b(rd2), .alu_op(alu_op), .result(alu_result),
        .flag_zero(f_zero), .flag_neg(f_neg), .flag_nan(f_nan), .flag_inf(f_inf)
    );

    data_mem #(.INIT_FILE(DMEM_FILE)) dmem (
        .clk(clk), .we(mem_write & ~rst), .addr(imm8),
        .wdata(rd2), .rdata(dmem_rdata)
    );

    assign wb_data = mem_read ? dmem_rdata : alu_result;

    wire branch_taken = branch & (alu_result[62:0] != 63'd0);   // FEQ true -> 1.0

    always @(posedge clk) begin
        if (rst)                       pc <= 8'd0;
        else if (halt)                 pc <= pc;
        else if (jump || branch_taken) pc <= imm8;
        else                           pc <= pc + 8'd1;
    end

    assign halted = halt;
    assign pc_out = pc;
endmodule
