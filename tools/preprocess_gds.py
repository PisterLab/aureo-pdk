# export_masks.py - Given a library and cellview, export_fab.py will stream out a GDSII file
# with all the drawn layers present. It will first ensure that SOI layers have been split about
# the SOIHOLE layers (see aureo.il file).
#
# The drawn layers are then preprocessed for fab by merging the metal layers (LOWMETAL1 & HIGHMETAL1 -> METAL1FAB)
# (LOWMETAL2 & HIGHMETAL2 -> METAL2FAB).
# SOI1/2 become SOIFAB1/2.
# POLY1/2 become POLYFAB1/2.
# At this point the first gds file is written out. 
# 
# Then, all [LAYERNAME]2 layers are reflected about the X-axis and moved to SOIFAB, POLYFAB, METALFAB layers.
# The second gds file is written out. This final gds file contains only 3 layers for 3 masks.


import argparse
import subprocess, os
import gdspy

def change_layers_all(cell, old_layer, new_layer):
    """Make a copy of the shapes/paths in the given layer and add them to the cell with the new layer number."""
    shapes = get_polygons_by_layer(cell.polygons, old_layer)
    for shape in shapes:
        shape = gdspy.copy(shape)
        shape.layers = [new_layer[0]]
        shape.datatypes = [new_layer[1]]
        cell.add(shape)

    paths = get_paths_by_layer(cell.paths, old_layer)
    paths_copy = paths.copy()
    for path in paths:
        path = gdspy.copy(path)
        path.layers = [new_layer[0]]
        path.datatypes = [new_layer[1]]
        cell.add(path)

    return cell
def get_paths_by_layer(paths, layer):
    """Return a list of paths in the given layer."""
    return [path for path in paths if layer[0] in path.layers and layer[1] in path.datatypes ]

def get_polygons_by_layer(polygons, layer):
    """Return a list of polygons in the given layer."""
    return [polygon for polygon in polygons if layer[0] in polygon.layers and layer[1] in polygon.datatypes ]

def copy_list(list):
    """Return a copy of the given list."""
    return [gdspy.copy(item) for item in list]

# Define and parse command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('--lib', help='Library name')
parser.add_argument('--cell', help='Cell view name')
args = parser.parse_args()


############################## 
# Preprocess
##############################
ld_soifab = (0, 0)
ld_polyfab = (1, 0)
ld_metalfab = (2, 0)
ld_soi1fab = (3, 0)
ld_poly1fab = (4, 0)
ld_metal1fab = (5, 0)
ld_metal2fab = (6, 0)
ld_poly2fab = (7, 0)
ld_soi2fab = (8, 0)
ld_soi1 = (9, 0)
ld_soihole1 = (10, 0)
ld_poly1 = (11, 0)
ld_lowmetal1 = (12, 0)
ld_highmetal1 = (13, 0)
ld_highmetal2 = (14, 0)
ld_lowmetal2 = (15, 0)
ld_poly2 = (16, 0)
ld_soi2 = (17, 0)
ld_soihole2 = (18, 0)

# Load the GDS file into gdspy
lib = gdspy.GdsLibrary()
lib.read_gds(args.cell + '_preprocess.gds')

# Select the cell
cell = lib.cells[args.cell]


# Perform boolean operations to merge layers and reflect about the X axis
shapes = cell.polygons
paths = cell.get_paths()

# Initialize empty list for the layers if there are no shapes drawn on them
lm1shapes = get_polygons_by_layer(shapes, ld_lowmetal1)
hm1shapes = get_polygons_by_layer(shapes, ld_highmetal1)
lm2shapes = get_polygons_by_layer(shapes, ld_lowmetal2)
hm2shapes = get_polygons_by_layer(shapes, ld_highmetal2)

lm1paths = get_paths_by_layer(paths, ld_lowmetal1)
hm1paths = get_paths_by_layer(paths, ld_highmetal1)
lm2paths = get_paths_by_layer(paths, ld_lowmetal2)
hm2paths = get_paths_by_layer(paths, ld_highmetal2)

# Merge layers only if there are shapes on them

if lm1shapes or hm1shapes:
    merged_m1shapes = lm1shapes + hm1shapes
    for shape in merged_m1shapes:
        shape.layers = [ld_metal1fab[0]]
        shape.datatypes = [ld_metal1fab[1]]
    cell.add(merged_m1shapes)

if lm2shapes or hm2shapes:
    merged_m2shapes  = lm2shapes + hm2shapes
    for shape in merged_m2shapes:
        shape.layers = [ld_metal2fab[0]]
        shape.datatypes = [ld_metal2fab[1]]
    cell.add(merged_m2shapes)

# Cannot perform boolean operations on paths, so we must copy them over
if lm1paths or hm1paths:
    merged_m1paths = lm1paths + hm1paths
    for path in merged_m1paths:
        path = gdspy.copy(path)
        path.layers = [ld_metal1fab[0]]
        path.datatypes = [ld_metal1fab[1]]
        cell.add(path)

if lm2paths or hm2paths:
    merged_m2paths = lm2paths + hm2paths
    for path in merged_m2paths:
        path = gdspy.copy(path)
        path.layer = [ld_metal2fab[0]]
        path.datatype = [ld_metal2fab[1]]
        cell.add(path)

# Now assign the SOI1, POLY1, SOI2, POLY2 layers to the fab layers
change_layers_all(cell, ld_soi1, ld_soi1fab)
change_layers_all(cell, ld_poly1, ld_poly1fab)
change_layers_all(cell, ld_soi2, ld_soi2fab)
change_layers_all(cell, ld_poly2, ld_poly2fab)



# Write out the new GDS file
gdspy.write_gds(args.cell + '_merged.gds', cells=[cell])
#cell.write_svg('_merged.svg')
#gdspy.LayoutViewer(cells=cell, depth=3)


##############################
# Reflect
##############################
shapes = cell.get_polygons(by_spec=True)

fab_cell = gdspy.Cell(args.cell + '_fab')

bbox = cell.get_bounding_box()
xmin = bbox[0][0]
xmax = bbox[1][0]
ymin = bbox[0][1]
ymax = bbox[1][1]

# Copy and reflect SOI2FAB, METAL2FAB, and POLY2FAB layers
for ld_fab in [(ld_soi2fab, ld_soifab), (ld_metal2fab, ld_metalfab), (ld_poly2fab, ld_polyfab)]:
    fab_shapes = get_polygons_by_layer(cell.polygons, ld_fab[0])
    if fab_shapes:
        for shape in fab_shapes:
            shape = gdspy.copy(shape)
            shape.mirror((xmax,ymin), (xmax,ymax))  # reflect about the line x = rightmost
            shape.layers = [ld_fab[1][0]]
            shape.datatypes = [ld_fab[1][1]]
            fab_cell.add(shape)
    fab_paths = get_paths_by_layer(cell.paths, ld_fab[0])
    if fab_paths:
        copied = fab_paths.copy()
        for path in fab_paths:
            path = gdspy.copy(path)
            path.mirror((xmax,ymin), (xmax,ymax))
            path.layers = [ld_fab[1][0]]
            path.datatypes = [ld_fab[1][1]]
            fab_cell.add(path)



fab_cell.add(copy_list(get_polygons_by_layer(cell.polygons, ld_soi1fab)))
fab_cell.add(copy_list(get_polygons_by_layer(cell.polygons, ld_metal1fab)))
fab_cell.add(copy_list(get_polygons_by_layer(cell.polygons, ld_poly1fab)))

fab_cell.add(copy_list(get_paths_by_layer(cell.paths, ld_soi1fab)))
fab_cell.add(copy_list(get_paths_by_layer(cell.paths, ld_metal1fab)))
fab_cell.add(copy_list(get_paths_by_layer(cell.paths, ld_poly1fab)))

change_layers_all(fab_cell, ld_soi1fab, ld_soifab)
change_layers_all(fab_cell, ld_metal1fab, ld_metalfab)
change_layers_all(fab_cell, ld_poly1fab, ld_polyfab)

# Write out the new GDS file
lib.write_gds(args.cell + '_fab.gds', cells=[fab_cell])

# reload the gds and view it
lib = gdspy.GdsLibrary()
lib.read_gds(args.cell + '_fab.gds')
gdspy.LayoutViewer(cells=lib.cells[args.cell + '_fab'], depth=3)
