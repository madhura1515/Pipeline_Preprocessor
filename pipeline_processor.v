module pipeline_processor(
    input clk,
    input reset,
    output [31:0] result
);

    // Instruction Memory (4 instructions)
    reg [31:0] instr_mem [0:3];

    // Register file (32 registers, 32 bits each)
    reg [31:0] reg_file [0:31];

    // Pipeline registers for each stage
    reg [31:0] IF_instr, ID_instr, EX_instr, WB_instr;
    reg [31:0] IF_PC, ID_PC, EX_PC, WB_PC;
    reg [31:0] ALU_result, WB_data;

    // Initialize Instruction Memory
    initial begin
        instr_mem[0] = 32'b000000_00001_00010_00011_00000_100000; // ADD R3, R1, R2
        instr_mem[1] = 32'b000000_00001_00010_00100_00000_100010; // SUB R4, R1, R2
        instr_mem[2] = 32'b100011_00000_00001_00000_00000_000000; // LOAD R1, 0(R0)
        instr_mem[3] = 32'b000000_00001_00010_00101_00000_100000; // ADD R5, R1, R2
    end

    // Instruction Fetch (IF) Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IF_PC <= 0;
            IF_instr <= 32'b0;
        end else begin
            IF_instr <= instr_mem[IF_PC];
            IF_PC <= IF_PC + 1;
        end
    end

    // Instruction Decode (ID) Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ID_instr <= 32'b0;
            ID_PC <= 0;
        end else begin
            ID_instr <= IF_instr;
            ID_PC <= IF_PC;
        end
    end

    // Execute (EX) Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_instr <= 32'b0;
            EX_PC <= 0;
            ALU_result <= 0;
        end else begin
            EX_instr <= ID_instr;
            EX_PC <= ID_PC;
            case (EX_instr[31:26]) // Opcode
                6'b000000: // R-type (ADD, SUB)
                    case (EX_instr[5:0])
                        6'b100000: ALU_result <= reg_file[EX_instr[25:21]] + reg_file[EX_instr[20:16]]; // ADD
                        6'b100010: ALU_result <= reg_file[EX_instr[25:21]] - reg_file[EX_instr[20:16]]; // SUB
                        default: ALU_result <= 0;
                    endcase
                6'b100011: // LOAD
                    ALU_result <= reg_file[EX_instr[25:21]] + EX_instr[15:0]; // Address calculation
                default: ALU_result <= 0;
            endcase
        end
    end

    // Write Back (WB) Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            WB_instr <= 32'b0;
            WB_PC <= 0;
            WB_data <= 0;
        end else begin
            WB_instr <= EX_instr;
            WB_PC <= EX_PC;
            case (WB_instr[31:26])
                6'b000000: reg_file[WB_instr[15:11]] <= ALU_result; // R-type
                6'b100011: reg_file[WB_instr[20:16]] <= ALU_result; // LOAD
                default: ;
            endcase
            WB_data <= ALU_result;
        end
    end

    // Output result
    assign result = WB_data;

endmodule