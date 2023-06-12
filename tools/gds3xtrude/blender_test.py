##
## Copyright (c) 2018-2019 Thomas Kramer.
## 
## This file is part of gds3xtrude 
## (see https://codeberg.org/tok/gds3xtrude).
## 
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU Affero General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU Affero General Public License for more details.
## 
## You should have received a copy of the GNU Affero General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.
##
import bpy
import bmesh
import numpy as np
import pya
from .polygon_approx import approximate_polygon


def create_bmesh(polygon, z_offset=0):
    bm = bmesh.new()
    for x, y in hull:
        bm.verts.new((x, y, z_offset))
    bm.faces.new(bm.verts)
    bm.normal_update()
    return bm


def _region2blender_objects(region: pya.Region, thickness: float, z_offset=0, approx_error: float = 0):
    """
    """

    mat = bpy.data.materials.new("PKHG")
    mat.diffuse_color = (0.5, 0.0, 1.0)

    volumes = []
    for poly in region.each():
        n_holes = poly.holes()

        approx_hull = approximate_polygon(poly.each_point_hull(), approx_error)
        approx_holes = [approximate_polygon(poly.each_point_hole(i), approx_error)
                        for i in range(n_holes)]

        points_hull = [(p.x, p.y) for p in approx_hull]
        points_holes = [[(p.x, p.y) for p in h] for h in approx_holes]

        bmesh_hull = create_bmesh(points_hull, z_offset=z_offset)
        # Linear extrusion.
        bmesh.ops.solidify(bmesh_hull, geom=bmesh_hull.faces, thickness=thickness)

        mesh = bpy.data.meshes.new("")
        bmesh_hull.to_mesh(mesh)
        bmesh_hull.free()
        ob = bpy.data.objects.new("polygon", mesh)
        ob.active_material = mat

        volumes.append(ob)

    return volumes


scene = bpy.context.scene

thickness = 1
hull = [(0, 0), (10, 0), (10, 10), (0, 10)]
holes = [
    [(1, 1), (2, 1), (2, 2), (1, 2)],
    [(4, 4), (5, 4), (5, 5), (4, 5)]
]

mat = bpy.data.materials.new("PKHG")
mat.diffuse_color = (0.5, 0.0, 1.0)

bm = bmesh.new()
for x, y in hull:
    z = 0
    bm.verts.new((x, y, z))

bm.faces.new(bm.verts)
bm.normal_update()

# bms = []
# for p in polys:
#     bm = bmesh.new()
#     for x, y in p:
#         z = 0
#         bm.verts.new((x, y, z))
#     bm.faces.new(bm.verts)
#     bm.normal_update()
#     bms.append(bm)

# Extrude
thickness = 1
bmesh.ops.solidify(bm, geom=bm.faces, thickness=thickness)

me = bpy.data.meshes.new("")
bm.to_mesh(me)
bm.free()

ob = bpy.data.objects.new("polygon", me)
ob.active_material = mat

scene.objects.link(ob)
scene.update()

# Test 2
hull = [(0, 0), (10, 0), (10, 10), (0, 10)]
holes = [
    [(1, 1), (2, 1), (2, 2), (1, 2)],
    # [(4, 4), (5, 4), (5, 5), (4, 5)]
]


def add_z(p2: np.ndarray, z: float):
    zs = np.zeros((len(p2), 1)) + z
    p3 = np.append(p2, zs, axis=1)
    return p3


def window2(a: np.ndarray):
    l = len(a)
    idx1 = np.arange(l)
    idx2 = (idx1 + 1) % l
    return a[idx1], a[idx2]


hull = np.array(hull)
holes = np.array(holes)

# hole_verts2 = np.concatenate(holes)
# verts2 = np.concatenate((hull, hole_verts2))

_index = 0

verts = []


def create_indices(array: np.ndarray) -> np.ndarray:
    global _index
    global verts
    verts.append(array)
    l = len(array)
    idx = np.arange(_index, _index + l)
    _index += l
    return idx


hull_bottom = add_z(hull, 0)
hull_bottom_indices = create_indices(hull_bottom)
# hull_top = add_z(hull, 1)
# hull_top_indices = create_indices(hull_top)

holes_bottom = [add_z(hole[::-1], 0) for hole in holes]
# holes_top = [add_z(hole[::-1], 1) for hole in holes]
holes_bottom_indices = [create_indices(hole) for hole in holes_bottom]
# holes_top_indices = [create_indices(hole) for hole in holes_top]

edges = []

verts = list(np.concatenate(verts))

faces = [np.concatenate([hull_bottom_indices] + holes_bottom_indices),
         # np.concatenate([hull_top_indices] + holes_top_indices),
         ]
faces = [list(f) for f in faces]
#
# edges = []
# verts = [(1.0, 0.9999999403953552, -1.0), (1.0, -1.0, -1.0), (-1.0000001192092896, -0.9999998211860657, -1.0),
#          (-0.9999996423721313, 1.0000003576278687, -1.0), (-0.7993143200874329, 7.718172128079459e-07, -1.0),
#          (-0.7839558124542236, -0.1559378057718277, -1.0), (-0.7384703755378723, -0.3058837354183197, -1.0),
#          (-0.6646059155464172, -0.4440747797489166, -1.0), (-0.565200924873352, -0.5652002096176147, -1.0),
#          (-0.44407564401626587, -0.6646053194999695, -1.0), (-0.3058846890926361, -0.7384699583053589, -1.0),
#          (-0.15593880414962769, -0.7839556336402893, -1.0), (-2.6044966716654017e-07, -0.7993143200874329, -1.0),
#          (0.1559382975101471, -0.7839557528495789, -1.0), (0.3058842122554779, -0.738470196723938, -1.0),
#          (0.44407519698143005, -0.6646056175231934, -1.0), (0.5652005672454834, -0.5652005672454834, -1.0),
#          (0.6646056175231934, -0.44407519698143005, -1.0), (0.7384701371192932, -0.3058842122554779, -1.0),
#          (0.7839557528495789, -0.15593838691711426, -1.0), (0.7993143200874329, 6.034655086750718e-08, -1.0),
#          (0.7839556932449341, 0.1559385061264038, -1.0), (0.7384701371192932, 0.30588433146476746, -1.0),
#          (0.6646056175231934, 0.44407519698143005, -1.0), (0.5652005672454834, 0.5652005672454834, -1.0),
#          (0.44407525658607483, 0.6646055579185486, -1.0), (0.30588436126708984, 0.7384701371192932, -1.0),
#          (0.15593849122524261, 0.7839556932449341, -1.0), (0.0, 0.7993143200874329, -1.0),
#          (-0.1559372842311859, 0.7839559316635132, -1.0), (-0.3058832585811615, 0.7384706139564514, -1.0),
#          (-0.4440743327140808, 0.6646061539649963, -1.0), (-0.5651998519897461, 0.5652012825012207, -1.0),
#          (-0.6646050214767456, 0.4440760612487793, -1.0), (-0.7384697794914246, 0.3058851659297943, -1.0),
#          (-0.7839555740356445, 0.15593931078910828, -1.0), (1.0000004768371582, 0.999999463558197, 1.0),
#          (-0.9999999403953552, 1.0, 1.0), (0.9999993443489075, -1.0000005960464478, 1.0),
#          (-1.0000003576278687, -0.9999996423721313, 1.0), (-2.6044966716654017e-07, -0.7993143200874329, 1.0),
#          (-0.15593880414962769, -0.7839556336402893, 1.0), (-0.3058846890926361, -0.7384699583053589, 1.0),
#          (-0.44407564401626587, -0.6646053194999695, 1.0), (-0.565200924873352, -0.5652002096176147, 1.0),
#          (-0.6646059155464172, -0.4440747797489166, 1.0), (-0.7384703755378723, -0.3058837354183197, 1.0),
#          (-0.7839558124542236, -0.1559378057718277, 1.0), (-0.7993143200874329, 7.718172128079459e-07, 1.0),
#          (-0.7839555740356445, 0.15593931078910828, 1.0), (-0.7384697794914246, 0.3058851659297943, 1.0),
#          (-0.6646050214767456, 0.4440760612487793, 1.0), (-0.5651998519897461, 0.5652012825012207, 1.0),
#          (-0.4440743327140808, 0.6646061539649963, 1.0), (-0.3058832585811615, 0.7384706139564514, 1.0),
#          (-0.1559372842311859, 0.7839559316635132, 1.0), (0.0, 0.7993143200874329, 1.0),
#          (0.15593849122524261, 0.7839556932449341, 1.0), (0.30588436126708984, 0.7384701371192932, 1.0),
#          (0.44407525658607483, 0.6646055579185486, 1.0), (0.5652005672454834, 0.5652005672454834, 1.0),
#          (0.6646056175231934, 0.44407519698143005, 1.0), (0.7384701371192932, 0.30588433146476746, 1.0),
#          (0.7839556932449341, 0.1559385061264038, 1.0), (0.7993143200874329, 6.034655086750718e-08, 1.0),
#          (0.7839557528495789, -0.15593838691711426, 1.0), (0.7384701371192932, -0.3058842122554779, 1.0),
#          (0.6646056175231934, -0.44407519698143005, 1.0), (0.5652005672454834, -0.5652005672454834, 1.0),
#          (0.44407519698143005, -0.6646056175231934, 1.0), (0.3058842122554779, -0.738470196723938, 1.0),
#          (0.1559382975101471, -0.7839557528495789, 1.0)]
# faces = [(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19),
#          (0, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 4, 3), (36, 0, 3, 37), (0, 36, 38, 1),
#          (1, 38, 39, 2), (2, 39, 37, 3),
#          (36, 37, 39, 38, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55),
#          (36, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 40, 38), (28, 27, 57, 56),
#          (29, 28, 56, 55), (27, 26, 58, 57), (30, 29, 55, 54), (26, 25, 59, 58), (31, 30, 54, 53), (25, 24, 60, 59),
#          (32, 31, 53, 52), (24, 23, 61, 60), (33, 32, 52, 51), (23, 22, 62, 61), (34, 33, 51, 50), (22, 21, 63, 62),
#          (35, 34, 50, 49), (21, 20, 64, 63), (4, 35, 49, 48), (20, 19, 65, 64), (5, 4, 48, 47), (19, 18, 66, 65),
#          (6, 5, 47, 46), (18, 17, 67, 66), (7, 6, 46, 45), (17, 16, 68, 67), (8, 7, 45, 44), (16, 15, 69, 68),
#          (9, 8, 44, 43), (15, 14, 70, 69), (10, 9, 43, 42), (14, 13, 71, 70), (11, 10, 42, 41), (13, 12, 40, 71),
#          (12, 11, 41, 40)]

mesh = bpy.data.meshes.new(name="mesh with hole")
mesh.from_pydata(verts, edges, faces)

ob = bpy.data.objects.new("test", mesh)
scene.objects.link(ob)
