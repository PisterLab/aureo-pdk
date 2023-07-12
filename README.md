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

### Cadence setup

To set up the environment to run Virtuoso, perform the followng steps:
1. Run the following command to copy `setup-template.sh` to `setup.sh`.
   ```
   cp setup-template.sh setup.sh
   ```
2. Add the corresponding license file and tools directories to `setup.sh`.
   If you are running on the BWRC servers, set `export CDS_HOME=/tools/cadence/ICADVM/ICADVM201`.
   If you are running on the Alcatraz server, set `export CDS_HOME=/usr/eesww/cadence/IC618`.
   If you are running on the EDA servers, set `export CDS_HOME=/share/instsww/cadence/IC618`.

To start Virtuoso, run the following commands to set up the environment and start Virtuoso.
```
source .bashrc
virtuoso &
```

### High and low metal

To allow for connectivity extraction to verify layout vs. schematic and perform parasitic extraction, a particular set of layers were defined in which users can layout their designs in.

Of particular note is the concept of high-metal and low-metal, which captures the ability to design connectivity between the poly layers and SOI layers using the metal layer. The figure below explains the correspondence between the layout view's `LOWMETAL1`/`HIGHMETAL1`/`LOWMETAL2`/`HIGHMETAL2` and the physical result.

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/dc714a5b-d4a4-4abd-acce-a0b8fba3050d)

### Exporting the layout and masks

The Aureo PDK offers a number of tools for streaming out the layouts to GDSII file format. The current layer number definition is as follows:

**Layers for fabrication**
| Layer Name | Layer Number | Description |
| ---------- | ------------ | ----------- |
| `SOIFAB` | 0 | Silicon on Insulator |
| `POLYFAB` | 1 | Polysilicon |
| `METALFAB` | 2 | Metal |

**Merged layers for inspection, visualization, and 3D rendering**

| Layer Name | Layer Number | Description |
| ---------- | ------------ | ----------- |
| `SOI1FAB` | 3 | Silicon on Insulator |
| `POLY1FAB` | 4 | Polysilicon |
| `METAL1FAB` | 5 | Metal |
| `METAL2FAB` | 6 | Metal |
| `POLY2FAB` | 7 | Polysilicon |
| `SOI2FAB` | 8 | Silicon on Insulator |

**Layers for layout**

| Layer Name | Layer Number | Description |
| ---------- | ------------ | ----------- |
| `SOI1` | 9 | Silicon on Insulator |
| `POLY1` | 11 | Polysilicon |
| `LOWMETAL1` | 12 | Metal |
| `HIGHMETAL1` | 13 | Metal |
| `HIGHMETAL2` | 14 | Metal |
| `LOWMETAL2` | 15 | Metal |
| `POLY2` | 16 | Polysilicon |
| `SOI2` | 17 | Silicon on Insulator |

### Export Scripts

**Export GDS**

To export the GDS of a particular library and cell, run the following command:

```
python3 tools/export_gds.py --lib="aureo_lib" --cell="test"
```

`tools/export_gds.py` - Given a library and cellview, export_fab.py will stream out a GDSII file 
with all the drawn layers present (according the "Layer for layout" table above). This will directly export the GDS to the directory from which the command was run.

**Process the GDS**

To prepare the GDS for fabrication, run the following command. Note that this currently requires that `tools/export_gds.py` has been run first.

```
python3 tools/process_gds.py --lib="aureo_lib" --cell="test"
```
`tools/process_gds.py` takes the drawn layers in the corresponding Aureo GDSII file and preprocesses them
for fab by merging the metal layers: 
 - (`LOWMETAL1` & `HIGHMETAL1` -> `METAL1FAB`)
 - (`LOWMETAL2` & `HIGHMETAL2` -> `METAL2FAB`).
 
Then `SOI1/2` become `SOIFAB1/2` and `POLY1/2` become `POLYFAB1/2`.

At this point the first gds file is written out with the filename `[CELLNAME]_merged.gds.`

Then, all `[LAYERNAME]2` layers are reflected about the X-axis and moved to `SOIFAB`, `POLYFAB`, `METALFAB` layers.
The second gds file is written out. This final gds file contains only 3 layers for 3 masks.

The final gds file is written out with the filename `[CELLNAME]_fab.gds.`

**Extract the preprocess GDS for a 3D view**

Install OpenSCAD

If not done, run `tools/export_gds.py`

Move the preprocess GDS to 'aureo-pdk/tools/examples' file.

Run the following command in 'aureo-pdk/tools' working directory. 

```
python3 gds3xtrude.py --tech "examples/test_preprocess.layerstack" --input "examples/test_preprocess.gds" --view
```
`gds3xtrude.py` runs the GDS in OpenSCAD.

`examples/test_preprocess.layerstack` defines the drawn layers order, thicknesses and colors.

`examples/test_preprocess.gds` is the preprocess GDS you want to extract

To export the 3D view as STL file, press F6 for rendering, then press F7 for exporting, in OpenSCAD.

**Extract the fab GDS for a 3D view**

Extracting the fab GDS is useful for 3D printing.

Install OpenSCAD

If not done, run `tools/process_gds.py`

Move the fab GDS to 'aureo-pdk/tools/examples' file.

Run the following command in 'aureo-pdk/tools' working directory. 

```
python3 gds3xtrude.py --tech "examples/test_preprocess.layerstack" --input "examples/test_fab.gds" --view
```
`gds3xtrude.py` runs the GDS in OpenSCAD.

`examples/test_preprocess.layerstack` defines the drawn layers order, thicknesses and colors.

`examples/test_fab.gds` is the fab GDS you want to extract

To export the 3D view as a STL file, press F6 for rendering, then press F7 for exporting, in OpenSCAD.

### Updating the PDK

Updates to the Aureo PDK's ASCII Technology File (`aureo.tf`) can be applied to an existing Cadence Library by reloading the Technology File in the Cadence CIW. 

See the image below:

![image](https://github.com/PisterLab/aureo-pdk/assets/6250953/588b2cf3-6622-47de-a5a6-0237cd690231)

Updates to the Display Resource File (`display.drf`) can be applied most easily by restarting Cadence, as the `display.drf` file is reloaded each time Cadence is launched from a directory.

## Design Rules

### Width / Line Rules

| Layer Name | Minimum Width | 
| ---------- | ------------ | 
| `SOI1` | 2um | 
| `POLY1` | 2um | 
| `LOWMETAL1` | 2um |
| `HIGHMETAL1` | 2um |
| `HIGHMETAL2` | 2um |
| `LOWMETAL2` | 2um | 
| `POLY2` | 2um | 
| `SOI2` | 2um | 

### Space Rules

Single layer space rules are enforced on spaces between drawings/shapes on the same layer.

| Layer Name | Minimum Width | 
| ---------- | ------------ | 
| `SOI1` | 2um | 
| `POLY1` | 2um | 
| `LOWMETAL1` | 4um |
| `HIGHMETAL1` | 4um |
| `HIGHMETAL2` | 4um |
| `LOWMETAL2` | 4um | 
| `POLY2` | 2um | 
| `SOI2` | 2um |

##
