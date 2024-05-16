# 20240226-game-hard

| id | hex | name |
| -- | --- | ---- |
| 0  | 0x0 | zero |
| 1  | 0x1 | sp   |
| 2  | 0x2 | ra   |
| 2  | 0x3 | rv   |
| 4  | 0x4 | tptr |
| 5  | 0x5 | tcmp |
| 6  | 0x6 | a    |
| 7  | 0x7 | b    |
| 8  | 0x8 | c    |
| 9  | 0x9 | d    |
| 0  | 0xA | e    |
| 11 | 0xB | f    |
| 12 | 0xC | g    |
| 13 | 0xD | h    |
| 14 | 0xE | i    |
| 15 | 0xF | j    |

| 31-20     | 19-16 | 15-12 | 11-8 | 7-4 | 3-0    |
| --------- | ------|-------|------|-----|--------|
| imm[11-0] | rs2   | rs1   | rd   | opt | opcode |

| 31-28      | 27-24      | 23-20      | 19-16      | 15-12 | 11-8 | 7-4  | 3-0   |
| ---------- | ---------- | ---------- | ---------- | ----- | ---- | ---- | ----- |
| imm[11-8]  | imm[7-4]   | imm[3-0]   | -          | rs1   | rd   | opt  | calci |
|     -      |     -      |     -      | rs2        | rs1   | rd   | opt  | calcr |
|     -      |     -      |     -      | rs2        | rs1   | -    | -    | sw    |
|     -      |     -      |     -      | -          | rs1   | rd   | -    | lw    |
|     -      |     -      |     -      | -          | rs1   | rd   | -    | jalr  |
|     -      |     -      |     -      | rs2        | rs1   | -    | opt  | jcc   |

| mnemonic                     | register behavior               |
| ---------------------------- | ------------------------------- |
| `calcr opt rd rs1 rs2`       | `x[rd] = x[rs1] opt x[rs2]`     |
| `calci opt rd rs1 imm[11:0]` | `x[rd] = x[rs1] opt ext32(imm)` |
| `jalr rd rs1`                | `x[rd] = pc + 4; pc = x[rs1]`   |
| `jcc opt rs2 rs1`            | `if opt(x[rs2]) {pc = x[rs1]}`  |
| `lw rd rs1`                  | `x[rd] = mem[x[rs1]]`           |
| `sw rs2 rs1`                 | `mem[x[rs1]] = x[rs2]`          |
| `r_io rd imm`                | `x[rd] = io[imm]`               |
| `w_io rs1 imm`               | `io[imm] = x[rs1]`              |
| `w_intr rs1 imm`             | `intr[imm] = x[rs1]`            |
| `iret`                       | `pc = intr_pc; intr_en = 1`     |
| `halt`                       | `pc = pc`                       |
| `icall`                      | `intr_pc = pc; pc = intr_vec; intr_en = 0`|


| 31-20      | 19-16      | 15-12 | 11-8 | 7-4 | 3-0 | opcode |
| ---------- | ---------- | ----- | ---- | --- | --- | -----  |
| imm[11:0]  |            | rs1   | rd   |     | 0x0 | addi   |
| imm[11:0]  |            | rs1   | rd   | 0x1 | 0x0 | subi   |
| imm[11:0]  |            | rs1   | rd   | 0x2 | 0x0 | slli   |
| imm[11:0]  |            | rs1   | rd   | 0x3 | 0x0 | srli   |
| imm[11:0]  |            | rs1   | rd   | 0x4 | 0x0 | srai   |
| imm[11:0]  |            | rs1   | rd   | 0x5 | 0x0 | andi   |
| imm[11:0]  |            | rs1   | rd   | 0x6 | 0x0 | ori    |
| imm[11:0]  |            | rs1   | rd   | 0x7 | 0x0 | xori   |
|            | rs2        | rs1   | rd   |     | 0x1 | add    |
|            | rs2        | rs1   | rd   | 0x1 | 0x1 | sub    |
|            | rs2        | rs1   | rd   | 0x2 | 0x1 | sll    |
|            | rs2        | rs1   | rd   | 0x3 | 0x1 | srl    |
|            | rs2        | rs1   | rd   | 0x4 | 0x1 | sra    |
|            | rs2        | rs1   | rd   | 0x5 | 0x1 | and    |
|            | rs2        | rs1   | rd   | 0x6 | 0x1 | or     |
|            | rs2        | rs1   | rd   | 0x7 | 0x1 | xor    |
|            |            | rs1   | rd   |     | 0x2 | jalr   |
|            | rs2        | rs1   |      |     | 0x3 | jeq    |
|            | rs2        | rs1   |      | 0x1 | 0x3 | jneq   |
|            | rs2        | rs1   |      | 0x2 | 0x3 | jge    |
|            | rs2        | rs1   |      | 0x3 | 0x3 | jlt    |
|            | rs2        | rs1   |      | 0x4 | 0x3 | jgt    |
|            | rs2        | rs1   |      | 0x5 | 0x3 | jle    |
|            |            | rs1   | rd   |     | 0x4 | lw     |
|            | rs2        | rs1   |      |     | 0x5 | sw     |
| imm[11:0]  |            |       | rd   |     | 0x6 | r io   |
| imm[11:0]  |            | rs1   |      |     | 0x7 | w io   |
| imm[11:0]  |            | rs1   |      |     | 0x8 | w intr |
|            |            |       |      |     | 0x9 | iret   |
|            |            |       |      |     | 0xA | halt   |
