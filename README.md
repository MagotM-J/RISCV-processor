# RISC-V Single-Cycle Processor

A hardware implementation of a single-cycle RISC-V processor written in SystemVerilog, designed for Intel FPGA platforms (specifically the DE10-Lite development board).

## Overview

This project implements a 32-bit RISC-V processor following the single-cycle architecture. The processor supports a subset of the RV32I base integer instruction set and includes memory-mapped I/O for interfacing with FPGA peripherals such as LEDs, 7-segment displays, and switches.

## Features

- **Single-cycle execution**: Each instruction completes in one clock cycle
- **32-bit RISC-V architecture**: Implements core RV32I instructions
- **Memory-mapped I/O**: Interface with FPGA peripherals
- **Harvard architecture**: Separate instruction and data memories
- **Supported instructions**:
  - Load/Store: `lw`, `sw`
  - Arithmetic: `add`, `sub`, `addi`
  - Logical: `and`, `or`, `andi`, `ori`
  - Comparison: `slt`, `slti`
  - Branch: `beq`
  - Jump: `jal`

## Architecture

The processor follows a classic single-cycle datapath design with the following main components:

```
┌─────────────┐
│  Controller │ ← Instruction decoder
└─────────────┘
       ↓
┌─────────────┐
│  Datapath   │ ← Execution path
└─────────────┘
   ↓       ↓
┌─────┐ ┌─────┐
│ IMEM│ │ DMEM│ ← Memories
└─────┘ └─────┘
```

### Main Modules

- **`riscvsingle.sv`**: Top-level processor module integrating controller and datapath
- **`controller.sv`**: Instruction decoder generating control signals
- **`datapath.sv`**: Execution datapath with PC, register file, ALU, and muxes
- **`alu.sv`**: Arithmetic Logic Unit performing operations
- **`regfile.sv`**: 32×32-bit register file
- **`imem.sv`**: Instruction memory (ROM)
- **`dmem.sv`**: Data memory (RAM)
- **`maindec.sv`**: Main decoder for instruction opcodes
- **`aludec.sv`**: ALU decoder for function codes

### Helper Modules

Located in `helper_modules/`:
- **`adder.sv`**: 32-bit adder for PC calculations
- **`muxes.sv`**: 2:1 and 3:1 multiplexers
- **`flopr.sv`**: D flip-flop with reset for PC register
- **`extender.sv`**: Immediate value sign extension

## File Structure

```
.
├── riscvsingle.sv           # Top-level processor
├── controller.sv            # Control unit
├── datapath.sv             # Datapath unit
├── alu.sv                  # ALU
├── regfile.sv              # Register file
├── imem.sv                 # Instruction memory
├── dmem.sv                 # Data memory
├── maindec.sv              # Main decoder
├── aludec.sv               # ALU decoder
├── helper_modules/         # Supporting modules
│   ├── adder.sv
│   ├── muxes.sv
│   ├── flopr.sv
│   └── extender.sv
├── top.sv                  # System top-level with I/O
├── cpu_top.sv              # FPGA board interface
├── testbench.sv            # Simulation testbench
├── mem_init/               # Memory initialization files
│   ├── imem.txt            # Instruction memory (hex)
│   └── dmem.txt            # Data memory (hex)
├── single-cycle-processor.qpf  # Quartus project file
├── cpu_top.qsf             # Quartus settings file
└── devkits/                # FPGA board support files
```

## Memory-Mapped I/O

The processor includes memory-mapped I/O at the following addresses:

| Address      | Device          | Access |
|--------------|-----------------|--------|
| 0xFF200000   | LEDR (10 LEDs)  | Write  |
| 0xFF200020   | HEX3-HEX0       | Write  |
| 0xFF200030   | HEX5-HEX4       | Write  |
| 0xFF200040   | SW (10 switches)| Read   |

## Getting Started

### Prerequisites

- **Intel Quartus Prime** (for FPGA synthesis)
- **ModelSim** or **Quartus Simulator** (for functional simulation)
- **DE10-Lite FPGA Board** (for hardware deployment)

### Simulation

1. Open your SystemVerilog simulator (ModelSim/QuestaSim)
2. Compile all `.sv` files in the project
3. Load the testbench: `testbench.sv`
4. Initialize memories from `mem_init/` directory
5. Run the simulation
6. The testbench will output "Simulation succeeded" if the test passes

Example with ModelSim:
```bash
# Compile all files
vlog *.sv helper_modules/*.sv

# Run simulation
vsim -c testbench -do "run -all"
```

### FPGA Synthesis (Intel DE10-Lite)

1. Open **Intel Quartus Prime**
2. Open the project file: `single-cycle-processor.qpf`
3. Set `cpu_top.sv` as the top-level entity
4. Configure pin assignments:
   - Use the provided `cpu_top.qsf` settings file
   - Or refer to `devkits/` directory for board-specific setup files
5. Compile the design (Processing → Start Compilation)
6. Program the FPGA (Tools → Programmer)

### Testing on Hardware

1. **Reset**: Press KEY[0] to reset the processor
2. **Input**: Use SW[9:0] switches to provide input data
3. **Output**: 
   - LEDR[9:0] shows output on LEDs
   - HEX0-HEX5 display values on 7-segment displays
4. **Clock**: Uses the 50 MHz onboard clock (MAX10_CLK1_50)

## Instruction Memory Format

Instructions are stored in hexadecimal format in `mem_init/imem.txt`. Each line represents a 32-bit instruction in little-endian format.

Example program (from `imem.txt`):
```
08002283    # lw x5, 128(x0)    ; Load from address 128
0402A303    # lw x6, 64(x5)     ; Load from address (x5+64)
0062A023    # sw x6, 0(x5)      ; Store to address x5
0262A023    # sw x6, 32(x5)     ; Store to address (x5+32)
0262A823    # sw x6, 48(x5)     ; Store to address (x5+48)
FF1FF06F    # jal x0, -16       ; Jump back (infinite loop)
FF200000    # Data value at address 128
```

## Test Program

The included testbench (`testbench.sv`) verifies the processor by:
1. Loading a test program from `imem.txt`
2. Executing instructions
3. Checking if the value `25` (decimal) is written to memory address `100` (decimal)
4. Reporting "Simulation succeeded" if the test passes, or "Simulation failed" otherwise

## Customization

### Adding New Instructions

1. Update `maindec.sv` to decode the new opcode
2. Modify `aludec.sv` if new ALU operations are needed
3. Add ALU functionality in `alu.sv`
4. Update control signals in `controller.sv`

### Memory Size

- Instruction memory: 64 words (256 bytes) - modify array size in `imem.sv`
- Data memory: 64 words (256 bytes) - modify array size in `dmem.sv`

## Technical Specifications

- **Word size**: 32 bits
- **Register file**: 32 registers (x0-x31), x0 hardwired to 0
- **Program counter**: 32 bits
- **Memory addressing**: Word-aligned (byte addresses [31:2])
- **Clock frequency**: Up to 50 MHz (board dependent)

## License

This project is provided as-is for educational purposes.

## References

- RISC-V Instruction Set Manual: https://riscv.org/specifications/
- Digital Design and Computer Architecture (RISC-V Edition) by Harris & Harris

## Author

MagotM-J

## Contributing

Contributions, issues, and feature requests are welcome!
