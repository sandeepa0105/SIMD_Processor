`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module program_counter_tb;

    // Parameters
    parameter OPCODE_LEN = 4;
    parameter PC_WIDTH   = 12;

    // Signals for testbench
    logic clk;
    logic rstn;
    logic valid;
    logic [OPCODE_LEN-1:0] instruction;
    logic [PC_WIDTH-1:0] pc_out;

    // Clock generation: 10ns clock period (100 MHz)
    always #5 clk = ~clk;

    // Instantiate the DUT (Device Under Test)
    program_counter #(
        .OPCODE_LEN(OPCODE_LEN),
        .PC_WIDTH(PC_WIDTH)
    ) uut (
        .clk(clk),
        .rstn(rstn),
        .valid(valid),
        .instruction(instruction),
        .pc(pc_out)
    );

    // Testbench stimulus
    initial begin
        // Initialize signals
        clk = 0;
        rstn = 0;
        valid = 0;
//        instruction = 0;
        
        #10 rstn = 1;
        #10 valid = 1;
        #100;
        #10 instruction = 4'h8;
        #100;

       
       
        #50 $stop;
    end

   
endmodule

