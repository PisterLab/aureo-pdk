######################################################################
#
#  CdnLglNtc    [ Copyright (c) 2002-2005
#               | Cadence Design Systems, Inc. All rights reserved.
#               |
#               | THIS PROGRAM IS CONFIDENTIAL AND PROPRIETARY
#               | TO CADENCE DESIGN SYSTEMS, INC. AND CONSTITUTES
#               | A VALUABLE TRADE SECRET.
#               |
#               | This work may not be copied, modified, re-published,
#               | uploaded, executed, or distributed in any way, in any
#               | medium, whether in whole or in part, without prior
#               | written permission from Cadence Design Systems, Inc.
#               ]
#  Synopsis     [ Convert old-style notices to new style ]
#  Description  [ Has meta knowledge of historical stuff at Simplex,
#                 such as the old CPP_EMBED_NOTICES convention.
#
#                 Requires the code was reasonably compliant with the
#                 old standard.
#               ]
########################################################################


use Getopt::Long;
GetOptions("src=s", "dest:s");

if (!$opt_src) {
  printf "Usage: <Script_name> <file to be converted> <destination file:optional>\n";
  die;
}

if (!$opt_dest) {
  $dest_file = "____tmp";
}
else {
  $dest_file = $opt_dest;
}

$src_file = $opt_src;
open(in, $src_file);
open(out, ">$dest_file");
while(<in>) {

  while (index($_, "\t") != -1) {
    s/\t/    /;
  }
  printf out "%s", $_;
}
close(in);
close(out);

if ($dest_file eq "____tmp") {
  use File::Copy;
  copy($dest_file, $src_file);
  unlink($dest_file);
}
