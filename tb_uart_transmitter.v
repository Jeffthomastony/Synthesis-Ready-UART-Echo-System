`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.07.2026 09:29:47
// Design Name: 
// Module Name: tb_uart_transmitter
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


`timescale 1ns / 1ps

module tb_uart_transmitter();

// 1. Inputs to module (driven by TB)
reg clk;
reg reset_n;
reg [7:0] tx_data;
reg tx_start;

// 2. Outputs from module
wire tx;
wire tx_active;
wire tx_done;

// 3. Instantiate the Transmitter
uart_transmitter_m uut_tx (
    .clk(clk),
    .reset_n(reset_n),
    .tx_data(tx_data),
    .tx_start(tx_start),
    .tx(tx),
    .tx_active(tx_active),
    .tx_done(tx_done)
);

// 4. Generate 50 MHz Clock (10ns flips)
always #10 clk = ~clk;

// 5. Test Sequence
initial begin
    // Initialize
    clk = 0;
    reset_n = 0;
    tx_data = 8'd0;
    tx_start = 0;

    // Release reset
    #100;
    reset_n = 1;
    #1000;

    // Load data to send (Hex: 0x55, Binary: 01010101)
    // This pattern looks like a square wave on the tx line!
    tx_data = 8'h55; 
    
    $display("Firing tx_start trigger...");
    // Pulse tx_start for exactly one clock cycle (20ns)
    tx_start = 1;
    #20;
    tx_start = 0;

    // Wait for the transmission to finish.
    // 10 bits * 104,167ns per bit = ~1,041,670ns
    // We will wait 1.2 million ns just to be safe.
    #1200000;

    $display("Simulation Complete!");
    $finish;
end


endmodule