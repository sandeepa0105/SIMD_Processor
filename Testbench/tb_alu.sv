`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module tb_alu;

    // Parameters
    parameter OPCODE_WIDTH = 4;
    parameter DATA_WIDTH = 32;

    // Signals
    logic clk;
    logic [31:0] a, b;
    logic [OPCODE_WIDTH-1:0] opcode_in;
    logic [31:0] out;

    // Instantiate the ALU
    alu #(
        .OPCODE_WIDTH(OPCODE_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk(clk),
        .a(a),
        .b(b),
        .opcode_in(opcode_in),
        .out(out)
    );

    // Clock generation
    always #5 clk = ~clk; // 10 ns clock period (100 MHz)


    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        a = 0;
        b = 0;
        opcode_in = 0;

        // Wait for reset propagation
        #110;

        // Test ADD operation
        a = 32'h00000010; // 16
        b = 32'h00000005; // 5
        opcode_in = 4'b0001; // ADD
        #10; // Wait for operation
  

        // Test SUB operation
        opcode_in = 4'b0010; // SUB
        #10; // Wait for operation
 

        // Test MUL operation
        opcode_in = 4'b0011; // MUL
        #10; // Wait for operation


        // Test DOTP operation
        opcode_in = 4'b0100; // DOTP
        #10; // Wait for operation
 

        // Test STORE_TEMP_S1 operation
        opcode_in = 4'b0101; // STORE_TEMP_S1
        #10; // Wait for operation


        // Test STORE_TEMP_S2 operation
        opcode_in = 4'b0110; // STORE_TEMP_S2
        #10; // Wait for operation


        // Test STORE_RESULT operation
        opcode_in = 4'b0111; // STORE_RESULT
        #10; // Wait for operation


        // Test NOOP operation
        opcode_in = 4'b0000; // NOOP
        #10; // Wait for operation


        // Test STOP operation
        opcode_in = 4'b1000; // STOP
        #10; // Wait for operation


        // Finish simulation
        $stop;
    end
endmodule

