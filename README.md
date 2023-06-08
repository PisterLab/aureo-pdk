# aureo-pdk

This repository contains the Process Design Kit (PDK) for the Aureo process. The Aureo process is a unique bonded 2-SCS layer Silicon-on-Insulator (SOI) process, specifically designed to enable the integration of Integrated Circuits (ICs) and Micro-Electro-Mechanical Systems (MEMS). This process is intended to make it possible to build combined systems such as microrobots and sensor motes.

## Layer stackup

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/abacc744-3962-4fe8-acd8-cb80029c1709)

## Bonded structure

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/e0779e61-25a8-4243-8b25-a8bb2ac41eb6)


## Contents

- `aureo_lib/` - Cadence Virtuoso library with standard cells
- `aureo.tf` - Cadence Virtuoso technology file
- `display.drf` - Display resource file defining how layers are rendered in Cadence's Layout XL.

## Process Flow

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/0ff4ffb6-6a4a-4cc0-9540-0dc3eb88d8ad)

1. The process begins with a 40/2/550um SOI wafer. Note that for a faster release of the substrate before bonding, it may be helpful to start with SOI wafers with pre-patterned buried oxide (BOX). Or alternatively, the substrate can be pre-patterned with an initial backside DRIE etch.
2. 500nm of nitride is deposited via LPCVD 
3. 1um of N+ doped polysilicon is deposited via LPCVD

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/16907d1b-308a-4370-a489-655022b9720a)

4. The `POLY` mask is applied using RIE
5. A hot phopshoric acid etch of the nitride removes the exposed nitride. The polysilicon remains electrically isolated from the SOI.
6. A 1um film of Au is patterned onto the wafer using lift-off.

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/dd273e7f-42c2-443a-9da8-a8a27e047c28)

7. The `SOI` mask is applied with a timed DRIE
8. The counterpart structure, most likely fabricated on the same wafer, is then bonded at the gold contacts.
9. The buried oxide is etched away and the structure is released from the substrate in a 49% HF bath.

## Working with the PDK

The Aureo PDK is developed for Cadence Virtuoso, and exists as an ASCII Technology File together with a Virtuoso library.

To allow for connectivity extraction to verify layout vs. schematic and perform parasitic extraction, a particular set of layers were defined in which users can layout their designs in.

Of particular note is the concept of high-metal and low-metal, which captures the ability to design connectivity between the poly layers and SOI layers using the metal layer. The figure below explains the correspondence between the layout view's `LOWMETAL1`/`HIGHMETAL1`/`LOWMETAL2`/`HIGHMETAL2` and the physical result.

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/dc714a5b-d4a4-4abd-acce-a0b8fba3050d)

### Exporting the masks


## Design Rules

### TRENCH

- Minimum width: 2um
- Minimum spacing: 2um

### POLY

- Minimum width: 2um
- Minimum spacing: 2um
