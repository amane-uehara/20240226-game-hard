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

| 31-28      | 27-24      | 23-20      | 19-16      | 15-12 | 11-8 | 7-4  | 3-0   |
| ---------- | ---------- | ---------- | ---------- | ----- | ---- | ---- | ----- |
| imm[31-28] | imm[27-24] | imm[23-20] | imm[19-16] | -     | rd   | -    | lih   |
| imm[15-12] | imm[11-8]  | imm[7-4]   | imm[3-0]   | rs1   | rd   | opt  | calci |
|     -      |     -      |     -      | rs2        | rs1   | rd   | opt  | calcr |
| imm[11-8]  | imm[7-4]   | imm[3-0]   | rs2        | rs1   | -    | -    | sw    |
| imm[11-8]  | imm[7-4]   | imm[3-0]   | -          | rs1   | rd   | -    | lw    |
|            |            |            | -          | rs1   | rd   | -    | jalr  |
|            |            |            | rs2        | rs1   | -    | opt  | jcc   |

| mnemonic                     | register behavior                     |
| ---------------------------- | ------------------------------------- |
| `lih rd imm[31:16]`          | `rd[31:16] = imm[31:16]`              |
| `calcr opt rd rs1 rs2`       | `rd = rs1 opt rs2`                    |
| `calci opt rd rs1 imm[15:0]` | `rd = rs1 opt ext32(imm)`             |
| `sw rs2 rs1 imm[11:0]`       | `mem[rs1 + ext32(imm)] = rs2`         |
| `lw rd rs1 imm[11:0]`        | `rd = mem[rs1 + ext32(imm)]`          |
| `jalr rd rs1`                | `rd = pc + 4; pc = rs1`               |
| `jcc opt rs2 rs1`            | `if opt(rs2) {pc = rs1}`              |


| 31-20      | 19-16      | 15-12 | 11-8 | 7-4 | 3-0 | opcode |
| ---------- | ---------- | ----- | ---- | --- | --- | -----  |
| imm[31:20] | imm[19:16] | 0x0   | rd   | 0x0 | 0x0 | lih    |
| imm[11:0]  | 0x0        | rs1   | rd   | 0x0 | 0x9 | lw     |
| imm[11:0]  | rs2        | rs1   | 0x0  | 0x0 | 0xB | sw     |
| imm[15:4]  | imm[3:0]   | rs1   | rd   | 0x0 | 0x2 | addi   |
| imm[15:4]  | imm[3:0]   | rs1   | rd   | 0x1 | 0x2 | subi   |
| imm[15:4]  | imm[3:0]   | rs1   | rd   | 0x2 | 0x2 | slai   |
| imm[15:4]  | imm[3:0]   | rs1   | rd   | 0x3 | 0x2 | srai   |
| imm[15:4]  | imm[3:0]   | rs1   | rd   | 0x4 | 0x2 | andi   |
| imm[15:4]  | imm[3:0]   | rs1   | rd   | 0x5 | 0x2 | ori    |
| imm[15:4]  | imm[3:0]   | rs1   | rd   | 0x6 | 0x2 | xori   |
| 0x000      | rs2        | rs1   | rd   | 0x0 | 0x3 | add    |
| 0x000      | rs2        | rs1   | rd   | 0x1 | 0x3 | sub    |
| 0x000      | rs2        | rs1   | rd   | 0x2 | 0x3 | sla    |
| 0x000      | rs2        | rs1   | rd   | 0x3 | 0x3 | sra    |
| 0x000      | rs2        | rs1   | rd   | 0x4 | 0x3 | and    |
| 0x000      | rs2        | rs1   | rd   | 0x5 | 0x3 | or     |
| 0x000      | rs2        | rs1   | rd   | 0x6 | 0x3 | xor    |
| 0x000      | rs2        | rs1   | 0x0  | 0x0 | 0x7 | jeq    |
| 0x000      | rs2        | rs1   | 0x0  | 0x1 | 0x7 | jneq   |
| 0x000      | rs2        | rs1   | 0x0  | 0x2 | 0x7 | jgt    |
| 0x000      | rs2        | rs1   | 0x0  | 0x3 | 0x7 | jle    |
| 0x000      | 0x0        | rs1   | rd   | 0x0 | 0x5 | jalr   |
| 0x000      | 0x000      | 0x0   | 0x0  | 0x0 | 0xF | halt   |
| 0x000      | 0x000      | 0x0   | 0x0  | 0x1 | 0xF | ie     |
| 0x000      | 0x000      | 0x0   | 0x0  | 0x2 | 0xF | ide    |
| 0x000      | 0x000      | rs1   | 0x0  | 0x3 | 0xF | ivec   |
| 0x000      | 0x000      | 0x0   | 0x0  | 0x4 | 0xF | iret   |
