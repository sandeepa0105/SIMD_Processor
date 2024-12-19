`timescale 1ns / 1ps

module tb_top;

    // Parameters
    parameter INST_LEN = 12;
    parameter DATA_WIDTH = 32;
    parameter PE_ELEMENTS = 4;
    parameter PC_LEN = 12;
    parameter DRAM_DEPTH = 256;
    localparam DRAM_ADDR_WIDTH = $clog2(DRAM_DEPTH);

    // Signals
    logic rstn, clk, valid,stop;

    // Instantiate DUT (Device Under Test)
    top #(
        .INST_LEN(INST_LEN),
        .DATA_WIDTH(DATA_WIDTH),
        .PE_ELEMENTS(PE_ELEMENTS),
        .PC_LEN(PC_LEN),
        .DRAM_DEPTH(DRAM_DEPTH)
    ) dut (
        .rstn(rstn),
        .clk(clk),
        .valid(valid),
        .stop(stop)
        
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns clock period

    // Instruction and data memories
    // logic [INST_LEN-1:0] instruction_memory [0:511];
    // logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0] ram_a_memory [0:255];
    // logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0] ram_b_memory [0:255];

    // Assign data from mock memories
    // assign dut.inst_read_data = instruction_memory[dut.inst_read_addr];
    // assign dut.ram_a_read_data = ram_a_memory[dut.ram_a_read_addr];
    // assign dut.ram_b_read_data = ram_b_memory[dut.ram_b_read_addr];

    // Testbench procedure
    initial begin
        // Initialize signals
        clk = 0;
        rstn = 0;
        valid = 0;

        // Initialize instruction memory
        // instruction_memory[0] = 12'h100; // FETCH_A, address 0x100
        // instruction_memory[1] = 12'h200; // FETCH_B, address 0x200
        // instruction_memory[2] = 12'h300; // ADD
        // instruction_memory[3] = 12'h400; // STOP

        // Initialize data memories
        // ram_a_memory[0] = {32'hA1, 32'hA2, 32'hA3, 32'hA4};
        // ram_b_memory[0] = {32'hB1, 32'hB2, 32'hB3, 32'hB4};

        // Reset
        #120;
        rstn = 1;

        // Test Case 1: FETCH_A
        valid = 1;
        #10;
        valid = 0;

       

        // End simulation
        #1300;
        $stop;
    end


endmodule
