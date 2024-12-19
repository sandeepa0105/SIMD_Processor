`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module pe_fetch #(
    parameter OPCODE_LEN = 4,
    parameter PC_WIDTH = 12,
    parameter INST_LEN = 12,
    parameter DATA_WIDTH = 32,
    parameter PE_ELEMENTS = 4,
    parameter DRAM_DEPTH = 256,
    localparam DRAM_ADDR_WIDTH = $clog2(DRAM_DEPTH)
)(
    input logic             clk,          // Clock signal
    input logic             rstn,         // Active-low reset
    input logic             valid,        // Valid signal to start instruction fetch
    output logic [OPCODE_LEN-1:0] opcode,

    input logic pe_stage_1_valid,store_result,pe_stage_2_valid,
    input logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0] pe_stage_1_output,
    input logic [DATA_WIDTH-1:0] pe_stage_2_output,

    output logic [PC_WIDTH-1:0] inst_read_addr,
    input logic [INST_LEN-1:0] inst_read_data,

    output logic [DRAM_ADDR_WIDTH-1:0] ram_a_read_addr,
    input logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0] ram_a_read_data,
    output logic ram_a_rd_en,

    output logic [DRAM_ADDR_WIDTH-1:0] ram_b_read_addr,
    input logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0] ram_b_read_data,
    output logic ram_b_rd_en,

    output logic [DRAM_ADDR_WIDTH-1:0]ram_result_write_addr,
    output logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0]ram_result_write_data,
    output logic ram_result_wr_en,

    output logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0] data_a,data_b
    

    );

    // Internal signals
    logic [PC_WIDTH-1:0] pc_out;
    logic [INST_LEN-1:0] instruction;
    logic load_a, load_b,save_result;
    logic [DRAM_ADDR_WIDTH-1:0] data_addr;
    logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0] result;
    logic [DRAM_ADDR_WIDTH-1:0] result_addr;
    logic pe_stage_2_valid_buffer;


    typedef enum logic [OPCODE_LEN-1:0] {NOOP, ADD, SUB, MUL, DOTP, STORE_TEMP_S1, STORE_TEMP_S2, STORE_RESULT, STOP, FETCH_A, FETCH_B} OPCODE; 

    program_counter #(
        .OPCODE_LEN(OPCODE_LEN),
        .PC_WIDTH(PC_WIDTH)
    ) pc (
        .clk(clk),
        .rstn(rstn),
        .valid(valid),
        .instruction(opcode),
        .pc(pc_out)
    );

    always_comb begin
        unique0 case (opcode)
            NOOP: begin
                load_a = 0;
                load_b = 0;
                save_result = 0;
            end
            ADD: begin
                load_a = 0;
                load_b = 0;
                save_result = 0;
            end
            SUB: begin
                load_a = 0;
                load_b = 0;
                save_result = 0;
            end
            MUL: begin
                load_a = 0;
                load_b = 0;
                save_result = 0;
            end
            DOTP: begin
                load_a = 0;
                load_b = 0;
                save_result = 0;
            end
            STORE_TEMP_S1: begin
                load_a = 0;
                load_b = 0;
                save_result = 0;
            end
            STORE_TEMP_S2: begin
                load_a = 0;
                load_b = 0;
                save_result = 0;
            end
            STORE_RESULT: begin
                load_a = 0;
                load_b = 0;
                save_result = 1;
            end
            STOP: begin
                load_a = 0;
                load_b = 0;
                save_result = 0;
            end
            FETCH_A: begin
                load_a = 1;
                load_b = 0;
                save_result = 0;
            end
            FETCH_B: begin
                load_a = 0;
                load_b = 1;
                save_result = 0;
            end
            default: begin
                load_a = 0;
                load_b = 0;
                save_result = 0;
            end


        endcase 

    end

    // always_ff@(posedge clk) begin
    //     if (pe_stage_1_valid && !store_result)
    //         result <= pe_stage_1_output;
    //     else if (pe_stage_2_valid_buffer && !store_result) begin
    //         result[PE_ELEMENTS-1] <= pe_stage_2_output;

    //         for (int i=1; i<PE_ELEMENTS; i++) begin
    //             result[i-1] <= result[i];
    //         end
    //     end
    // end

    always_ff@(posedge clk) begin
        if (pe_stage_1_valid && !store_result)
            result <= pe_stage_1_output;
        else if (pe_stage_2_valid_buffer && !store_result) begin
            result[0] <= pe_stage_2_output;

            for (int i=1; i<PE_ELEMENTS; i++) begin
                result[i] <= result[i-1];
            end
        end
    end
    
    // handling internal signals
    always_ff@(posedge clk) begin
        if (save_result == 1) begin
            result_addr <= data_addr;
        end
    end

    // buffering the pe_stage_2_valid signal
    always_ff@(posedge clk) begin
        pe_stage_2_valid_buffer <= pe_stage_2_valid;
    end

    

    assign data_addr = inst_read_data[INST_LEN-1:OPCODE_LEN];
    assign opcode = inst_read_data[OPCODE_LEN-1:0];
    assign inst_read_addr = pc_out;
    assign instruction = inst_read_data;
    assign ram_a_read_addr = data_addr;
    assign ram_b_read_addr = data_addr;
    assign ram_a_rd_en = load_a;
    assign ram_b_rd_en = load_b;

    assign data_a = ram_a_read_data;
    assign data_b = ram_b_read_data;

    assign ram_result_write_addr = result_addr;
    assign ram_result_write_data = result;
    assign ram_result_wr_en = store_result;


endmodule
