`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.07.2026 09:46:33
// Design Name: 
// Module Name: tb_uart_top_echo
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

module tb_uart_top_echo();

reg clk;
reg reset_n;
reg rx;
wire tx;

// Instantiate our entire motherboard!
uart_top_echo_m uut_system (
    .clk(clk),
    .reset_n(reset_n),
    .rx(rx),
    .tx(tx)
);

// Generate 50 MHz Master Clock
always #10 clk = ~clk;

initial begin
    // Initialize
    clk = 0;
    reset_n = 0;
    rx = 1;

    // Release reset
    #100;
    reset_n = 1;
    #1000;

    $display("Sending byte 0x42 (ASCII 'B') to FPGA...");
    
    // Let's send 0x42 (Binary: 01000010)
    // Remember UART sends LSB first: 0, 1, 0, 0, 0, 0, 1, 0
    
    rx = 0; #104167; // START Bit

    rx = 0; #104167; // Bit 0 (LSB)
    rx = 1; #104167; // Bit 1
    rx = 0; #104167; // Bit 2
    rx = 0; #104167; // Bit 3
    rx = 0; #104167; // Bit 4
    rx = 0; #104167; // Bit 5
    rx = 1; #104167; // Bit 6
    rx = 0; #104167; // Bit 7 (MSB)

    rx = 1; #104167; // STOP Bit

    $display("Byte sent! Waiting for FPGA to process and echo it back...");
    
    // Wait 1.5 milliseconds for the transmitter to send it back
    #1500000;
    
    $display("Echo simulation complete!");
    $finish;
end


endmodule