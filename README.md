# IITB RISC Processor
## Overview
A multi cycle implemenatation of a fully functional RISC based computer design, IITB RISC whose ISA is provided below. IITB RISC is a 8 - register, 16-bit architecture using multi-cycle implementation.
[Report](https://github.com/ShubhamBirange/iitb_risc/blob/main/docs/report.pdf)

<p align="center">
  <img src="https://github.com/ShubhamBirange/iitb_risc/blob/a92a6b550a3aa782b411398cfe322aa1c7a5f4e9/docs/isa.jpg?raw=true" alt="IITB RISC ISA" title="IITB RISC ISA" width="80%"/>
</p>
<p align="center">
    <em>IITB RISC ISA</em>
</p>

## Intoduction
In a multi-cycle implementation the instruction fetched is completely executed before the next instruction is fetched. The design implementation mainly consists of two parts a datapath and a controller. For this purpose a Level - 1 Hardware flow chart was designed which was later optimized in the Level - 2 Hardware flow chart. The data-path consists of the PC and IR registers, a ROM, a Register file with 8 registers, two temporary registers T1 and T2 and an ALU with adder, subtractor and nand operation. While the controller is a Mealy FSM optimized for 16 states.

<p align="center">
  <img src="https://github.com/ShubhamBirange/iitb_risc/blob/main/docs/datapath.jpg?raw=true" alt="Datapath" title="Datapath" width="80%"/>
</p>
<p align="center">
    <em>Datapath</em>
</p>

<p align="center">
  <img src="https://github.com/ShubhamBirange/iitb_risc/blob/main/docs/fsm.jpg?raw=true" alt="State Transition graph of the controller" title="State Transition graph of the controller" width="80%"/>
</p>
<p align="center">
    <em>State Transition graph of the controller</em>
</p>
