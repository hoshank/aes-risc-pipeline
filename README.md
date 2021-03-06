
# AES on a RISC Pipeline

*A design space study of different ways to implement AES accelerator
 instructions in a RISC CPU pipeline, obeying a 2-read-1-write register
 file constraint.*

---

1. [Progress](#Progress)
2. [Quickstart](#Quickstart)
3. [Introduction](#Introduction)
4. [Points for the paper](#Points-for-the-paper)

## Progress

AES Implementation  | Spike | SCARV CPU | Rocket RV32 | Rocket RV64
--------------------|-------|-----------|-------------|----------------
Byte-wise reference | x     | x         | x           | x
TTable    reference | x     | x         | x           | x
RV32 V1 Sub + Mix   | x     | x         | x           | N/A ?
RV32 V2 (Tillich)   | x     | x         | x           | N/A ?
RV32 V3 (HW TTable) | x     | x         | x           | N/A ?
RV32 V3 (HW TTable) | x     | x         | x           | N/A ?
RV32 Tiled          | x     | x         | x           | N/A ?
RV64 (Ben's)        | x     | N/A       | N/A         | x

- All implementations support AES 128 block encrypt/decrypt.

- The API uses separate functions to create the encrypt/decrypt KeySchedules,
  since some implementations use the equivilent inverse cipher construction.

  - This also allows us to support on-line KeySchedules, though no
    implementations currently do this.

- We can currently measure:

  - Static code size

  - Instruction counts

  - Cycle countes

  - Hardware size in NAND2 equivalents.

  - Longest HW topological path.

- Will want to add measurements for:

  - [ ] Dynamic data bandwidth (bytes)

  - [ ] Dynamic instruction bandwidth (bytes)

- Additional AES implementations to add:

  - [ ] Bitslicing.

## Quickstart

- Checkout the repository:
  ```sh
  git checkout <REPO PATH>
  cd aes-risc-pipeline
  git submodule update --init --recursive
  ```

- Setup the project workspace:
  ```sh
  source bin/conf.sh
  ```

- Build the toolchain:
  ```
  make toolchain-build
  ```

- Configure and build the ISA simulator
  ```
  make spike-configure spike-build
  ```

- Configure and build the Spike proxy kernel
  ```
  make pk-configure pk-build
  ```

- Build and run the benchmarks:
  
  ```
  make -C ./src/ all
  make -C ./src/ test
  ```

  See `$REPO_BUILD/src/` for build artifacts, test results and
  performance numbers.

- To run the benchmarks on the cycle accurate model of the scarv-cpu
  open a *new terminal* and:
  ```
  cd extern/scarv-cpu
  source bin/conf.sh
  ./bin/verilator-build-aes-variants.sh
  ```

  This will build the vanila scarv-cpu core, as well as several variants
  with the different ISE implementations.

  Simulation results are placed in `work/unit/aes-*`, and synthesis
  results are placed in `work/synth-*`.
      

## Introduction

The aim is to evaluate several different ways of accelerating AES within
a scalar CPU pipeline.


For `32` bit datapaths:

- A simple `N` wide SBox instruction, which applies the `(Inv)AESSubBytes`
  transformation to each of the `N` bytes in a register.

- The Tillich/Großschädl paper [Instruction Set Extensions for Efficient AES Implementation on 32-bit Processors](https://link.springer.com/chapter/10.1007/11894063_22).

- Markku-Juhani O. Saarinen's
  [lwaes](https://github.com/mjosaarinen/lwaes_isa)
  paper, presented at
  [SECRISCV](https://ascslab.org/conferences/secriscv/index.html).

- Andy Glew's "tiled AES" approach.


For `64` bit datapaths:

- The RV64 proposal from the
  [riscv-crypto](https://github.com/scarv/riscv-crypto)
  (see draft v0.2.1, section 4.4.2)
  repository, which splits the AES round into hi/lo components.


Each approach is evaluated on:

- Static code size.

- Dynamic instruction bandwidth (bytes fetched).

- Performance improvement (instruction count, cycle count).

- Additional instruction encoding points.

- NAND2 gate equivalent for hardware area.

- Longest topological path length / impact on critical path.


Evaluations are done using:

- The Spike ISA simulator, modified to support the given instructions.
- A modified version of the
  [scarv-cpu](https://github.com/scarv/scarv-cpu).
- Rocket?


## Points for the paper

This is a (unordered) list of points to make or discuss in the paper:


- Why do AES on a scalar CPU pipeline at all?

- Other ISAs approaches to accelerating AES: x86/ARM/MIPS.

- Software approaches to implementing AES.

  - Why TTables is fast but can be insecure.

- Security arguments for accelerated AES.

  - Removes timing channels.

  - Still vulnerable to power/EM attacks. Possibly more so than a
    pure software implementation.

  - Still vulnerable to fault attacks (voltage glitching / brownouts).

- Implmentation space for each variant. E.g. how many SBox operations to
  instantiate?

