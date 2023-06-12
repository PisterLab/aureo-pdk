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

from typing import Iterable, Tuple
from .types import Material

# klayout.db should not be imported if script is run from KLayout GUI.
try:
    # Try to import pya if run inside KLayout GUI
    import pya
except:
    import klayout.db as pya

DEFAULT_COLOR = (0.5, 0.5, 0.5)

DEFAULT_MATERIAL = Material("DEFAULT_MATERIAL")


class LayerStackBuilder:

    def add_polygon(self,
                    hull: Iterable[Tuple[int, int]],
                    holes: Iterable[Iterable[Tuple[int, int]]],
                    z_offset: float,
                    thickness: float,
                    material: Material = DEFAULT_MATERIAL):
        pass

    def add_region(self, region: pya.Region,
                   z_offset: float,
                   thickness: float,
                   material: Material = DEFAULT_MATERIAL
                   ):
        """ Convert a layer to volumes by extruding the polygons in z direction.
        """

        for poly in region.each():
            n_holes = poly.holes()

            # Convert KLayout Points into tuples.
            points_hull = [(p.x, p.y) for p in poly.each_point_hull()]
            points_holes = [[(p.x, p.y) for p in poly.each_point_hole(i)] for i in range(n_holes)]

            self.add_polygon(points_hull, points_holes,
                             z_offset=z_offset,
                             thickness=thickness,
                             material=material)

    def translate(self, t: Tuple[float, float, float]):
        """
        Translate the whole object by a vector.
        :param t:
        :return:
        """
        pass

    def scale(self, f: float):
        """
        Scale the whole object by a factor.
        :param f:
        :return:
        """
        pass


class ApproximateLayerStackBuilder(LayerStackBuilder):
    """
    Wraps any `LayerStackBuilder` by approximating and simplifying all polygons first before passing them to the builder.
    """

    def __init__(self, layer_stack_builder: LayerStackBuilder, approx_error: float
                 ):
        self.builder = layer_stack_builder
        self.approx_error = approx_error

    def add_region(self, region: pya.Region,
                   z_offset: float,
                   thickness: float,
                   material: Material = DEFAULT_MATERIAL
                   ):
        """ Convert a layer to volumes by extruding the polygons in z direction.
        """

        smooth = region.smoothed(self.approx_error)

        self.builder.add_region(smooth,
                                z_offset=z_offset,
                                thickness=thickness,
                                material=material)
