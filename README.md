# PDR-Based Reconfigurable Lightweight Data Security Engine on FPGA

## Overview

This project demonstrates Dynamic Function eXchange (DFX), also known as Partial Dynamic Reconfiguration (PDR), on an FPGA.

The design implements three interchangeable lightweight data transformation modules within a reconfigurable region:

- XOR transformation
- Bit rotation
- Additive checksum

Instead of implementing all three functions as separate active hardware blocks, the design uses a reconfigurable module that can be replaced by loading different partial bitstreams. The static logic remains operational during reconfiguration.

**Note:** These transformations demonstrate hardware reconfiguration and data processing. They are not intended to provide cryptographically secure encryption or authentication.

## Hardware and Software

- FPGA board: Digilent Nexys A7-100T
- FPGA device: xc7a100tcsg324-1
- Development environment: AMD Vivado 2024.1
- Reconfiguration interface: USB-JTAG
- Hardware description language: Verilog

## Architecture

The design consists of:

1. **Static region:** Contains the main control logic and heartbeat indicator.
2. **Reconfigurable region:** Hosts one of the three transformation modules.
3. **Partial bitstreams:** Allow the reconfigurable module to be changed without reconfiguring the entire FPGA.

The static heartbeat continues operating while partial bitstreams are loaded, demonstrating that the static region remains active during reconfiguration.

## Implemented Modules

| Module | Function |
|---|---|
| XOR | Performs bitwise XOR transformation |
| Rotate | Performs bit rotation |
| Checksum | Computes an additive checksum |

## Verification

The project was verified through simulation and physical FPGA testing.

- Four simulation testbenches were used.
- Each reconfigurable module underwent exhaustive testing across 65,536 data/key combinations.
- The top-level design was simulated.
- All four simulations passed.
- All three partial bitstreams were successfully loaded onto the physical Nexys A7-100T board.
- Static heartbeat operation was observed during partial reconfiguration.

## Experimental Results

The measured average JTAG partial reconfiguration time was approximately **252.5 ms**.

The generated bitstream sizes were:

| Bitstream | Size |
|---|---:|
| Full configuration | 3,825,904 bytes |
| XOR partial | 353,769 bytes |
| Rotate partial | 353,769 bytes |
| Checksum partial | 353,769 bytes |

Post-placement resource utilization and Vivado power estimates are documented in [`results/experimental_results.md`](results/experimental_results.md).

The reserved reconfigurable region is larger than the implemented modules. Therefore, the project demonstrates functional partial reconfiguration rather than claiming an overall FPGA area reduction.

Power figures are Vivado estimates with low confidence, not physical measurements. Reconfiguration energy was not measured.

## Repository Structure


PDR-Based-Reconfigurable-Security-Engine/
│
├── README.md
├── .gitignore
│
├── dfx_project/
│   ├── rtl/
│   │   ├── README.md
│   │   ├── security_engine_top.v
│   │   ├── rm_xor.v
│   │   ├── rm_rotate.v
│   │   └── rm_checksum.v
│   │
│   └── constraints/
│       ├── README.md
│       ├── pins.xdc
│       └── floorplan.xdc
│
├── conventional_project/
│   ├── rtl/
│   │   ├── README.md
│   │   └── security_engine_conv.v
│   │
│   └── constraints/
│       ├── README.md
│       └── pins.xdc
│
├── simulation/
│   ├── README.md
│   ├── tb_rm_xor.v
│   ├── tb_rm_rotate.v
│   ├── tb_rm_checksum.v
│   └── tb_security_engine_top.v
│
├── results/
│   └── experimental_results.md
│
└── docs/
    └── README.md

Release assets (tag: v1.0):
    ├── full_xor.bit
    ├── part_xor.bit
    ├── part_rotate.bit
    └── part_checksum.bit


## Opening the Project

1. Install AMD Vivado.
2. Open `dfx_project/pdr.xpr` to inspect the DFX implementation.
3. Open `conventional_project/conv.xpr` to inspect the conventional implementation.
4. Review the simulation testbenches in the `simulation/` directory.
5. Refer to `results/experimental_results.md` for the recorded measurements.

The project was developed and tested using Vivado 2024.1 and the Digilent Nexys A7-100T board.

## Limitations

- The project demonstrates lightweight data transformations, not secure cryptographic encryption.
- The reserved reconfigurable region has more resources than the implemented modules require.
- Power values are tool-generated estimates rather than physical measurements.
- Reconfiguration energy was not measured.

## Acknowledgements

The FPGA development platform used in this project is the Digilent Nexys A7-100T. Pin assignments are based on the official Digilent Nexys A7 master constraints file.
