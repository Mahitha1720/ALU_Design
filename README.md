# Parameterized ALU – Design & Verification

## Project Overview

This project implements and verifies a **Parameterized Arithmetic Logic Unit (ALU)** using synthesizable Verilog RTL.
The ALU supports multiple arithmetic and logical operations and is fully parameterized by operand width.

The verification environment includes:

* Self-checking testbench
* Independent reference model
* Functional coverage collection
* HTML coverage report generation using QuestaSim

---

# Features

## Arithmetic Operations

* ADD
* SUB
* ADD with Carry
* SUB with Carry
* Increment / Decrement
* Compare
* Multiply operations
* Signed ADD / SUB

## Logical Operations

* AND / NAND
* OR / NOR
* XOR / XNOR
* NOT
* Shift Left / Right
* Rotate Left / Right

## Additional Features

* Parameterized operand width
* Multi-cycle pipeline support
* Clock Enable (CE)
* Synchronous Reset
* Input validity checking
* Error flag handling
* Self-checking verification flow

---

# Directory Structure

```text
project_verification/
│
├── alu.v                     # DUT RTL Design
├── alu_ref_model.v           # Reference Model
├── tb_design.v               # Self-checking Testbench
│
├── alu_coverage.ucdb         # Coverage database
├── compile.log               # Compilation log
├── sim.log                   # Simulation log
│
├── covReport/                # HTML Coverage Report
│   ├── index.html
│   └── ...
│
└── README.md
```

---

# Tools Used

| Tool           | Version | Purpose           |
| -------------- | ------- | ----------------- |
| QuestaSim vlog | 10.6c   | RTL Compilation   |
| QuestaSim vsim | 10.6c   | Simulation        |
| vcover         | 10.6c   | Coverage Analysis |

---

# Compilation & Simulation

## Setup Environment

```bash
source /home/share/questa.csh
```

## Compile Design

```bash
vlog +acc +cover -l compile.log alu.v alu_ref_model.v tb_design.v
```

## Run Simulation

```bash
vsim work.tb_design -l sim.log -coverage -c -do "coverage save -onexit -codeAll alu_coverage.ucdb; run -all; exit"
```

## Generate HTML Coverage Report

```bash
vcover report -html alu_coverage.ucdb -htmldir covReport -details
```

---

# Design Architecture

## Inputs

| Signal    | Description                 |
| --------- | --------------------------- |
| OPA       | Operand A                   |
| OPB       | Operand B                   |
| cin       | Carry input                 |
| clk       | System clock                |
| rst       | Synchronous reset           |
| ce        | Clock enable                |
| mode      | Arithmetic / Logical select |
| inp_valid | Input validity              |
| cmd       | Operation select            |

---

## Outputs

| Signal | Description       |
| ------ | ----------------- |
| res    | Operation result  |
| cout   | Carry-out         |
| oflow  | Overflow flag     |
| G      | Greater-than flag |
| E      | Equal flag        |
| L      | Less-than flag    |
| err    | Error flag        |

---

# Pipeline Behaviour

The ALU uses a multi-cycle pipeline architecture.

| Stage     | Description          |
| --------- | -------------------- |
| Count = 0 | Input Register Phase |
| Count = 1 | Operation Execution  |
| Count = 2 | Multiply Completion  |

Multiply operations require 3 clock cycles.
All other operations require 2 clock cycles.

---

# Verification Methodology

The verification environment is fully self-checking.

## Verification Components

* DUT Instantiation
* Reference Model
* Output Comparator
* Directed Testcases
* Functional Coverage

## Verification Features

* Cycle-by-cycle comparison
* Error reporting
* Boundary testing
* Overflow testing
* Invalid input testing
* CE disable testing

---

# Coverage Summary

| Coverage Type   | Bins | Hits | Misses |   % Hit | Coverage % |
| --------------- | ---: | ---: | -----: | ------: | ---------: |
| Statements      |  437 |  428 |      9 |  97.94% |     97.94% |
| Branches        |  182 |  170 |     12 |  93.40% |     93.40% |
| FEC Expressions |   25 |   13 |     12 |  52.00% |     52.00% |
| FEC Conditions  |   14 |   10 |      4 |  71.42% |     71.42% |
| Toggles         |  486 |  306 |    180 |  62.96% |     62.96% |
| FSMs            |    8 |    8 |      0 | 100.00% |    100.00% |
| FSM States      |    3 |    3 |      0 | 100.00% |    100.00% |
| FSM Transitions |    5 |    5 |      0 | 100.00% |    100.00% |
| TOTAL           |    – |    – |      – |  81.16% |     79.62% |

---

# Coverage Observations

* Statement coverage reached **97.94%**
* FSM coverage achieved **100%**
* Branch coverage achieved **93.40%**
* Toggle coverage is limited due to unused upper bits at `W=4`
* FEC coverage gaps are mainly caused by complex signed overflow conditions

---

# Issues Fixed During Verification

* Module naming mismatches
* Parameter naming inconsistencies
* Reference model integration issues
* Stale library compilation problems
* Incorrect simulation module references

---

# Sample Testcases

| Test Name           | Result |
| ------------------- | ------ |
| ADD_Normal_case     | PASS   |
| SUB_overflow        | PASS   |
| ADD_CIN_Normal_case | PASS   |
| CMP_greater         | PASS   |
| CMD9_Normal_case    | PASS   |
| ROL_A_B_rotate1     | PASS   |
| ADD_CE_disabled     | PASS   |

---

# Future Improvements

* Add constrained-random verification
* Implement SystemVerilog Assertions (SVA)
* Extend parameter width to 8-bit and 16-bit
* Develop UVM-based environment
* Add formal verification
* Improve toggle coverage

---

# Author

**Mahitha M**
Employee ID: 6906

---

# Conclusion

The parameterized ALU was successfully verified using a self-checking verification environment with a reference model.
The project achieved high statement and branch coverage while validating arithmetic, logical, pipeline, reset, CE, and error handling functionality across multiple scenarios.

