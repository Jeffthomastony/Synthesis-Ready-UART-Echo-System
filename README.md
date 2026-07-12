**Synthesis-Ready UART Echo System (RTL Design)**

A robust, synthesis-ready asynchronous serial communication system (UART Receiver & Transmitter) designed in Verilog. This project demonstrates core digital logic and VLSI design principles, culminating in a Top-Level Loopback (Echo) module that receives data from a host and instantly transmits it back.
**
I. Tech Stack & Tools**

Hardware Description Language: Verilog (IEEE 1364)

Synthesis & Simulation: AMD Xilinx Vivado ML Standard

Target Architecture: Xilinx Artix-7 (xc7a35tcpg236-1)

Core Concepts: RTL Design, Asynchronous Protocols, Finite State Machines (FSM), Metastability, Clock Domain Crossing.
**
II. Hardware Architecture**
**
1. The Receiver (Rx) & 16x Oversampling**

To ensure highly accurate data sampling in an asynchronous environment, the receiver utilizes a clock divider generating a tick pulse at 16 times the target baud rate (9600 baud). This acts as a digital tape measure, anchoring the main FSM to the exact physical center of incoming bit widths to maximize noise immunity.

**2. Metastability Synchronizer**

Because the FPGA system clock and external UART transmitters operate on independent clock domains, incoming data is susceptible to timing violations. A 2-stage D-Flip-Flop synchronizer isolates the input, allowing asynchronous signals to safely settle into a valid logic state before entering the receiver's sequential logic paths.

**3. The Transmitter (Tx)
**
The transmitter reverses the process, utilizing a dedicated 1x baud rate generator. Upon receiving a tx_start pulse, the transmitter FSM latches the parallel 8-bit data into a shift register and sequentially drives the serial tx wire, appending protocol-accurate Start and Stop bits.

**4. Top-Level Loopback (Echo) Module
**
The system is bound together by a top-level module acting as the physical motherboard. It directly wires the receiver's rx_data output bus to the transmitter's tx_data input bus, and routes the rx_done flag directly into the tx_start trigger, creating a seamless, zero-latency hardware echo response.

**III. Verification & Simulation**

The design was functionally verified using custom behavioral testbenches. The final system was validated using tb_uart_top_echo.v, which injects a 10-bit asynchronous UART frame into the receiver and verifies the exact bit-pattern being echoed back out of the transmitter 1 millisecond later.

<img width="1038" height="601" alt="Screenshot 2026-07-12 095842" src="https://github.com/user-attachments/assets/8a4196f4-649f-4596-8081-370beab0b125" />
**
IV. RTL Synthesis**

The Verilog code was successfully synthesized into physical hardware structures using Xilinx Vivado, mapped cleanly to Look-Up Tables (LUTs) and Flip-Flops for the Artix-7 architecture with no unintended latches.

<img width="1263" height="580" alt="Screenshot 2026-07-12 100235" src="https://github.com/user-attachments/assets/a86bdd39-2aa3-4318-86c8-c8a29265c4b7" />
