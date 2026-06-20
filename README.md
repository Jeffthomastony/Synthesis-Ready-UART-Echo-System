# Synthesis-Ready UART Receiver (RTL Design)

A robust, synthesis-ready asynchronous serial receiver (UART) designed in Verilog. This project demonstrates core digital logic and VLSI design principles, including metastability mitigation, 
finite state machine (FSM) architecture, and nanosecond-level timing verification.

## 🛠️ Tech Stack & Tools
* **Hardware Description Language:** Verilog (IEEE 1364)
* **Synthesis & Simulation:** AMD Xilinx Vivado ML Standard
* **Target Architecture:** Xilinx Artix-7 (xc7a35tcpg236-1)
* **Core Concepts:** RTL Design, Asynchronous Protocols, Functional Verification

---

## 🏗️ Hardware Architecture

### 1. 16x Oversampling Baud Rate Generator
To ensure highly accurate data sampling in an asynchronous environment, this design utilizes a clock divider that generates a tick pulse at **16 times the target baud rate** (9600 baud). 
This acts as a digital tape measure, allowing the main FSM to anchor to the exact physical center of the incoming bit widths, maximizing noise immunity.

### 2. Metastability Synchronizer
Because the FPGA system clock and the external UART transmitter operate on completely independent clock domains, incoming data is susceptible to timing violations. A **2-stage D-Flip-Flop synchronizer** was 
engineered at the input boundary to act as an isolation airlock, allowing asynchronous signals to safely settle into a valid logic state before entering the sequential logic paths.

### 3. FSM & Data Path Separation
The core receiver logic is governed by a 4-state Finite State Machine (`IDLE`, `START`, `DATA`, `STOP`). To guarantee a clean, latch-free silicon synthesis, the RTL is strictly separated into:
* **Sequential Memory Block:** Updates state registers synchronously on the master clock edge.
* **Combinational Logic Block:** Evaluates current state and synchronizer inputs to route next-state paths and control the right-shifting data register.

---

## 🔬 Verification & Simulation

The design was functionally verified using a custom behavioral testbench (`tb_uart_receiver.v`). The testbench simulates a complete 10-bit asynchronous UART frame transfer (Start + 8 Data + Stop) with precise 
nanosecond delays calculated for 9600 baud. 

**Simulation Results:**
*(Insert your waveform screenshot here)*
![Simulation Waveform](docs/simulation_waveform.png)
> *Logic analyzer waveform demonstrating successful start-bit detection, 8-bit sequential shifting, and the single-cycle `rx_done` flag deployment.*

---

## 🧩 RTL Synthesis

The Verilog code was successfully synthesized into physical hardware structures using Xilinx Vivado, mapped to Look-Up Tables (LUTs) and Flip-Flops for the Artix-7 architecture.

*(Insert your schematic screenshot here)*
![RTL Schematic](docs/rtl_schematic.png)
> *Generated schematic detailing the synthesized physical gate-level routing and state registers.*

---

## 🚀 How to Run the Simulation
1. Clone this repository to your local machine.
2. Open Xilinx Vivado and create a new RTL project.
3. Add the files from the `/src` directory as **Design Sources**.
4. Add the file from the `/sim` directory as a **Simulation Source**.
5. In the Flow Navigator, click **Run Simulation** -> **Run Behavioral Simulation**.
6. Set simulation time to `1.5 ms` and click **Run All** to view the completed frame transfer.
