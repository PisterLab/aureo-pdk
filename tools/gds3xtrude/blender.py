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

import logging
from .builder import LayerStackBuilder, Material, DEFAULT_MATERIAL, DEFAULT_COLOR
from typing import Iterable, Tuple
from .gds3xtrude import build_layerstack
import klayout.db as pya
from itertools import count

logger = logging.getLogger(__name__)

try:
    import bpy
except ImportError as e:
    msg = "Module `bpy` not found. Need to call script from blender!"
    logger.error(msg)
    raise e


class BlenderLayerStackBuilder(LayerStackBuilder):

    def __init__(self, scale: float = 0.001):
        self.volumes = []
        self.scale_factor = scale
        self.translation = (0, 0, 0)
        self.counter = count()
        self.materials = dict()

    def get_blender_material(self, m: Material):
        """
        Get or create blender material.
        :param m:
        :return: Blender material.
        """
        if m not in self.materials:
            mat = bpy.data.materials.new(m.name)
            col = tuple(m.getattr('color', DEFAULT_COLOR))
            
            if len(col) == 3:
                col = col + (1,)

            mat.diffuse_color = col
            self.materials[m] = mat

        return self.materials[m]

    def add_polygon(self,
                    hull: Iterable[Tuple[int, int]],
                    holes: Iterable[Iterable[Tuple[int, int]]],
                    z_offset: float,
                    thickness: float,
                    material: Material = DEFAULT_MATERIAL):
        scale = self.scale_factor
        z_offset *= scale
        thickness *= scale

        #  Augment vertex lists with z = z_offset
        hull = [(x * scale, y * scale, z_offset) for x, y in hull]
        holes = [[(x * scale, y * scale, z_offset) for x, y in hole] for hole in holes]

        #  Create edge list for hull and create object
        edges = [[i, i + 1] for i in range(len(hull) - 1)]
        edges.append([len(hull) - 1, 0])

        index = next(self.counter)

        object_name_hull = "hull_{}".format(index)
        bpy.ops.object.select_all(action="DESELECT")


        mesh = bpy.data.meshes.new(object_name_hull)
        mesh.from_pydata(hull, edges, faces=[])

        obj = bpy.data.objects.new(object_name_hull, mesh)
        scene = bpy.context.scene
        scene.collection.objects.link(obj)
        obj.select_set(True)

        # Set material
        obj.active_material = self.get_blender_material(material)
       

        #  Create edge list for holes and create object
        for i, hole in enumerate(holes):
            object_name_hole = "hole.{}.{}".format(index, i)
            edges = [[i, i + 1] for i in range(len(hole) - 1)]
            edges.append([len(hole) - 1, 0])
            mesh = bpy.data.meshes.new(object_name_hole)
            mesh.from_pydata(hole, edges, faces=[])
            obj = bpy.data.objects.new(object_name_hole, mesh)
            scene.collection.objects.link(obj)
            obj.select_set(True)
        
        bpy.context.view_layer.objects.active = bpy.data.objects[object_name_hull]

        # Join all objects (if needed)
        if len(holes) > 0:
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
        

        return obj

    def scale(self, f: float):
        self.scale_factor = f

    def translate(self, t: Tuple[float, float, float]):
        self.translation = t


def load_gds(gds_file: str, layer_stack_file: str):
    logging.basicConfig(format='%(module)16s %(levelname)8s: %(message)s', level=logging.DEBUG)
    layout = pya.Layout()
    logger.info("Reading GDS: %s", gds_file)
    layout.read(gds_file)

    top_cells = layout.top_cells()
    logger.debug('Number of top cells: %d', len(top_cells))

    if len(top_cells) > 1:
        logger.warning('More than one top cells (%d). Taking the largest one. Use `--cell` to select a cell.',
                       len(top_cells))

    # Just take the largest top cell: TODO
    top_cell = max(top_cells, key=lambda cell: cell.bbox().area())

    builder = BlenderLayerStackBuilder()

    build_layerstack(builder=builder,
                     layout=layout,
                     top_cell=top_cell,
                     tech_file=layer_stack_file,
                     approx_error=0)
