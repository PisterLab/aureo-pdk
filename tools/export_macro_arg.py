import pya
from klayout import db
import os
import argparse

parser = argparse.ArgumentParser(description="Run export macro for GDS layout processing.")
parser.add_argument("input_file", help="Path to the input GDS file")
parser.add_argument("mask_run_num", help="Mask run number to be used in output file names")
args = parser.parse_args()

input_file = args.input_file
MASK_RUN_NUM = args.mask_run_num

input_dir = os.path.dirname(input_file)
export_dir = os.path.join(input_dir, "Export")
os.makedirs(export_dir, exist_ok=True)

layout = pya.Layout()
layout.read(input_file)

top = layout.top_cell()

# flatten all cells
top.flatten(True)


###########################
# DEFINE FAB LAYERS
###########################
soi1 = layout.layer(0, 0)  # 0/0
poly1 = layout.layer(1, 0)  # 1/0
metal1 = layout.layer(2, 0)  # 2/0
metal2 = layout.layer(3, 0)  # 3/0
poly2 = layout.layer(4, 0)  # 4/0
soi2 = layout.layer(5, 0)  # 5/0
ndope = layout.layer(6, 0)  # 6/0
pdope = layout.layer(7, 0)  # 7/0
layer_43 = layout.layer(43, 0)  # 43/0

###########################
# DEFINE MERGE LAYERS
###########################
layer_9_0 = layout.layer(9, 0)
layer_9_255 = layout.layer(9, 255)
layer_10_0 = layout.layer(10, 0)
layer_11_0 = layout.layer(11, 0)
layer_11_255 = layout.layer(11, 255)
layer_12_0 = layout.layer(12, 0)
layer_12_255 = layout.layer(12, 255)
layer_13_0 = layout.layer(13, 0)
layer_13_255 = layout.layer(13, 255)
layer_14_0 = layout.layer(14, 0)
layer_14_255 = layout.layer(14, 255)
layer_15_0 = layout.layer(15, 0)
layer_15_255 = layout.layer(15, 255)
layer_16_0 = layout.layer(16, 0)
layer_16_255 = layout.layer(16, 255)
layer_17_0 = layout.layer(17, 0)
layer_17_255 = layout.layer(17, 255)
layer_18_0 = layout.layer(18, 0)
layer_19_0 = layout.layer(19, 0)

# create regions from layers
region_9_0 = pya.Region(top.shapes(layer_9_0))
region_9_255 = pya.Region(top.shapes(layer_9_255))
region_10_0 = pya.Region(top.shapes(layer_10_0))
region_11_0 = pya.Region(top.shapes(layer_11_0))
region_11_255 = pya.Region(top.shapes(layer_11_255))
region_12_0 = pya.Region(top.shapes(layer_12_0))
region_12_255 = pya.Region(top.shapes(layer_12_255))
region_13_0 = pya.Region(top.shapes(layer_13_0))
region_13_255 = pya.Region(top.shapes(layer_13_255))
region_14_0 = pya.Region(top.shapes(layer_14_0))
region_14_255 = pya.Region(top.shapes(layer_14_255))
region_15_0 = pya.Region(top.shapes(layer_15_0))
region_15_255 = pya.Region(top.shapes(layer_15_255))
region_16_0 = pya.Region(top.shapes(layer_16_0))
region_16_255 = pya.Region(top.shapes(layer_16_255))
region_17_0 = pya.Region(top.shapes(layer_17_0))
region_17_255 = pya.Region(top.shapes(layer_17_255))
region_18_0 = pya.Region(top.shapes(layer_18_0))
region_19_0 = pya.Region(top.shapes(layer_19_0))

###########################
# MERGE LAYERS
###########################
# 0/0: 9/0 + 9/255 - 10/0
soi1_region = (region_9_0 | region_9_255) - region_10_0
top.shapes(soi1).insert(soi1_region)  # create new layer and insert result shapes

# 1/0: 11/0 + 11/255
poly1_region = region_11_0 | region_11_255
top.shapes(poly1).insert(poly1_region)

# 2/0: 12/0 + 13/0 + 12/255 + 13/255
metal1_region = region_12_0 | region_13_0 | region_12_255 | region_13_255
top.shapes(metal1).insert(metal1_region)

# 3/0: 14/0 + 15/0 + 14/255 + 15/255
metal2_region = region_14_0 | region_15_0 | region_14_255 | region_15_255
top.shapes(metal2).insert(metal2_region)

# 4/0: 16/0 + 16/255
poly2_region = region_16_0 | region_16_255
top.shapes(poly2).insert(poly2_region)

# 5/0: 17/0 + 17/255 - 18/0
soi2_region = (region_17_0 | region_17_255) - region_18_0
top.shapes(soi2).insert(soi2_region)

# 6/0: 19/0
top.shapes(ndope).insert(region_19_0)

# 7/0: 19/0
top.shapes(pdope).insert(region_19_0)

layout.write(f"{input_dir}/a_{MASK_RUN_NUM}_merged.gds")

###########################
# SEPARATE BY WAFERS
###########################

########
# FAB1
########

fab1_layout = pya.Layout()
fab1_top = fab1_layout.create_cell("TOP")

fab1_soi1 = fab1_layout.layer(0, 0)
fab1_poly1 = fab1_layout.layer(1, 0)
fab1_metal1 = fab1_layout.layer(2, 0)
fab1_layer43 = fab1_layout.layer(43, 0)

merged_soi1 = pya.Region(top.shapes(soi1))
merged_pol1 = pya.Region(top.shapes(poly1))
merged_metal1 = pya.Region(top.shapes(metal1))
merged43 = pya.Region(top.shapes(layer_43))

fab1_top.shapes(fab1_soi1).insert(merged_soi1)
fab1_top.shapes(fab1_poly1).insert(merged_pol1)
fab1_top.shapes(fab1_metal1).insert(merged_metal1)
fab1_top.shapes(fab1_layer43).insert(merged43)

# scale all by 5 and flip horizontally
for layer in [fab1_soi1, fab1_poly1, fab1_metal1, fab1_layer43]:
   fab1_top.shapes(layer).transform(db.ICplxTrans(5.0, 0, False, 0, 0)) 
   fab1_top.shapes(layer).transform(pya.Trans.M90) 

dbu = layout.dbu

print(f"Database unit (dbu): {dbu} µm per database unit")

# note: this is after we size it by 5x
bbox = fab1_top.bbox()
x_length = bbox.width()
y_length = bbox.height()

# convert to microns
x_length_microns = x_length * dbu
y_length_microns = y_length * dbu

print(f"x_length: {x_length_microns} µm")
print(f"y_length: {y_length_microns} µm")

# move a copy of 0/0, 1/0, 2/0 (and 43/0) to -1.5 times the y length of the layout
for layer in [fab1_soi1, fab1_poly1, fab1_metal1, fab1_layer43]:
   fab1_top.shapes(layer).transform(pya.Trans(0, -y_length))  

# add layer 43 to each layer in the file
fab1_43 = pya.Region(fab1_top.shapes(fab1_layer43))
for layer in [fab1_soi1, fab1_poly1]:
   fab1_top.shapes(layer).insert(fab1_43)

fab1_layout.write(f"{input_dir}/a_{MASK_RUN_NUM}_fab1.gds")

########
# FAB2
########
fab2_layout = pya.Layout()
fab2_top = fab2_layout.create_cell("TOP")

fab2_metal2 = fab2_layout.layer(3, 0)
fab2_poly2 = fab2_layout.layer(4, 0)
fab2_soi2 = fab2_layout.layer(5, 0)
fab2_layer43 = fab2_layout.layer(43, 0)

merged_metal2 = pya.Region(top.shapes(metal2))
merged_poly2 = pya.Region(top.shapes(poly2))
merged_soi2 = pya.Region(top.shapes(soi2))
merged43 = pya.Region(top.shapes(layer_43))

fab2_top.shapes(fab2_metal2).insert(merged_metal2)
fab2_top.shapes(fab2_poly2).insert(merged_poly2)
fab2_top.shapes(fab2_soi2).insert(merged_soi2)
fab2_top.shapes(fab2_layer43).insert(merged43)

# image the layout for wafer 2 by flipping 3/0, 4/0, 5/0 horizontally
for layer in [fab2_metal2, fab2_poly2, fab2_soi2]:
    shapes = pya.Region(fab2_top.shapes(layer))
    shapes.transform(pya.Trans.M90)
    fab2_top.shapes(layer).clear()
    fab2_top.shapes(layer).insert(shapes)

# scale all by 5 and flip horizontally (this time including 43/0)
for layer in [fab2_metal2, fab2_poly2, fab2_soi2, fab2_layer43]:
   fab2_top.shapes(layer).transform(db.ICplxTrans(5.0, 0, False, 0, 0))
   fab2_top.shapes(layer).transform(pya.Trans.M90)

# move a copy of 3/0, 4/0, 5/0 (and 43/0) to -1.5 times both the x and y lengths of the layout
for layer in [fab2_metal2, fab2_poly2, fab2_soi2, fab2_layer43]:
   fab2_top.shapes(layer).transform(pya.Trans(-x_length, -y_length))

# add layer 43 to each layer in the file
fab2_43 = pya.Region(fab2_top.shapes(fab2_layer43))
for layer in [fab2_poly2, fab2_soi2]:
   fab2_top.shapes(layer).insert(fab2_43)

fab2_layout.write(f"{input_dir}/a_{MASK_RUN_NUM}_fab2.gds")

#############################################
# MAKE MASK MLA150 READY - FLIP POLARITIES
#############################################

def flip_polarity(curr_layer, name, curr_top, export_dir, mask_run_num):
   flipped_layout = pya.Layout()
   flipped_top = flipped_layout.create_cell("TOP")

   flipped_layer = flipped_layout.layer(0, 0)  # 0/0
   bg = flipped_layout.layer(0, 1)  # 0/1

   region_to_flip = pya.Region(curr_top.shapes(curr_layer))
   bbox_flipped = region_to_flip.bbox()

   # rectangle the size of the bounding box on 0/1 layer
   rectangle = pya.Box(bbox_flipped)
   flipped_top.shapes(bg).insert(rectangle)

   # 0/0 = 0/1 - 0/0
   flipped = pya.Region(flipped_top.shapes(bg)) - region_to_flip
   flipped_top.shapes(flipped_layer).insert(flipped)
    
   flipped_layout.write(f"{export_dir}/a_{mask_run_num}_{name}.gds")

# 0/0, 1/0, 4/0, 5/0: flip polarity and save as separate files as _soi1/poly1/poly2/soi2.gds 
flip_polarity(fab1_soi1, "soi1", fab1_top, export_dir, MASK_RUN_NUM)
flip_polarity(fab1_poly1, "poly1", fab1_top, export_dir, MASK_RUN_NUM)
flip_polarity(fab2_poly2, "poly2", fab2_top, export_dir, MASK_RUN_NUM)
flip_polarity(fab2_soi2, "soi2", fab2_top, export_dir, MASK_RUN_NUM)

def flip_43(flip_43, name, curr_top, curr_layer, export_dir, mask_run_num):
   flipped_layout = pya.Layout()
   flipped_top = flipped_layout.create_cell("TOP")

   flipped_layer = flipped_layout.layer(0, 0)  # 0/0
   bg = flipped_layout.layer(0, 1)  # 0/1

   region_to_flip = pya.Region(curr_top.shapes(flip_43))
   bbox_flipped = region_to_flip.bbox()

   # rectangle the size of the bounding box on 0/1 layer
   rectangle = pya.Box(bbox_flipped)
   flipped_top.shapes(bg).insert(rectangle)

   # 0/0 = 0/1 - 0/0
   flipped = pya.Region(flipped_top.shapes(bg)) - region_to_flip
   flipped_top.shapes(flipped_layer).insert(flipped)
   flipped_top.shapes(flipped_layer).insert(pya.Region(curr_top.shapes(curr_layer)))

   flipped_layout.write(f"{export_dir}/a_{mask_run_num}_{name}.gds")

# 2/0, 3/0, 6/0, 7/0: DO NOT flip polarity (except alignment key 43) and save as separate files as _metal1/metal2/ndope/pdope.gds 
flip_43(fab1_layer43, "metal1", fab1_top, fab1_metal1, export_dir, MASK_RUN_NUM)
flip_43(fab2_layer43, "metal2", fab2_top, fab2_metal2, export_dir, MASK_RUN_NUM)