`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2026 09:40:51
// Design Name: 
// Module Name: baud_rate_gen
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


module baud_rate_gen (
    input wire clk,      // 50 MHz Master clock input
    input wire reset_n,  // Active-low asynchronous reset
    output reg tick      // The 16x oversampling tick output
);

  
    reg [8:0] counter;

    // The Sequential Control Block
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
           
            counter <= 9'd0;
            tick    <= 1'b0;
        end else begin
            if (counter == 9'd325) begin
                counter <= 9'd0;  // Reset back to zero to loop again
                tick    <= 1'b1;  // Generate a pulse for ONE clock cycle
            end else begin
                counter <= counter + 9'd1; // Increment counter by 1
                tick    <= 1'b0;           // Keep tick low
            end
        end
    end

endmodule