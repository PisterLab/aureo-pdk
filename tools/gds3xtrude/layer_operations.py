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

import operator


class LayerOp:
    def __init__(self, op, lhs, rhs):
        self.op = op
        self.lhs = lhs
        self.rhs = rhs

    def eval(self):
        pass

    def __add__(self, other):
        return LayerOp(operator.add, self, other)

    def __or__(self, other):
        return LayerOp(operator.add, self, other)

    def __and__(self, other):
        return LayerOp(operator.iand, self, other)

    def __sub__(self, other):
        return LayerOp(operator.sub, self, other)

    def __xor__(self, other):
        return LayerOp(operator.xor, self, other)


class Leaf(LayerOp):
    def __init__(self, val):
        self.val = val

    def eval(self):
        return self.val


class AbstractLayer(Leaf):

    def __init__(self, layer_num, layer_purpose, material=None):
        self.layer_num = layer_num
        self.layer_purpose = layer_purpose
        self.material = material

    def eval(self):
        return self.layer_num, self.layer_purpose, self.material
