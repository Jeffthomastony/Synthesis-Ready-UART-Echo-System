`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.07.2026 09:32:40
// Design Name: 
// Module Name: uart_transmitter_m
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_transmitter_m (
input wire clk,          // 50 MHz Master Clock
input wire reset_n,      // Active-low reset
input wire [7:0] tx_data,// The 8-bit byte to send
input wire tx_start,     // Pulse to start transmission
output reg tx,           // The physical serial wire out
output reg tx_active,    // High while busy sending
output reg tx_done       // High for 1 cycle when finished
);

// FSM State Declarations
localparam STATE_IDLE  = 2'b00,
           STATE_START = 2'b01,
           STATE_DATA  = 2'b10,
           STATE_STOP  = 2'b11;

// Internal Registers
reg [1:0] current_state;
reg [12:0] baud_counter; // Counts 0 to 5207 (for 9600 baud)
reg [2:0] bit_counter;   // Counts 0 to 7 for data bits
reg [7:0] shift_reg;     // Holds the data being sent

// The single block for Clock Dividing and FSM Logic
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        current_state <= STATE_IDLE;
        baud_counter  <= 13'd0;
        bit_counter   <= 3'd0;
        shift_reg     <= 8'd0;
        tx            <= 1'b1; // Idle state for UART is HIGH
        tx_active     <= 1'b0;
        tx_done       <= 1'b0;
    end else begin
        tx_done <= 1'b0; // Default to 0 unless specifically raised

        case (current_state)
            
            STATE_IDLE: begin
                tx        <= 1'b1;
                tx_active <= 1'b0;
                baud_counter <= 13'd0;
                
                if (tx_start) begin
                    shift_reg     <= tx_data; // Latch the data in!
                    tx_active     <= 1'b1;
                    current_state <= STATE_START;
                end
            end

            STATE_START: begin
                tx <= 1'b0; // Pull line low for Start Bit
                
                if (baud_counter == 13'd5207) begin // Wait exactly 1 full bit width
                    baud_counter  <= 13'd0;
                    current_state <= STATE_DATA;
                end else begin
                    baud_counter <= baud_counter + 13'd1;
                end
            end

            STATE_DATA: begin
                tx <= shift_reg[0]; // Drive the lowest bit onto the wire (LSB first)

                if (baud_counter == 13'd5207) begin
                    baud_counter <= 13'd0;
                    shift_reg    <= {1'b0, shift_reg[7:1]}; // Shift data right

                    if (bit_counter == 3'd7) begin // Finished all 8 bits?
                        bit_counter   <= 3'd0;
                        current_state <= STATE_STOP;
                    end else begin
                        bit_counter <= bit_counter + 3'd1;
                    end
                end else begin
                    baud_counter <= baud_counter + 13'd1;
                end
            end

            STATE_STOP: begin
                tx <= 1'b1; // Drive line high for Stop Bit

                if (baud_counter == 13'd5207) begin
                    baud_counter  <= 13'd0;
                    tx_done       <= 1'b1; // Transmission complete pulse
                    current_state <= STATE_IDLE;
                end else begin
                    baud_counter <= baud_counter + 13'd1;
                end
            end

            default: current_state <= STATE_IDLE;
        endcase
    end
end


endmodule