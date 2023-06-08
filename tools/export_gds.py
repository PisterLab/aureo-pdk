# export_masks.py - Given a library and cellview, export_fab.py will stream out a GDSII file
# with all the drawn layers present. It will first ensure that SOI layers have been split about
# the SOIHOLE layers (see aureo.il file).

import argparse
import subprocess, os
import gdspy

# Define and parse command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('--lib', help='Library name')
parser.add_argument('--cell', help='Cell view name')
args = parser.parse_args()

# Call Cadence Virtuoso to stream out the GDS file
arg_env = os.environ.copy()
arg_env['GDS_LIB'] = args.lib
arg_env['GDS_CELL'] = args.cell
arg_env['GDS_FILE'] = os.getcwd() + "/" + args.cell + '_preprocess.gds'
subprocess.Popen(["virtuoso", "-nograph", "-restore", "tools/stream_gds.il", args.lib, args.cell], env=arg_env).wait()
