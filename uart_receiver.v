`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2026 09:45:08
// Design Name: 
// Module Name: uart_receiver
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


module uart_receiver (
    input wire clk,          // 50 MHz Master clock
    input wire reset_n,      // Active-low reset
    input wire rx,           // Raw incoming serial line
    input wire tick,         // 16x oversampling tick (from baud generator)
    output reg [7:0] rx_data,// The completed 8-bit byte
    output reg rx_done       // High for 1 cycle when data is valid
);

    // FSM State Declarations 
    localparam STATE_IDLE  = 2'b00,
               STATE_START = 2'b01,
               STATE_DATA  = 2'b10,
               STATE_STOP  = 2'b11;

    // Internal Memory Registers
    reg [1:0] current_state;
    reg [3:0] tick_counter; // Counts 0 to 15 (tracks the 16 ticks per bit)
    reg [2:0] bit_counter;  // Counts 0 to 7 (tracks the 8 data bits)
    reg [7:0] shift_reg;    // Temporarily holds bits as they slide in
    
    // Synchronizer registers 
    reg rx_sync1, rx_sync2;

    // ---------------------------------------------------------
    // BLOCK 1: The Metastability Synchronizer 
    // ---------------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1; // Default UART idle state is '1'
        end else begin
            rx_sync1 <= rx;       
            rx_sync2 <= rx_sync1; 
        end
    end

    // ---------------------------------------------------------
    // BLOCK 2: The Main FSM & Data Path
    // ---------------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Wipe all memory on reset
            current_state <= STATE_IDLE;
            tick_counter  <= 4'd0;
            bit_counter   <= 3'd0;
            shift_reg     <= 8'd0;
            rx_data       <= 8'd0;
            rx_done       <= 1'b0;
        end else begin
            // Default output behavior: keep the flag down unless told otherwise
            rx_done <= 1'b0; 

            case (current_state)
                
                STATE_IDLE: begin
                    tick_counter <= 4'd0;
                    bit_counter  <= 3'd0;
                    if (rx_sync2 == 1'b0) begin 
                        // The line dropped to 0! Start bit detected.
                        current_state <= STATE_START;
                    end
                end

                STATE_START: begin
                    if (tick) begin // Only move when the 16x clock ticks
                        if (tick_counter == 4'd7) begin 
                            // Reached the exact middle of the Start Bit
                            tick_counter  <= 4'd0;       // Reset timer
                            current_state <= STATE_DATA; // Move to reading data
                        end else begin
                            tick_counter <= tick_counter + 4'd1;
                        end
                    end
                end

                STATE_DATA: begin
                    if (tick) begin
                        if (tick_counter == 4'd15) begin 
                            // Jumped exactly 1 bit-width forward into the middle of a data bit
                            tick_counter <= 4'd0;
                            // Shift the new bit into the highest slot, slide the rest down
                            shift_reg    <= {rx_sync2, shift_reg[7:1]}; 
                            
                            if (bit_counter == 3'd7) begin 
                                // We collected all 8 bits
                                current_state <= STATE_STOP;
                            end else begin
                                bit_counter <= bit_counter + 3'd1; // Next bit
                            end
                        end else begin
                            tick_counter <= tick_counter + 4'd1;
                        end
                    end
                end

                STATE_STOP: begin
                    if (tick) begin
                        if (tick_counter == 4'd15) begin 
                            // We are in the middle of the Stop Bit.
                            rx_data       <= shift_reg;  // Push the temp data to the main output
                            rx_done       <= 1'b1;       // Raise the success flag for 1 cycle!
                            current_state <= STATE_IDLE; // Go back to sleep
                        end else begin
                            tick_counter <= tick_counter + 4'd1;
                        end
                    end
                end

                default: current_state <= STATE_IDLE; // Safety catch
            endcase
        end
    end
endmodule