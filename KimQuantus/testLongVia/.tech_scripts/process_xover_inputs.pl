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
GetOptions("prof=s", "out=s", "nbors:i");

use Cwd;
$cur_dir = cwd;

chdir($opt_prof);
$data_file = $opt_prof.".dat";

if (!($opt_nbors == 1 || $opt_nbors == 3)) {
  die "nbors = $opt_nbors illegal\n";
}

open(in, $data_file);
open(out, ">$opt_out");
while (<in>) {
  @Fld = split(' ', $_, 1000);
  
  if ($#Fld < 10) {
    if ($opt_nbors == 1) {
      printf out "%s %s %s %s\n", $Fld[0], $Fld[1], $Fld[2], 100 * $Fld[5];
    }
    elsif ($opt_nbors == 3) {
      printf out "%s %s %s %s %s %s %s %s %s %s %s %s\n", $Fld[0], $Fld[1], $Fld[2], 100 * $Fld[5], 100 * $Fld[4];
    }

  }
  else {
    if ($opt_nbors == 1) {
      printf out "%s %s %s %s %s %s %s %s %s %s %s\n", $Fld[0], $Fld[1], $Fld[2], $Fld[3], $Fld[4], $Fld[5], $Fld[6], 100 * $Fld[9], 100 * $Fld[10], 100 * $Fld[11], 100 * $Fld[12];
    }
    elsif ($opt_nbors == 3) {
      printf out "%s %s %s %s %s %s %s %s %s %s %s %s\n", $Fld[0], $Fld[1], $Fld[2], $Fld[3], $Fld[4], $Fld[5], $Fld[6], 100 * $Fld[9], 100 * $Fld[8], 100 * $Fld[10], 100 * $Fld[11], 100 * $Fld[12];
    }
  }

}
close(in);
close(out);
