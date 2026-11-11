# Experimental Results

## 1. FPGA Platform

- FPGA Board: Digilent Nexys A7-100T
- FPGA Device: xc7a100tcsg324-1
- Development Tool: AMD Vivado 2024.1
- Reconfiguration Method: Dynamic Function eXchange (DFX) through USB-JTAG

## 2. Partial Reconfiguration Results

Three reconfigurable modules were implemented and tested:

- XOR transformation
- Bit rotation
- Additive checksum

The static heartbeat logic continued operating while partial bitstreams were loaded, demonstrating that the static region remained active during partial reconfiguration.

Measured JTAG partial reconfiguration time:

- Average reconfiguration time: approximately 252,479 microseconds (252.5 ms).

## 3. Bitstream Sizes

| Bitstream | Size |
|---|---:|
| Full configuration | 3,825,904 bytes |
| XOR partial | 353,769 bytes |
| Rotate partial | 353,769 bytes |
| Checksum partial | 353,769 bytes |

## 4. Resource Utilization

Post-placement resource utilization:

| Implementation | LUTs | Flip-Flops | Slices |
|---|---:|---:|---:|
| Conventional | 38 | 52 | 19 |
| DFX XOR | 10 | 36 | 13 |
| DFX Rotate | 19 | 36 | 19 |
| DFX Checksum | 11 | 36 | 11 |

The DFX implementation uses fewer LUTs and flip-flops at a time because only one reconfigurable function is active. However, the reserved partial reconfiguration region is significantly larger than the implemented logic. Therefore, these results do not establish an overall FPGA area reduction.

## 5. Power Estimates

Vivado estimated power consumption:

| Configuration | Total Power | Dynamic Power | Static Power |
|---|---:|---:|---:|
| DFX XOR | 0.110 W | 0.013 W | 0.097 W |
| DFX Rotate | 0.111 W | 0.014 W | 0.097 W |
| DFX Checksum | 0.115 W | 0.018 W | 0.097 W |
| Conventional | 0.116 W | 0.019 W | 0.097 W |

These are Vivado estimates with low confidence, not physical power measurements. Reconfiguration energy was not measured.

## 6. Functional Verification

- Four simulation testbenches were used.
- Exhaustive data/key sweeps covered 65,536 combinations for each reconfigurable module.
- The top-level design was also simulated.
- All four simulations passed.
- All three partial bitstreams were successfully loaded onto the physical FPGA board.
- Static heartbeat operation was maintained during partial reconfiguration.

## 7. Conclusion

The project successfully demonstrates Dynamic Function eXchange on the Nexys A7-100T FPGA using three interchangeable lightweight data transformation modules. Functional simulations and hardware testing verified the partial reconfiguration workflow. The measurements also highlight the importance of considering reserved reconfigurable-region resources when evaluating the practical area benefits of DFX.
