module program_counter #(
    parameter OPCODE_LEN = 4, // Length of the opcode field
    parameter PC_WIDTH = 12   // Width of the program counter
)(
    input  logic             clk,          // Clock signal
    input  logic             rstn,         // Active-low reset
    input  logic             valid,        // Valid signal to start instruction fetch
    input  logic [OPCODE_LEN-1:0] instruction, // Instruction input
    output logic [PC_WIDTH-1:0] pc    // Program counter output
);

    // Internal signals
//    logic [PC_WIDTH-1:0] pc;       // Program counter
    logic valid_hold;              // Hold valid status
    
    // Program Counter Routine
    always_ff @(posedge clk) begin
        if (!rstn) begin
            pc <= 0;              // Reset PC
            valid_hold <= 0;      // Clear valid_hold on reset
        end
        else begin
            if (valid_hold == 1) begin
                if (instruction[OPCODE_LEN-1:0] == 4'h8)begin // STOP Opcode assumed as 'hF
                    valid_hold <= 0; // STOP signal clears valid_hold
                    pc <= 0;   // Reset PC to 0
                end
                else begin
                    pc <= pc + 1; // Increment PC                           
                end
            end
            else begin
                if (valid == 1) begin
                    pc <= 0;         // Initialize PC
                    valid_hold <= 1; // Set valid_hold
                end
            end
        end
    end
    
    // Assign outputs
//    assign pc_out = pc;           // Program counter output

endmodule
