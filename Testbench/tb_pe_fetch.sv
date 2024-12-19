`timescale 1ns / 1ps

module tb_pe_fetch;

    // Parameters
    parameter OPCODE_LEN = 4;
    parameter PC_WIDTH = 12;
    parameter INST_LEN = 12;
    parameter DATA_WIDTH = 32;
    parameter PE_ELEMENTS = 4;
    parameter DRAM_DEPTH = 256;
    localparam DRAM_ADDR_WIDTH = $clog2(DRAM_DEPTH);

    // Signals
    logic clk;
    logic rstn;
    logic valid;
    logic [OPCODE_LEN-1:0] opcode;

    logic [PC_WIDTH-1:0] inst_read_addr;
    logic [INST_LEN-1:0] inst_read_data;

    logic [DRAM_ADDR_WIDTH-1:0] ram_a_read_addr;
    logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0] ram_a_read_data;
    logic ram_a_rd_en;

    logic [DRAM_ADDR_WIDTH-1:0] ram_b_read_addr;
    logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0] ram_b_read_data;
    logic ram_b_rd_en;

    logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0] data_a, data_b;

    // Instantiate DUT (Device Under Test)
    pe_fetch #(
        .OPCODE_LEN(OPCODE_LEN),
        .PC_WIDTH(PC_WIDTH),
        .INST_LEN(INST_LEN),
        .DATA_WIDTH(DATA_WIDTH),
        .PE_ELEMENTS(PE_ELEMENTS),
        .DRAM_DEPTH(DRAM_DEPTH)
    ) uut (
        .clk(clk),
        .rstn(rstn),
        .valid(valid),
        .opcode(opcode),
        .inst_read_addr(inst_read_addr),
        .inst_read_data(inst_read_data),
        .ram_a_read_addr(ram_a_read_addr),
        .ram_a_read_data(ram_a_read_data),
        .ram_a_rd_en(ram_a_rd_en),
        .ram_b_read_addr(ram_b_read_addr),
        .ram_b_read_data(ram_b_read_data),
        .ram_b_rd_en(ram_b_rd_en),
        .data_a(data_a),
        .data_b(data_b)
    );

    // Clock generation
    always #5 clk = ~clk; // 10 ns clock period

    // Mock memory initialization
    logic [INST_LEN-1:0] inst_memory [0:255];
    logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0] ram_a_memory [0:255];
    logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0] ram_b_memory [0:255];

    // Instruction memory simulation
    assign inst_read_data = inst_memory[inst_read_addr];

    // Data memory simulation
    assign ram_a_read_data = ram_a_memory[ram_a_read_addr];
    assign ram_b_read_data = ram_b_memory[ram_b_read_addr];

    // Testbench procedure
    initial begin
        // Initialize signals
        clk = 0;
        rstn = 0;
        valid = 0;

        // Initialize instruction memory with sample instructions
        inst_memory[0] = 12'h000;
        inst_memory[1] = 12'h019; // FETCH_A, address 0x100
        inst_memory[2] = 12'h01a; // FETCH_B, address 0x200
        inst_memory[3] = 12'h001; // ADD
        inst_memory[4] = 12'h008; // STOP

        // Initialize data memory with sample data
        ram_a_memory[1] = {32'hA1, 32'hA2, 32'hA3, 32'hA4};
        ram_b_memory[1] = {32'hB1, 32'hB2, 32'hB3, 32'hB4};

        // Reset the system
        #10;
        rstn = 1;

        // Test Case 1: FETCH_A
        valid = 1;
        #20;
        valid = 0;

//        // Test Case 2: FETCH_B
//        #20;
//        valid = 1;
//        #10;
//        valid = 0;

//        // Test Case 3: ADD
//        #20;
//        valid = 1;
//        #10;
//        valid = 0;

//        // Test Case 4: STOP
//        #20;
//        valid = 1;
//        #10;
//        valid = 0;

        // End simulation
        #100;
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time: %0t | Opcode: %0h | PC: %0h | Inst_Addr: %0h | Inst_Data: %0h | RamA_Addr: %0h | RamB_Addr: %0h | RamA_Data: %p | RamB_Data: %p", 
                 $time, opcode, inst_read_addr, inst_read_addr, inst_read_data, ram_a_read_addr, ram_b_read_addr, ram_a_read_data, ram_b_read_data);
    end

endmodule
