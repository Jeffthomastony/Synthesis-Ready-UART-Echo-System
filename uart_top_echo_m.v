`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.07.2026 09:45:41
// Design Name: 
// Module Name: uart_top_echo_m
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


module uart_top_echo_m (
input wire clk,       // 50 MHz Master Clock
input wire reset_n,   // Active-low reset
input wire rx,        // Incoming serial data from the computer
output wire tx        // Outgoing serial data back to the computer
);

// Internal wires acting as copper traces on our motherboard
wire tick_16x;             // Connects Baud Gen to Receiver
wire [7:0] internal_data;  // Connects Receiver data out to Transmitter data in
wire data_ready_pulse;     // Connects Receiver done flag to Transmitter start flag

// 1. Instantiate the Baud Rate Generator (for the Receiver)
baud_rate_gen uut_baud (
    .clk(clk),
    .reset_n(reset_n),
    .tick(tick_16x)
);

// 2. Instantiate the Receiver
uart_receiver uut_rx (
    .clk(clk),
    .reset_n(reset_n),
    .rx(rx),
    .tick(tick_16x),
    .rx_data(internal_data),    // Dumps received data onto internal bus
    .rx_done(data_ready_pulse)  // Fires 1-cycle pulse when data is valid
);

// 3. Instantiate the Transmitter
// (Using your exact module name: uart_transmitter_m)
uart_transmitter_m uut_tx (
    .clk(clk),
    .reset_n(reset_n),
    .tx_data(internal_data),    // Grabs data directly from the internal bus
    .tx_start(data_ready_pulse),// Triggers instantly when receiver finishes
    .tx(tx),                    // Drives the physical output pin
    .tx_active(),               // (Left disconnected, not needed for top level)
    .tx_done()                  // (Left disconnected, not needed for top level)
);


endmodule