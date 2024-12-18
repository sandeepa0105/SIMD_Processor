`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module tb_bram;

    // Parameters
    parameter DATA_WIDTH = 128;
    parameter DEPTH = 256;

    // Signals
    logic clk;
    logic [$clog2(DEPTH)-1:0] addr;
    logic [DATA_WIDTH-1:0] data_in;
    logic we, re;
    logic [DATA_WIDTH-1:0] data_out;

    // Instantiate the BRAM
    bram #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .clk(clk),
        .addr(addr),
        .data_in(data_in),
        .we(we),
        .re(re),
        .data_out(data_out)
    );

    // Clock generation
    always #5 clk = ~clk; // 10 ns clock period

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        addr = 0;
        data_in = 0;
        we = 0;
        re = 0;

        // Wait for the clock stabilization
        #10;

        // Test Case 1: Write to memory
        addr = 8'h01; // Address to write
        data_in = 128'hA5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5; // Data to write
        we = 1; // Enable write
        re = 0; // Disable read
        #10; // Wait for clock edge

        we = 0; // Disable write

        // Test Case 2: Read from memory
        addr = 8'h01; // Same address
        re = 1; // Enable read
        #10; // Wait for clock edge

        // Check read data
        if (data_out !== 128'hA5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5) begin
            $display("Test Case 2 Failed: Expected %h, Got %h", 
                     128'hA5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5, data_out);
        end else begin
            $display("Test Case 2 Passed");
        end
        re = 0; // Disable read

        // Test Case 3: Write to a different address
        addr = 8'h02; // New address
        data_in = 128'h5A5A_5A5A_5A5A_5A5A_5A5A_5A5A_5A5A_5A5A; // New data
        we = 1; // Enable write
        #10; // Wait for clock edge

        we = 0; // Disable write

        // Test Case 4: Read from new address
        addr = 8'h02; // Same address
        re = 1; // Enable read
        #10; // Wait for clock edge

        // Check read data
        if (data_out !== 128'h5A5A_5A5A_5A5A_5A5A_5A5A_5A5A_5A5A_5A5A) begin
            $display("Test Case 4 Failed: Expected %h, Got %h", 
                     128'h5A5A_5A5A_5A5A_5A5A_5A5A_5A5A_5A5A_5A5A, data_out);
        end else begin
            $display("Test Case 4 Passed");
        end
        re = 0; // Disable read

        // Test Case 5: Read from an unwritten address
        addr = 8'h03; // Unwritten address
        re = 1; // Enable read
        #10; // Wait for clock edge

        // Check read data
        if (data_out !== 128'h0) begin
            $display("Test Case 5 Failed: Expected %h, Got %h", 128'h0, data_out);
        end else begin
            $display("Test Case 5 Passed");
        end

        // End of simulation
        $stop;
    end
endmodule
