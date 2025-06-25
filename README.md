# 8-Bit Microcomputer

## Project Description
This project involves the design, simulation, and implementation of a fully functional 8-bit microcomputer on a DE0-CV FPGA board. The system includes an 8-bit CPU, program memory, RAM, and 16×8-bit input/output ports. The computer is programmed in a pseudo-assembly language by manually encoding opcodes into ROM. Key goals were achieving reliable simulation in ModelSim and deploying a working hardware implementation via Quartus on the FPGA board.

## Development
### Part 1: Structural Shell & Simulation Setup
- Verified correct structural connectivity using ModelSim simulation with the following structure:
-`computer.vhd`
-   └ `cpu.vhd`
-        └ `control_unit.vhd`
-        └ `data_path.vhd`
-             └ `alu.vhd`
-   └ `memory.vhd`
-        └ `rom_128x8_sync.vhd`
-        └ `rw_96x8_sync.vhd`
- Submitted screenshots showing successful compilation and simulation transcript as confirmation.

### Part 2: Basic Instruction Simulation
- Implemented and simulated the following instructions:
  - `LDA_IMM` – Load immediate value into register A
  - `LDA_DIR` – Load register A from direct memory address
  - `STA_DIR` – Store register A to direct memory address
  - `BRA` – Branch unconditionally
- 

### Part 3: FPGA Implementation & Real-Time I/O
- Created `top.vhd` to instantiate the microcomputer and match DE0-CV board I/O.
- Used physical switches `SW[7:0]` as input and mapped output to:
  - Red LEDs (`LEDR[7:0]`)
  - Seven-segment displays (`HEX[5:0]`) via decoders
- Incorporated `clock_div_prec.vhd` for user-selected clock speeds (`SW[9:8]`).

### Part 4: Extended Instruction Sets
- Additional instructions optionally implemented for extra credit, including:
  - `LDB_IMM`, `LDB_DIR`, `STB_DIR`, `ADD_AB`, `AND_AB`, `OR_AB`, `INCA`, `INCB`, `DECA`, and `DECB`
- For each:
  - Custom state diagram created
  - ModelSim waveform captured
  - Program demonstrated on the FPGA board
- Materials submitted: diagrams, simulations, and updated VHDL files.  

## Getting Started
### Prerequisites
- DE0-CV FPGA Development Board
- ModelSim and Intel Quartus Prime (Lite Edition)

### Installation and Usage
1. Clone this repository and create a VHDL project in Quartus.
2. Compile all components starting from `top.vhd`.
3. Open programmer and run the project on the FPGA.
4. Set switches `SW[7:0]` to input values.
5. Observe outputs on LEDs and HEX displays.
6. Modify ROM content as needed for different program functionality.
7. For simulation, open `computer_TB.vhd` in ModelSim and run test programs by modifying ROM content.

## Acknowledgments
- This work was based on course materials provided by Brock LaMeres, EELE 367 Logic Design, Montana State Univeristy - Bozeman.
- Libraries/Tools: Uses the DE10-Lite FPGA Board with the MAX 10 10M50DAF484C7G Device, and all code is written in VHDL, simulated in ModelSim, and implemented in Quartus. Diagrams developed in Mirosoft Visio.
- Resources: "Introduction to Logic Circuits & Logic Design with VHDL" by Brock LaMeres.
