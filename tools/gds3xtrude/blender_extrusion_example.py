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

thickness = 1
hull = [(0, 0), (10, 0), (10, 10), (0, 10), (-5, 8), (-5, 2)]
holes = [
    [(1, 1), (2, 1), (2, 2), (1, 2), (0.5, 1.5)],
    [(4, 4), (5, 4), (5, 5), (4, 5)]
]

#  Augment vertex lists with z = 0
for i in range(len(hull)):
    hull[i] = hull[i] + (0,)

for hole in holes:
    for i in range(len(hole)):
        hole[i] = hole[i] + (0,)

#  Create edge list for hull and create object
edges = [[i, i + 1] for i in range(len(hull) - 1)]
edges.append([len(hull) - 1, 0])

mesh = bpy.data.meshes.new("hull")
mesh.from_pydata(hull, edges, faces=[])
mesh.update()
obj = bpy.data.objects.new("hull", mesh)
scene = bpy.context.scene
scene.objects.link(obj)

#  Create edge list for holes and create object
for hole in holes:
    edges = [[i, i + 1] for i in range(len(hole) - 1)]
    edges.append([len(hole) - 1, 0])
    mesh = bpy.data.meshes.new("hole.000")
    mesh.from_pydata(hole, edges, faces=[])
    mesh.update()
    obj = bpy.data.objects.new("hole.000", mesh)
    scene.objects.link(obj)

# Join all objects
bpy.ops.object.select_all(action='TOGGLE')
bpy.context.scene.objects.active = bpy.data.objects["hull"]
bpy.ops.object.join()
#  Create faces using fill command
bpy.ops.object.editmode_toggle()
bpy.ops.mesh.fill()
bpy.ops.mesh.select_mode(type='FACE')
bpy.ops.mesh.select_all(action='SELECT')

#  Extrude faces
bpy.ops.mesh.extrude_region_move(
    TRANSFORM_OT_translate={"value": (0, 0, thickness)}
)

bpy.ops.object.editmode_toggle()
