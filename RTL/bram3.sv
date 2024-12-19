`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module bram3 #(
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
  //   mem[0] = {32'hB1, 32'hB2, 32'hB3, 32'hB4};
  //   mem[1] = {32'hB5, 32'hB6, 32'hB7, 32'hB8};
  //   mem[2] = {32'hB9, 32'hBA, 32'hBB, 32'hBC};
  //   mem[3] = {32'hBD, 32'hBE, 32'hBF, 32'hC0};

  // end
  initial begin    //TRANSPOSED
    mem[0] = {32'h1, 32'h9, 32'h11, 32'h19};
    mem[1] = {32'h21, 32'h29, 32'h31, 32'h39};
    mem[2] = {32'h2, 32'hA, 32'h12, 32'h1A};
    mem[3] = {32'h22, 32'h2A, 32'h32, 32'h3A};
    mem[4] = {32'h3, 32'hB, 32'h13, 32'h1B};
    mem[5] = {32'h23, 32'h2B, 32'h33, 32'h3B};
    mem[6] = {32'h4, 32'hC, 32'h14, 32'h1C};
    mem[7] = {32'h24, 32'h2C, 32'h34, 32'h3C};
    mem[8] = {32'h5, 32'hD, 32'h15, 32'h1D};
    mem[9] = {32'h25, 32'h2D, 32'h35, 32'h3D};
    mem[10] = {32'h6, 32'hE, 32'h16, 32'h1E};
    mem[11] = {32'h26, 32'h2E, 32'h36, 32'h3E};
    mem[12] = {32'h7, 32'hF, 32'h17, 32'h1F};
    mem[13] = {32'h27, 32'h2F, 32'h37, 32'h3F};
    mem[14] = {32'h8, 32'h10, 32'h18, 32'h20};
    mem[15] = {32'h28, 32'h30, 32'h38, 32'h40};
  end

  // initial begin           //Normal
  //   mem[0] = {32'h1, 32'h2, 32'h3, 32'h4};
  //   mem[1] = {32'h5, 32'h6, 32'h7, 32'h8};
  //   mem[2] = {32'h9, 32'hA, 32'hB, 32'hC};
  //   mem[3] = {32'hD, 32'hE, 32'hF, 32'h10};
  //   mem[4] = {32'h11, 32'h12, 32'h13, 32'h14};
  //   mem[5] = {32'h15, 32'h16, 32'h17, 32'h18};
  //   mem[6] = {32'h19, 32'h1A, 32'h1B, 32'h1C};
  //   mem[7] = {32'h1D, 32'h1E, 32'h1F, 32'h20};
  //   mem[8] = {32'h21, 32'h22, 32'h23, 32'h24};
  //   mem[9] = {32'h25, 32'h26, 32'h27, 32'h28};
  //   mem[10] = {32'h29, 32'h2A, 32'h2B, 32'h2C};
  //   mem[11] = {32'h2D, 32'h2E, 32'h2F, 32'h30};
  //   mem[12] = {32'h31, 32'h32, 32'h33, 32'h34};
  //   mem[13] = {32'h35, 32'h36, 32'h37, 32'h38};
  //   mem[14] = {32'h39, 32'h3A, 32'h3B, 32'h3C};
  //   mem[15] = {32'h3D, 32'h3E, 32'h3F, 32'h40};
    
  // end

  always @(posedge clk) begin
    if (we) begin
      mem[addr] <= data_in;
    end
    if (re) begin
      data_out <= mem[addr];
    end
  end

endmodule
