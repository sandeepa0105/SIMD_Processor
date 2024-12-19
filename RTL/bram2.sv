`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module bram2 #(
    parameter DATA_WIDTH = 128,
    parameter DEPTH = 256
) (
  input     logic                       clk,
  input     logic[$clog2(DEPTH)-1:0]    addr,
  input     logic[DATA_WIDTH-1:0]       data_in,
  input     logic                       we,
  input     logic                       re,
  output    logic[DATA_WIDTH-1:0]       data_out
);

  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  
  // initial begin
  //   mem[0] = {32'hA1, 32'hA2, 32'hA3, 32'hA4};
  //   mem[1] = {32'hA5, 32'hA6, 32'hA7, 32'hA8};
  //   mem[2] = {32'hA9, 32'hAA, 32'hAB, 32'hAC};
  //   mem[3] = {32'hAD, 32'hAE, 32'hAF, 32'hB0};

  // end
  initial begin
    mem[0] = {32'h1, 32'h2, 32'h3, 32'h4};
    mem[1] = {32'h5, 32'h6, 32'h7, 32'h8};
    mem[2] = {32'h9, 32'hA, 32'hB, 32'hC};
    mem[3] = {32'hD, 32'hE, 32'hF, 32'h10};
    mem[4] = {32'h11, 32'h12, 32'h13, 32'h14};
    mem[5] = {32'h15, 32'h16, 32'h17, 32'h18};
    mem[6] = {32'h19, 32'h1A, 32'h1B, 32'h1C};
    mem[7] = {32'h1D, 32'h1E, 32'h1F, 32'h20};
    mem[8] = {32'h21, 32'h22, 32'h23, 32'h24};
    mem[9] = {32'h25, 32'h26, 32'h27, 32'h28};
    mem[10] = {32'h29, 32'h2A, 32'h2B, 32'h2C};
    mem[11] = {32'h2D, 32'h2E, 32'h2F, 32'h30};
    mem[12] = {32'h31, 32'h32, 32'h33, 32'h34};
    mem[13] = {32'h35, 32'h36, 32'h37, 32'h38};
    mem[14] = {32'h39, 32'h3A, 32'h3B, 32'h3C};
    mem[15] = {32'h3D, 32'h3E, 32'h3F, 32'h40};
    
  end

  always @(posedge clk) begin
    if (we) begin
      mem[addr] <= data_in;
    end
    if (re) begin
      data_out <= mem[addr];
    end
  end

endmodule
