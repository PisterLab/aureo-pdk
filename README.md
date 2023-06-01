# aureo-pdk

This repository contains the Process Design Kit (PDK) for the Aureo process. The Aureo process is a unique bonded 2-SCS layer Silicon-on-Insulator (SOI) process, specifically designed to enable the integration of Integrated Circuits (ICs) and Micro-Electro-Mechanical Systems (MEMS). This process is intended to make it possible to build combined systems such as microrobots and sensor motes.

## Layer stackup

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/abacc744-3962-4fe8-acd8-cb80029c1709)

## Bonded structure

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/e0779e61-25a8-4243-8b25-a8bb2ac41eb6)


## Contents

- `aureo_lib/` - Cadence Virtuoso library with standard cells
- `aureo.tf` - Cadence Virtuoso technology file

## Process Definition

Beginning with a 40/2/550um SOI wafer, the Aureo process is defined as follows:

Note that for a faster release of the substrate before bonding, it may be helpful to start with SOI wafers with pattern buried oxide (BOX). 

1. `/TRENCH` DRIE SOI 
2. 500nm LPCVD nitride
3. `/POLY` 1um LPCVD N+ polysilicon
4. Hot phosphoric acid etch of the nitride
5. 1um evaporated Au liftoff

After the above steps, a 49% HF release etch is performed to release the structures. The individual dies are then diced and bonded together at the gold-gold contacts.


## Working with the PDK

The Aureo PDK is developed for Cadence Virtuoso, and exists as an ASCII Technology File together with a Virtuoso library.

To allow for connectivity extraction to verify layout vs. schematic and perform parasitic extraction, a particular set of layers were defined in which users can layout their designs in.

Of particular note is the concept of high-metal and low-metal, which captures the ability to design connectivity between the poly layers and SOI layers using the metal layer. The figure below explains the correspondence between the layout view's `LOWMETAL1`/`HIGHMETAL1`/`LOWMETAL2`/`HIGHMETAL2` and the physical result.

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/dc714a5b-d4a4-4abd-acce-a0b8fba3050d)


## Design Rules

### TRENCH

- Minimum width: 2um
- Minimum spacing: 2um

### POLY

- Minimum width: 2um
- Minimum spacing: 2um
