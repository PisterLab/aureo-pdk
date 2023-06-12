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


class Material:

    def __init__(self, name: str, **attrs):
        self.name = name
        self.attrs = attrs

    def getattr(self, name: str, default=None):
        if name in self.attrs:
            return self.attrs[name]
        return default

    def __getitem__(self, item):
        return self.attrs[item]

    def setattr(self, key, value):
        self[key] = value

    def __setitem__(self, key, value):
        self.attrs[key] = value
