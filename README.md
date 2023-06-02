# aureo-pdk

This repository contains the Process Design Kit (PDK) for the Aureo process. The Aureo process is a unique bonded 2-SCS layer Silicon-on-Insulator (SOI) process, specifically designed to enable the integration of Integrated Circuits (ICs) and Micro-Electro-Mechanical Systems (MEMS). This process is intended to make it possible to build combined systems such as microrobots and sensor motes.

## Layer stackup

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/abacc744-3962-4fe8-acd8-cb80029c1709)

## Bonded structure

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/e0779e61-25a8-4243-8b25-a8bb2ac41eb6)


## Contents

- `aureo_lib/` - Cadence Virtuoso library with standard cells
- `aureo.tf` - Cadence Virtuoso technology file

## Process Flow

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/1dd00361-0531-422c-900e-9edd9f600898)

1. The process begins with a 40/2/550um SOI wafer. Note that for a faster release of the substrate before bonding, it may be helpful to start with SOI wafers with pre-patterned buried oxide (BOX). Or alternatively, the substrate can be pre-patterned with an initial backside DRIE etch.

2. The `SOI` mask is applied with a timed DRIE

3. 500nm of nitride is deposited via LPCVD

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/62749289-2eeb-4ae3-ae51-fa702b7a86b4)

4. 1um of N+ doped polysilicon is deposited via LPCVD

5. The `POLY` mask is applied using RIE

6. A hot phopshoric acid etch of the nitride removes the exposed nitride. The polysilicon remains electrically isolated from the SOI.

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/3a2a2357-0884-477f-adf5-014529fed43d)

7. A 1um film of Au is patterned onto the wafer using lift-off.

8. The buried oxide is etched away and the structure is released from the substrate in a 49% HF bath.

9. The counterpart structure, most likely fabricated on the same wafer, is then bonded at the gold contacts.


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
