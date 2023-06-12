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

from .gds3xtrude import LayerStackBuilder, build_layerstack, DEFAULT_COLOR, DEFAULT_MATERIAL
from typing import Iterable, Tuple, Dict, Optional
from .types import Material
from solid import *
from solid import utils

# klayout.db should not be imported if script is run from KLayout GUI.
try:
    # Try to import pya if run inside KLayout GUI
    import pya
except:
    import klayout.db as pya

import logging

logger = logging.getLogger(__name__)


class OpenSCADLayerStackBuilder(LayerStackBuilder):

    def __init__(self):
        self.volumes = []
        self.scale_factor = 1
        self.translation = (0, 0, 0)

    def add_polygon(self,
                    hull: Iterable[Tuple[int, int]],
                    holes: Iterable[Iterable[Tuple[int, int]]],
                    z_offset: float,
                    thickness: float,
                    material: Material = DEFAULT_MATERIAL):
        solid_hull = polygon(hull)
        solid_holes = [polygon(h) for h in holes]

        if len(holes) > 0:
            solid_poly = difference()(solid_hull, *solid_holes)
        else:
            solid_poly = solid_hull

        volume = linear_extrude(thickness)(solid_poly)
        volume = utils.up(z_offset)(volume)
        volume = color(material.getattr('color', DEFAULT_COLOR))(volume)

        self.volumes.append(volume)

    def scale(self, f: float):
        self.scale_factor = f

    def translate(self, t: Tuple[float, float, float]):
        self.translation = t

    def build_volume(self):
        volume = scale(self.scale_factor)(
            translate(self.translation)(
                union()(*self.volumes)
            )
        )
        return volume


def render_scad_to_file(layout: pya.Layout,
                        top_cell: pya.Cell,
                        tech_file: str,
                        output_file: str,
                        **kw):
    """ Same as `render_scad` but write the output directly to a file.
    :param layout:  pya.Layout
    :param top_cell: pya.Cell
    :param tech_file:   Path to description of the layer stack.
    :param output_file: Path to OpenSCAD output file.
    :param approx_error:    Approximate polygons before conversion.
    :param material_map:   Mapping from layer number to materials. Dict[(int, int), Material]
    :param centered:    Move the center of the layout to (0, 0).
    :param scale_factor:    Scale the layout before conversion.
    :param selection_box: An optional pya.Box to select which part of the layout should be converted to masks.
    :return: None
    """

    volume = render_scad(layout, top_cell, tech_file, **kw)

    logger.info("Writing SCAD: %s", output_file)
    scad_render_to_file(volume, filepath=output_file)


def render_scad(layout: pya.Layout,
                top_cell: pya.Cell,
                tech_file,
                approx_error: float = 0,
                material_map: Optional[Dict[Tuple[int, int], Material]] = None,
                centered: bool = False,
                scale_factor: float = 1,
                selection_box: Optional[pya.Box] = None):
    """ Transform the first pya.Cell in `layout` into a solidpython volume.
    :param layout:  pya.Layout
    :param top_cell: pya.Cell
    :param tech_file:   Path to description of the layer stack.
    :param approx_error:    Approximate polygons before conversion.
    :param material_map:   Mapping from layer number to materials. Dict[(int, int), Material]
    :param centered:    Move the center of the layout to (0, 0).
    :param scale_factor:    Scale the layout before conversion.
    :param selection_box: An optional pya.Box to select which part of the layout should be converted to masks.
    :return: solidpython volume
    """

    builder = OpenSCADLayerStackBuilder()

    build_layerstack(builder=builder,
                     layout=layout,
                     top_cell=top_cell,
                     tech_file=tech_file,
                     approx_error=approx_error,
                     material_map=material_map,
                     centered=centered,
                     scale_factor=scale_factor,
                     selection_box=selection_box)

    volume = builder.build_volume()

    return volume
