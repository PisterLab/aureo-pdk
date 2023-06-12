#!/usr/bin/env python3
#
# Copyright (c) 2018 Thomas Kramer.
#
# This file is part of gds3xtrude
# (see https://teahub.io/miaou/gds3xtrude).
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#


"""
gds3xtrude stand alone command line tool.
"""
from solid import scad_render, scad_render_to_file
from gds3xtrude.openscad import render_scad

import tempfile
import subprocess
import logging

if __name__ == '__main__':
    import argparse
    import klayout.db as pya

    # List of supported CAD tools.
    cad_tools = [
        'blender',
        'openscad'
    ]

    logger = logging.getLogger(__name__)

    parser = argparse.ArgumentParser(description='Convert a GDS layout to OpenSCAD for 3D visualization.')
    parser.add_argument('-i', '--input', required=True, metavar='GDS', type=str, help='GDS file')

    parser.add_argument('--cell', default=None, metavar='CELL_NAME', type=str, help='name of the cell')

    parser.add_argument('-o', '--output', required=False, metavar='FILE', type=str, help='output file')
    parser.add_argument('-t', '--tech', required=True, metavar='FILE', type=str, help='layer stack description file')
    parser.add_argument('--approx', metavar='MAX_ERR', type=float, default=0,
                        help='approximate polygons allowing a maximum deviation from the original')
    parser.add_argument('--center', action='store_true', help='move the center of the layout to (0, 0)')
    parser.add_argument('--scale', default=1, type=float, help='scale the 3D layout')
    parser.add_argument('--view', action='store_true', help='launch OpenSCAD to display the output file')
    parser.add_argument('-c', '--cad', default='openscad', metavar='CAD_TOOL_NAME', choices=cad_tools,
                        help='name of CAD tool to be used. One of {{{}}}'.format(", ".join(cad_tools)))
    parser.add_argument('--openscad', default='openscad', metavar='EXECUTABLE',
                        help='optionally supply the path to the openscad executable')
    parser.add_argument('--blender', default='blender', metavar='EXECUTABLE',
                        help='optionally supply the path to the blender executable')
    parser.add_argument('-v', '--verbose', action='store_true', help='show more detailed log output')

    args = parser.parse_args()

    # Setup logging
    log_level = logging.INFO
    if args.verbose:
        log_level = logging.DEBUG
    logging.basicConfig(format='%(module)16s %(levelname)8s: %(message)s', level=log_level)

    approx_error = args.approx
    # Create temporary file for data transfer to OpenSCAD.
    output_file = None

    want_file_output = args.view or args.output is not None

    cad_tool = args.cad

    gds_path = args.input
    layerstack_path = args.tech

    if cad_tool == 'openscad':

        layout = pya.Layout()
        logger.info("Reading GDS: %s", gds_path)
        layout.read(gds_path)

        if args.cell is None:
            top_cells = layout.top_cells()
            logger.debug('Number of top cells: %d', len(top_cells))

            if len(top_cells) > 1:
                logger.warning('More than one top cells (%d). Taking the largest one. Use `--cell` to select a cell.',
                               len(top_cells))

            # Just take the largest top cell: TODO
            top_cell = max(top_cells, key=lambda cell: cell.bbox().area())
        else:
            top_cell = layout.cell(args.cell)
            if top_cell is None:
                logger.error('No such cell: `%s`', args.cell)
                exit(1)

        scad = render_scad(layout, top_cell, layerstack_path,
                           approx_error=approx_error,
                           centered=args.center,
                           scale_factor=args.scale)

        if want_file_output:
            if args.output:
                output_file = args.output
            else:
                fp, output_file = tempfile.mkstemp(suffix='.scad')

            logger.info('Write SCAD: %s', output_file)
            scad_render_to_file(scad, filepath=output_file, include_orig_code=False)
        else:
            print(scad_render(scad, file_header=''))

        openscad_binary = args.openscad

        if args.view:
            # Run OpenSCAD
            try:
                cmd = [openscad_binary, '--viewall', '--colorscheme=BeforeDawn', output_file]
                logger.debug("Run openscad: %s", " ".join(cmd))
                ret = subprocess.run(cmd)
            except FileNotFoundError as e:
                logger.error("`%s` not found", openscad_binary)
                logger.info("Make sure '{}' is installed and in the current search path.".format("openscad"))

    elif cad_tool == 'blender':

        blender_command = args.blender
        gds_path_esc = gds_path.replace('"', '\"')
        layerstack_path_esc = layerstack_path.replace('"', '\"')
        python_expr = 'import gds3xtrude.blender as gb; gb.load_gds("{}", "{}")'.format(gds_path_esc,
                                                                                        layerstack_path_esc)
        # Run Blender
        try:
            cmd = [blender_command, '--python-expr', python_expr]
            logger.debug("Run blender: {}".format(" ".join(cmd)))
            ret = subprocess.run(cmd)
        except FileNotFoundError as e:
            logger.error("`%s` not found", blender_command)
            logger.info("Make sure '{}' is installed and in the current search path.".format("blender"))
    else:
        msg = "CAD tool is not supported: {}".format(cad_tool)
        logger.error(msg)
        raise Exception(msg)
