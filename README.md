Synthesis-Ready UART Echo System (RTL Design)

A robust, synthesis-ready asynchronous serial communication system (UART Receiver & Transmitter) designed in Verilog. This project demonstrates core digital logic and VLSI design principles, culminating in a Top-Level Loopback (Echo) module that receives data from a host and instantly transmits it back.

🛠️ Tech Stack & Tools

Hardware Description Language: Verilog (IEEE 1364)

Synthesis & Simulation: AMD Xilinx Vivado ML Standard

Target Architecture: Xilinx Artix-7 (xc7a35tcpg236-1)

Core Concepts: RTL Design, Asynchronous Protocols, Finite State Machines (FSM), Metastability, Clock Domain Crossing.

🏗️ Hardware Architecture

The system is split into modular components to manage clock domains, safely capture incoming asynchronous data, process it synchronously, and drive serial outputs back to the host.

graph TD
    rx[Physical RX Pin] --> sync[2-Stage Synchronizer]
    sync --> u_rx[UART Receiver FSM]
    
    clk[50 MHz Master Clock] --> u_baud[Baud Rate Generator]
    u_baud -->|16x Oversampling Ticks| u_rx
    
    u_rx -->|8-bit Parallel Bus| u_tx[UART Transmitter]
    u_rx -->|rx_done Pulse| u_tx
    
    u_tx --> tx[Physical TX Pin]


1. The Baud Rate Generator (16x Oversampling)

To ensure highly accurate data sampling in an asynchronous environment, the receiver utilizes a clock divider generating a tick pulse at $16\times$ the target baud rate ($9600\text{ baud}$). This acts as a digital tape measure, anchoring the main FSM to the exact physical center of incoming bit widths to maximize noise immunity.

$$\text{Target Tick Frequency} = 9600\text{ baud} \times 16 = 153.6\text{ kHz}$$

$$\text{Counter Maximum Value} = \frac{50\text{ MHz}}{153.6\text{ kHz}} \approx 325.52 \rightarrow 326\text{ cycles}$$

Because counting starts at $0$, the internal register counts from $0$ up to $325$.

2. Metastability Synchronizer

Because the FPGA system clock and external UART transmitters operate on independent, asynchronous clock domains, incoming data is highly susceptible to timing violations. A 2-stage D-Flip-Flop synchronizer isolates the input, allowing unstable signals to safely settle into a valid logic state before entering the receiver's sequential logic paths.

3. The Receiver (Rx) FSM

Governed by a 4-state Finite State Machine (IDLE, START, DATA, STOP), the receiver samples the synchronized data line. Once a falling edge triggers the FSM out of IDLE, it uses the oversampling ticks to step into the exact midpoint of each bit-width, shifting the bits into an $8\text{-bit}$ register LSB-first.

4. The Transmitter (Tx)

The transmitter operates on a dedicated $1\times$ baud-rate divider counting up to $5208$ clock cycles per bit:

$$\text{Transmitter Counter Period} = \frac{50\text{ MHz}}{9600\text{ baud}} \approx 5208.33 \rightarrow 5208\text{ cycles}$$

Upon receiving a tx_start pulse, the transmitter FSM latches the parallel $8\text{-bit}$ data into a shift register, pulls the tx line low to assert a Start Bit, wiggles the serial output LSB-first, and concludes by asserting a high Stop Bit.

5. Top-Level Loopback (Echo) Module

The design is integrated by a top-level motherboard module (uart_top_echo). It binds the modules together by directly routing the receiver's output bus (rx_data) to the transmitter's input bus (tx_data), and wiring the receiver's valid-data flag (rx_done) directly to the transmitter's initiation trigger (tx_start). This creates a zero-latency hardware loopback.

🔬 Verification & Simulation

The design was functionally verified using a custom behavioral testbench (tb_uart_top_echo.v). The testbench simulates a host computer transmitting the character 'B' (ASCII 0x42 or 8'b01000010) to the FPGA's rx line, and monitors the tx line for the reflected response.

<img width="1038" height="601" alt="Screenshot 2026-07-12 095842" src="https://github.com/user-attachments/assets/c8d7e4bd-4080-4960-ba15-6d4b9221b5e4" />



Logic analyzer waveform verifying asynchronous RX frame capture and the immediate automatic TX echo output.

🧩 RTL Synthesis

The Verilog code was successfully synthesized into physical hardware structures using Xilinx Vivado, mapped cleanly to Look-Up Tables (LUTs) and Flip-Flops for the Artix-7 architecture with no unintended latches.

<img width="1263" height="580" alt="Screenshot 2026-07-12 100235" src="https://github.com/user-attachments/assets/7372aedf-5976-4ba4-ba49-248330c71985" />



Vivado Generated Synthesis Schematic outlining the structural mapping of the oversampling counters, synchronizer flip-flops, and FSM transition logic.

🚀 How to Run the Design in Vivado

Clone this repository.

Open Xilinx Vivado and select Create Project.

Add the files in /src (baud_rate_gen.v, uart_receiver.v, uart_transmitter.v, uart_top_echo.v) as Design Sources.

Add /sim/tb_uart_top_echo.v as a Simulation Source.

Right-click the testbench inside Vivado and select Set as Top.

Click Run Simulation -> Run Behavioral Simulation.

Set simulation run time to 3.0 ms and analyze the waveform.
