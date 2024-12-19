`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//instruction memory
module bram1 #(
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
  
  // initial begin       //addition
  //   mem[0] = 12'h000;
  //   mem[1] = 12'h009;   //address 0
  //   mem[2] = 12'h00A;
  //   mem[3] = 12'h001;
  //   mem[4] = 12'h005;
  //   mem[5] = 12'h007;
  //   mem[6] = 12'h019;     //address 1
  //   mem[7] = 12'h01A;
  //   mem[8] = 12'h001;
  //   mem[9] = 12'h005;
  //   mem[10] = 12'h017;
  //   mem[11] = 12'h029;    //address 2
  //   mem[12] = 12'h02A;
  //   mem[13] = 12'h001;
  //   mem[14] = 12'h005;
  //   mem[15] = 12'h027;
  //   mem[16] = 12'h039;    //address 3
  //   mem[17] = 12'h03A;
  //   mem[18] = 12'h001;
  //   mem[19] = 12'h005;
  //   mem[20] = 12'h037;
  //   mem[21] = 12'h049;    //address 4
  //   mem[22] = 12'h04A;
  //   mem[23] = 12'h001;
  //   mem[24] = 12'h005;
  //   mem[25] = 12'h047;
  //   mem[26] = 12'h059;    //address 5
  //   mem[27] = 12'h05A;
  //   mem[28] = 12'h001;
  //   mem[29] = 12'h005;
  //   mem[30] = 12'h057;
  //   mem[31] = 12'h069;    //address 6
  //   mem[32] = 12'h06A;
  //   mem[33] = 12'h001;
  //   mem[34] = 12'h005;
  //   mem[35] = 12'h067;
  //   mem[36] = 12'h079;    //address 7
  //   mem[37] = 12'h07A;
  //   mem[38] = 12'h001;
  //   mem[39] = 12'h005;
  //   mem[40] = 12'h077;
  //   mem[41] = 12'h089;    //address 8
  //   mem[42] = 12'h08A;
  //   mem[43] = 12'h001;
  //   mem[44] = 12'h005;
  //   mem[45] = 12'h087;
  //   mem[46] = 12'h099;    //address 9
  //   mem[47] = 12'h09A;
  //   mem[48] = 12'h001;
  //   mem[49] = 12'h005;
  //   mem[50] = 12'h097;
  //   mem[51] = 12'h0A9;    //address 10
  //   mem[52] = 12'h0AA;
  //   mem[53] = 12'h001;
  //   mem[54] = 12'h005;
  //   mem[55] = 12'h0A7;
  //   mem[56] = 12'h0B9;    //address 11
  //   mem[57] = 12'h0BA;
  //   mem[58] = 12'h001;
  //   mem[59] = 12'h005;
  //   mem[60] = 12'h0B7;
  //   mem[61] = 12'h0C9;    //address 12
  //   mem[62] = 12'h0CA;
  //   mem[63] = 12'h001;
  //   mem[64] = 12'h005;
  //   mem[65] = 12'h0C7;
  //   mem[66] = 12'h0D9;    //address 13
  //   mem[67] = 12'h0DA;
  //   mem[68] = 12'h001;
  //   mem[69] = 12'h005;
  //   mem[70] = 12'h0D7;
  //   mem[71] = 12'h0E9;    //address 14
  //   mem[72] = 12'h0EA;
  //   mem[73] = 12'h001;
  //   mem[74] = 12'h005;
  //   mem[75] = 12'h0E7;
  //   mem[76] = 12'h0F9;    //address 15
  //   mem[77] = 12'h0FA;
  //   mem[78] = 12'h001;
  //   mem[79] = 12'h005;
  //   mem[80] = 12'h0F7;
  //   mem[81] = 12'h008;    //stop
    

  // end


  initial begin        //  Multiplication
    mem[0] = 12'h000;     //start
    mem[1] = 12'h009;     //0st address 0
    mem[2] = 12'h00A;
    mem[3] = 12'h003;
    mem[4] = 12'h019;
    mem[5] = 12'h01A;
    mem[6] = 12'h003;
    mem[7] = 12'h006;    
    mem[8] = 12'h009;      //1nd address 0
    mem[9] = 12'h02A;
    mem[10] = 12'h003;
    mem[11] = 12'h019;
    mem[12] = 12'h03A;
    mem[13] = 12'h003;
    mem[14] = 12'h006;
    mem[15] = 12'h009;      //2rd address 0
    mem[16] = 12'h04A;
    mem[17] = 12'h003;
    mem[18] = 12'h019;
    mem[19] = 12'h05A;
    mem[20] = 12'h003;
    mem[21] = 12'h006;
    mem[22] = 12'h009;      //3th address 0
    mem[23] = 12'h06A;
    mem[24] = 12'h003;
    mem[25] = 12'h019;
    mem[26] = 12'h07A;
    mem[27] = 12'h003;
    mem[28] = 12'h006;
    mem[29] = 12'h007;      //store result

    mem[30] = 12'h009;     //0st address 1
    mem[31] = 12'h08A;
    mem[32] = 12'h003;
    mem[33] = 12'h019;
    mem[34] = 12'h09A;
    mem[35] = 12'h003;
    mem[36] = 12'h006;    
    mem[37] = 12'h009;      //1nd address 1
    mem[38] = 12'h0AA;
    mem[39] = 12'h003;
    mem[40] = 12'h019;
    mem[41] = 12'h0BA;
    mem[42] = 12'h003;
    mem[43] = 12'h006;
    mem[44] = 12'h009;      //2rd address 1
    mem[45] = 12'h0CA;
    mem[46] = 12'h003;
    mem[47] = 12'h019;
    mem[48] = 12'h0DA;
    mem[49] = 12'h003;
    mem[50] = 12'h006;
    mem[51] = 12'h009;      //3th address 1
    mem[52] = 12'h0EA;
    mem[53] = 12'h003;
    mem[54] = 12'h019;
    mem[55] = 12'h0FA;
    mem[56] = 12'h003;
    mem[57] = 12'h006;
    mem[58] = 12'h017;      //store result

    mem[59] = 12'h008;     //STOP



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
