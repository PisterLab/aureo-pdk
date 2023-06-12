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

from .layer_operations import AbstractLayer
from typing import Tuple, Optional
from .types import Material


def layer(idx: int,
          purpose: int = 0,
          material: Material = None) -> AbstractLayer:
    """ Get a handle to a layer by layer number.
    :param idx: GDS layer number or a string of the form '1/0'.
    :param purpose: GDS layer purpose.
    :param color: The color of the layer in the 3D model.
    :return: Handle to the layer.
    """

    # Allow idx to be a string like '1/0'.
    if isinstance(idx, str):
        s = idx.split('/', 2)
        a, b = s
        idx = int(a)
        purpose = int(b)

    if material is None:
        material = Material("<unnamed>")

    return AbstractLayer(idx, purpose, material=material)
