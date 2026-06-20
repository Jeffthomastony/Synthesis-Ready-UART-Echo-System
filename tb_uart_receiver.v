`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2026 09:57:41
// Design Name: 
// Module Name: tb_uart_receiver
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


`timescale 1ns / 1ps  // Defines time units: 1 step = 1 nanosecond

module tb_uart_receiver();

    
    reg clk;
    reg reset_n;
    reg rx;

    wire [7:0] rx_data;
    wire rx_done;
    wire tick; // Internal wire connecting generator to receiver

    baud_rate_gen uut_baud (
        .clk(clk),
        .reset_n(reset_n),
        .tick(tick)
    );

    uart_receiver uut_rx (
        .clk(clk),
        .reset_n(reset_n),
        .rx(rx),
        .tick(tick),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // 50 MHz = 20 nanoseconds per cycle. Flip the clock every 10 ns.
    always #10 clk = ~clk;

    // Test Sequence (The Virtual Stimulus)
    initial begin
        // System Boot & Initialization
        clk = 0;
        reset_n = 0; // Hold the reset button down
        rx = 1;      // UART line sits HIGH when idle

        #100;        // Wait 100 
        reset_n = 1; 
        #1000;       
        
        
        // At 9600 baud, 1 single bit lasts for exactly 104,167 nanoseconds.
        
        $display("Transmitting Start Bit...");
        rx = 0;      
        #104167;     // Wait exactly 1 bit width

        $display("Transmitting Data Bits...");
        rx = 0; #104167; // Data Bit 0
        rx = 1; #104167; // Data Bit 1
        rx = 0; #104167; // Data Bit 2
        rx = 1; #104167; // Data Bit 3
        rx = 0; #104167; // Data Bit 4
        rx = 1; #104167; // Data Bit 5
        rx = 0; #104167; // Data Bit 6
        rx = 1; #104167; // Data Bit 7

        $display("Transmitting Stop Bit...");
        rx = 1;      // Drive line high for STOP BIT
        #104167;

        //Wait for the chip to process the stop bit and raise the 'rx_done' flag
        #200000;
        
        $display("Simulation Complete!");
        $finish; // Power off the virtual lab
    end

endmodule