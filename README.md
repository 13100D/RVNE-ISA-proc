# Original Paper as reference for ISA
link to paper: https://drive.google.com/file/d/1VMYV3cXyO_G3AZVhaBLsR6iTjDRyL2xS/view?usp=sharing


# RVNE-ISA-proc
Verilog model for a RISC-V extension ISA implementing instructions for neuromorphic workloads such as SNNs

# Description of the pipeline(sourced from the paper)

NeuroRVcore is implemented based on an open-source RISC-V core named RI5CY. The instruction pipeline of NeuroRVcore contains four stages, instruction fetching (IF), instruction decoding (ID), executing (EXE) and writing back (W B), and three buffer stacks, IF/ID, ID/EXE, and EXE/W B.

1) IF: The IF stage contains an instruction prefetch buffer, which is responsible for fetching and caching instructions from the instruction cache, and a debugger that controls the debugging of the processor in debug mode through an external debug interface.

2) ID: The ID stage includes a decoder which is responsible for translating the register indexes and control signals stored in different fields of instructions and sending them to the register groups including general-purpose registers (GPR) and extended vector registers. It also contains multiple multiplexers that are used to choose indexes from different instruction fields. The organization of extended vector registers is introduced in

3) EXE: For general-purpose computation in RV32IMC, the EXE stage contains an LSU, which is responsible for
processing the request of storing and loading, an arithmetic logic unit (ALU) that performs general functions such as addition and subtraction, a multiply and division (MUL/DIV) unit that performs complex multiplication and division operations, a control state register (CSR) that is responsible for storing signals related to control, such as interrupts, exceptions, etc, multiple multiplexers that choose the source operands of computation, a controller used to judge whether to perform branch or execution in sequence.

For neuromorphic computing, the EXE stage consists of a neuron array composed of 1024 neuron units (NUs) which perform neuron computation according to the formula 1 in a multi-cycle way, a vector load store unit (VLSU) responsible for processing the requests of vector storing & loading and neuron/synapse-wise current accumulators to perform acceleration.

5) W B: The W B stage contains multiple multiplexers for selecting the results of the EXE stage or data read from memory to write back to specific registers and a ScratchPad Memory (SPM) that responds to storing requests and receives data transferred from LSU to store in the memory to achieve high memory bandwidth, balancing computing and irregular memory access.
