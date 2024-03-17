# 20240226-game-hard

| id | hex | name |
| -- | --- | ---- |
| 0  | 0x0 | zero |
| 1  | 0x1 | ra   |
| 2  | 0x2 | sp   |
| 3  | 0x3 | tptr |
| 4  | 0x4 | tcmp |
| 5  | 0x5 | a    |
| 6  | 0x6 | b    |
| 7  | 0x7 | c    |
| 8  | 0x8 | d    |
| 9  | 0x9 | e    |
| 10 | 0xA | f    |
| 11 | 0xB | g    |
| 12 | 0xC | h    |
| 13 | 0xD | i    |
| 14 | 0xE | j    |
| 15 | 0xF | k    |

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
| `sw rs2 rs1`                 | `mem[x[rs1]] = x[rs2]`          |
| `lw rd rs1`                  | `x[rd] = mem[x[rs1]]`           |
| `jalr rd rs1`                | `x[rd] = pc + 4; pc = x[rs1]`   |
| `jcc opt rs2 rs1`            | `if opt(x[rs2]) {pc = x[rs1]}`  |


| 31-20      | 19-16      | 15-12 | 11-8 | 7-4 | 3-0 | opcode |
| ---------- | ---------- | ----- | ---- | --- | --- | -----  |
| imm[11:0]  |            | rs1   | rd   |     | 0x0 | addi   |
| imm[11:0]  |            | rs1   | rd   | 0x1 | 0x0 | subi   |
| imm[11:0]  |            | rs1   | rd   | 0x2 | 0x0 | slai   |
| imm[11:0]  |            | rs1   | rd   | 0x3 | 0x0 | srai   |
| imm[11:0]  |            | rs1   | rd   | 0x4 | 0x0 | andi   |
| imm[11:0]  |            | rs1   | rd   | 0x5 | 0x0 | ori    |
| imm[11:0]  |            | rs1   | rd   | 0x6 | 0x0 | xori   |
|            | rs2        | rs1   | rd   |     | 0x1 | add    |
|            | rs2        | rs1   | rd   | 0x1 | 0x1 | sub    |
|            | rs2        | rs1   | rd   | 0x2 | 0x1 | sla    |
|            | rs2        | rs1   | rd   | 0x3 | 0x1 | sra    |
|            | rs2        | rs1   | rd   | 0x4 | 0x1 | and    |
|            | rs2        | rs1   | rd   | 0x5 | 0x1 | or     |
|            | rs2        | rs1   | rd   | 0x6 | 0x1 | xor    |
|            |            | rs1   | rd   |     | 0x2 | lw     |
|            | rs2        | rs1   |      |     | 0x3 | sw     |
|            |            | rs1   | rd   |     | 0x4 | jalr   |
|            | rs2        | rs1   |      |     | 0x5 | jeq    |
|            | rs2        | rs1   |      | 0x1 | 0x5 | jneq   |
|            | rs2        | rs1   |      | 0x2 | 0x5 | jgt    |
|            | rs2        | rs1   |      | 0x3 | 0x5 | jle    |
|            |            |       | rd   |     | 0x6 | keyboard |
|            | rs2        |       |      |     | 0x7 | monitor  |
|            |            |       | rd   |     | 0x8 | monitor busy |
|            |            |       |      |     | 0x9 | halt   |
|            |            |       |      | 0x1 | 0x9 | ie     |
|            |            |       |      | 0x2 | 0x9 | ide    |
|            |            | rs1   |      | 0x3 | 0x9 | ivec   |
|            |            |       |      | 0x4 | 0x9 | iret   |
