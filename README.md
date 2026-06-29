# FSM Based Vending Machine
A 2-bit FSM-based vending machine implemented in Verilog HDL. Accepts 5 Rs and 10 Rs coins, dispenses a toffee at 15 Rs, and supports incremental 5 Rs refund. Built using D Flip-Flops with Boolean logic derived from K-maps. Simulated on Icarus Verilog and verified on Xilinx Vivado.

# ⚡FSM Based Vending Machine in Verilog

> A fully verified, synchronous Finite State Machine (FSM) based vending machine implemented in Verilog HDL. Accepts 5 Rs and 10 Rs coins, dispenses a toffee at 15 Rs, and supports incremental 5 Rs refund. Designed using D Flip-Flops with Boolean logic minimized from K-maps and verified against all 16 input-state combinations.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Machine Specification](#machine-specification)
- [States](#states)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [State Transition Table](#state-transition-table)
- [State Diagram](#state-diagram)
- [Boolean Equations](#boolean-equations)
- [How to Run](#how-to-run)
- [Simulation Output](#simulation-output)
- [Tools Used](#tools-used)
- [Design Methodology](#design-methodology)
- [Key Concepts](#key-concepts)
- [Design Notes](#design-notes)
- [Author](#author)

---

## 📌 Overview

This project implements a **Mealy/Moore hybrid FSM** based vending machine using Verilog HDL. The machine is designed to:

- Accept coins of **5 Rs** and **10 Rs** denominations
- Accumulate the inserted amount across clock cycles
- Dispense a **toffee worth 15 Rs** when sufficient amount is inserted
- Return **5 Rs change** if the user overpays (e.g. inserts 20 Rs)
- Support an **incremental refund** of 5 Rs per button press
- Allow the user to **continue inserting coins** for a second toffee after the first is dispensed

The design uses **2 D Flip-Flops** to store the 2-bit state, and all next-state and output logic is derived from **Karnaugh Map (K-map) minimization**.

The outputs `y` (dispense) and `R` (refund) are **registered** (clocked) to avoid combinational glitches and ensure they are aligned with the state update — one clock cycle after the triggering input.

---

## 📁 Project Structure

```
FiniteVend/
│
├── dff.v                    # D Flip-Flop module (building block)
├── vendingmachine.v         # Main FSM vending machine module
├── vendingmachine_tb.v      # Testbench for simulation
├── dump.vcd                 # VCD waveform file (generated after simulation)
├── state_diagram.png        # FSM state diagram image
├── io_wave.png              # Input/Output waveform screenshot from GTKWave/Vivado
├── schematic.png            # RTL schematic of the vending machine circuit
└── README.md                # Project documentation (this file)
```

---

## 🧾 Machine Specification

| Property | Value |
|----------|-------|
| Toffee Price | **15 Rs** |
| Accepted Coins | **5 Rs**, **10 Rs** |
| Refund | **5 Rs per press** |
| Number of States | **4** |
| State Bits | **2-bit (Q[1:0])** |
| Input Bits | **2-bit (x[1:0])** |
| Clock | **Synchronous (posedge)** |
| Reset | **Synchronous, active high** |
| Output Type | **Registered (clocked)** |

# ⚠️ Warning

Clicking the Reset button will permanently forfeit all accumulated money. The system will reinitialize, and your balance will return to 0 rupees (State S1). This action cannot be refunded.

---

## 🔵 States

The machine has **4 states** represented by a 2-bit register `Q[1:0]`:

| State | Q[1:0] | Meaning |
|-------|--------|---------|
| S0 | `00` | 0 Rs accumulated — idle state |
| S1 | `01` | 5 Rs accumulated |
| S2 | `10` | 10 Rs accumulated |
| S3 | `11` | 15 Rs reached — toffee has been dispensed |

### State Encoding Explained:
- **S0 (00):** The machine is idle. No money has been inserted yet. The machine waits for a coin input.
- **S1 (01):** The user has inserted 5 Rs. The machine is waiting for more coins to reach 15 Rs.
- **S2 (10):** The user has inserted 10 Rs total. One more 5 Rs coin will dispense the toffee.
- **S3 (11):** 15 Rs has been reached and toffee is dispensed. The machine stays here until the next coin is inserted for a second toffee or refund is pressed.

---

## 🎮 Inputs

The machine takes a **2-bit input `x[1:0]`** at every clock cycle:

| x[1:0] | Meaning | Description |
|--------|---------|-------------|
| `00` | No coin | Machine stays in current state |
| `01` | Insert 5 Rs | Adds 5 Rs to accumulated amount |
| `10` | Insert 10 Rs | Adds 10 Rs to accumulated amount |
| `11` | Refund button | Returns 5 Rs and moves back one state |

### Input Details:
- **x=00 (No coin):** The machine does nothing. State remains unchanged. No output.
- **x=01 (5 Rs):** Adds 5 Rs to the current accumulated amount and transitions to the next state.
- **x=10 (10 Rs):** Adds 10 Rs to the current accumulated amount. If the total reaches or exceeds 15 Rs, the toffee is dispensed.
- **x=11 (Refund):** Returns 5 Rs to the user. The machine moves back one state. Special cases:
  - Refund at S0 (0 Rs): No money to return, stays at S0.
  - Refund at S3 (15 Rs): No money returned (toffee already dispensed), goes to S0.

---

## 📤 Outputs

| Output | Type | Meaning |
|--------|------|---------|
| `y` | reg (clocked) | `1` = Toffee dispensed |
| `R` | reg (clocked) | `1` = 5 Rs refunded to user |

### Output Details:
- **y (Dispense):** Goes HIGH for one clock cycle when the accumulated amount reaches 15 Rs. This happens when:
  - State S1 + input 10 Rs (5+10=15)
  - State S2 + input 5 Rs  (10+5=15)
  - State S2 + input 10 Rs (10+10=20, overpay — still dispenses)
- **R (Refund):** Goes HIGH for one clock cycle when 5 Rs is returned. This happens when:
  - Refund pressed at S1 (5 Rs returned, go to S0)
  - Refund pressed at S2 (5 Rs returned, go to S1)
  - Overpay: 10+10=20 Rs (5 Rs change returned automatically)

### Why Registered Outputs?
The outputs `y` and `R` are registered (clocked through a flip-flop) to:
1. **Prevent glitches** from combinational logic transitions
2. **Align timing** with state updates — both state and output change on the same clock edge
3. **Ensure clean pulses** exactly one clock cycle wide

---

## 📊 State Transition Table

This is the complete **16-row truth table** covering all combinations of current state `Q[1:0]` and input `x[1:0]`:

| Row | Q1 | Q0 | x1 | x0 | D1 | D0 | y | R | Next State | Meaning |
|-----|----|----|----|----|----|-----|---|---|------------|---------|
| 0   | 0  | 0  | 0  | 0  | 0  | 0   | 0 | 0 | S0 (00)    | At 0 Rs, no coin → stay |
| 1   | 0  | 0  | 0  | 1  | 0  | 1   | 0 | 0 | S1 (01)    | 0 + 5 = 5 Rs |
| 2   | 0  | 0  | 1  | 0  | 1  | 0   | 0 | 0 | S2 (10)    | 0 + 10 = 10 Rs |
| 3   | 0  | 0  | 1  | 1  | 0  | 0   | 0 | 0 | S0 (00)    | Refund at 0 Rs → no effect |
| 4   | 0  | 1  | 0  | 0  | 0  | 1   | 0 | 0 | S1 (01)    | At 5 Rs, no coin → stay |
| 5   | 0  | 1  | 0  | 1  | 1  | 0   | 0 | 0 | S2 (10)    | 5 + 5 = 10 Rs |
| 6   | 0  | 1  | 1  | 0  | 1  | 1   | 1 | 0 | S3 (11)    | 5 + 10 = 15 Rs → Dispense! |
| 7   | 0  | 1  | 1  | 1  | 0  | 0   | 0 | 1 | S0 (00)    | Refund at 5 Rs → return 5 Rs |
| 8   | 1  | 0  | 0  | 0  | 1  | 0   | 0 | 0 | S2 (10)    | At 10 Rs, no coin → stay |
| 9   | 1  | 0  | 0  | 1  | 1  | 1   | 1 | 0 | S3 (11)    | 10 + 5 = 15 Rs → Dispense! |
| 10  | 1  | 0  | 1  | 0  | 0  | 0   | 1 | 1 | S0 (00)    | 10 + 10 = 20 Rs → Dispense + Return 5 Rs |
| 11  | 1  | 0  | 1  | 1  | 0  | 1   | 0 | 1 | S1 (01)    | Refund at 10 Rs → return 5 Rs, go to 5 Rs |
| 12  | 1  | 1  | 0  | 0  | 1  | 1   | 0 | 0 | S3 (11)    | At 15 Rs, no coin → stay |
| 13  | 1  | 1  | 0  | 1  | 0  | 1   | 0 | 0 | S1 (01)    | At 15 Rs, insert 5 Rs for 2nd toffee |
| 14  | 1  | 1  | 1  | 0  | 1  | 0   | 0 | 0 | S2 (10)    | At 15 Rs, insert 10 Rs for 2nd toffee |
| 15  | 1  | 1  | 1  | 1  | 0  | 0   | 0 | 0 | S0 (00)    | Refund at 15 Rs → go to S0, no money back |

> **Note:** D1 and D0 are the next-state inputs to the D Flip-Flops. QB[0] = ~Q[0], QB[1] = ~Q[1].

---

## 🔄 State Diagram

> See `state_diagram.png` included in the repository for the full graphical state diagram showing all 4 states, transitions, and input/output labels.
> INPUT | OUTPUT | REFUND

---

## 📐 Boolean Equations

All equations are derived by **Karnaugh Map (K-map) minimization** from the 16-row truth table.

### Next State Logic:

**D1 (Next state bit 1):**
```
D1 = (Q1 & ~x1 & (~Q0 | ~x0))
   | (~x0 & x1 & (~Q1 | Q0))
   | (~x1 & x0 & ~Q1 & Q0)
```

**D0 (Next state bit 0):**
```
D0 = (~x1 & ~x0 & Q0)
   | (~Q1 & Q0 & ~x0)
   | (Q1 & Q0 & ~x1)
   | (Q1 & ~Q0 & x0)
   | (~x1 & x0 & (Q1 | ~Q0))
```

### Output Logic (combinational, then registered):

**y (Dispense):**
```
y = (x1 & ~x0 & (Q1 ^ Q0))
  | (Q1 & ~Q0 & (x1 ^ x0))
```

**R (Refund):**
```
R = x1 & ((Q1 & ~Q0) | (x0 & ~Q1 & Q0))
```

---

## ▶️ How to Run

### Prerequisites
Make sure you have the following installed:
- **Icarus Verilog (iverilog)** — for compilation and simulation
- **GTKWave** — for waveform viewing
- **Vivado** (optional) — for synthesis and FPGA implementation

---

### Step 1 — Compile

```bash
iverilog -o vendingmachine_tb.out vendingmachine_tb.v vendingmachine.v Dff.v
```

> This compiles all three Verilog files and produces the output binary `vendingmachine_tb.out`

---

### Step 2 — Simulate

```bash
vvp vendingmachine_tb.out
```

> This runs the simulation. You will see the `$monitor` output printed in the terminal showing signal values at each timestep.

---

### Step 3 — View Waveform in GTKWave

```bash
gtkwave dump.vcd
```

> This opens the waveform viewer. In GTKWave:
> 1. Expand `vendingmachine_tb` in the SST panel on the left
> 2. Select signals: `clk`, `rst`, `x[1:0]`, `Q[1:0]`, `Qb[1:0]`, `y`, `R`
> 3. Click **Append** to add them to the wave view
> 4. Use **Zoom Fit** to see the full waveform

---

### All Three Commands Together

```bash
iverilog -o vendingmachine_tb.out vendingmachine_tb.v vendingmachine.v dff.v
vvp vendingmachine_tb.out
gtkwave dump.vcd
```

---

## 📈 Simulation Output

Expected terminal output (from `$monitor`):

```
at time              0: clk=0 rst=1 x=00 Q=xx Qb=xx y=x R=x
at time           5000: clk=1 rst=1 x=00 Q=00 Qb=11 y=0 R=0
at time          10000: clk=0 rst=1 x=01 Q=00 Qb=11 y=0 R=0
...
at time          70000: clk=1 rst=0 x=10 Q=10 Qb=01 y=1 R=0
...
at time         140000: clk=1 rst=0 x=10 Q=10 Qb=01 y=1 R=1
```

**Testbench Scenarios Covered:**

| Step | rst | x | Scenario |
|------|-----|---|----------|
| 1-4  | 1   | 00,01,10,11 | Reset period — state stays 00 |
| 5    | 0   | 01 | Insert 5 Rs → go to S1 |
| 6    | 0   | 00 | No coin → stay at S1 |
| 7-8  | 0   | 01,01 | Insert 5+5 → go to S2 |
| 9    | 0   | 11 | Refund at S2 → return 5 Rs, go to S1 |
| 10   | 0   | 10 | Insert 10 Rs → go to S2 |
| 11-12| 0   | 01,01 | Insert 5+5 → go to S3, dispense |
| 13-14| 0   | 10,10 | Insert 10+10 → dispense + change |
| 15-16| 0   | 11,11 | Refund at S3 → go S0, no money back |
| 17-18| 0   | 10,10 | Insert 10+10 again → dispense + change |

---

## 🛠️ Tools Used

| Tool | Purpose | Version |
|------|---------|---------|
| Icarus Verilog (iverilog) | Compilation & Simulation | 11.0+ |
| vvp | Simulation runtime | bundled with iverilog |
| GTKWave | Waveform viewer | 3.3+ |
| Xilinx Vivado | Synthesis & Behavioral Simulation | 2023+ |

---

## 📚 Design Methodology

The design followed a structured **digital design flow**:

```
Problem Statement
      ↓
State Diagram (4 states, inputs, outputs)
      ↓
State Transition Table (16 rows)
      ↓
K-map Minimization (D1, D0, y, R)
      ↓
Boolean Equations
      ↓
Verilog Implementation
      ↓
Testbench Simulation (iverilog + GTKWave)
      ↓
Behavioral Verification (Vivado)
      ↓
Bug Detection & Fix (w0 equation corrected)
      ↓
Final Verified Design ✅
```

---

## 🧠 Key Concepts

| Concept | Description |
|---------|-------------|
| **FSM** | Finite State Machine — a model of computation with a fixed number of states |
| **Mealy Machine** | Output depends on current state AND input |
| **Moore Machine** | Output depends only on current state |
| **This Design** | Hybrid — combinational output logic registered through flip-flop |
| **D Flip-Flop** | A clocked memory element that stores 1 bit |
| **K-map** | Karnaugh Map — graphical method to minimize Boolean expressions |
| **Synchronous Reset** | Reset takes effect on the next clock edge |
| **Registered Output** | Output is passed through a flip-flop to align with clock |
| **VCD File** | Value Change Dump — waveform data file read by GTKWave |
| **Timescale** | `1ns/1ps` — simulation time unit and precision |

---

## ⚠️ Design Notes

1. **w0 Bug Fix:** The original `w0` equation had incorrect behavior for rows 8, 10, and 11 of the truth table. The term `(~x0) & (Q1 ^ Q0)` was too broad (missing `~x1` condition) and was replaced with the correct 5-term minimized expression.

2. **Registered Outputs:** Initially `y` and `R` were combinational (`assign`), causing them to fire one cycle early. They were moved into a clocked `always` block to correct the timing.

3. **Initial Block:** An `initial` block is used to set `y` and `R` to 0 before the first clock edge, preventing `X` (unknown) in simulation. This is simulation-only; for FPGA synthesis the `rst` condition in the `always` block handles initialization.

4. **QB outputs:** The complement outputs `QB[0]` and `QB[1]` from the D flip-flops are used directly in the next-state logic to simplify the Boolean expressions.

---

## 👤 Author

**Tirth**
B.Tech — Electronics & VLSI Design Engineering
*Digital Design Project — Vending Machine FSM*

---

## 📄 License

This project is open source and free to use for educational purposes.

---

> ✅ Fully verified against all 16 input-state combinations. Simulated on Icarus Verilog and tested on Xilinx Vivado. 🎉

