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


($dir, $num_inputs, $num_outputs) = @ARGV;

use Cwd;
$cur_dir = cwd;
chdir($dir);

$datafile = $dir.".dat";
$gz_datafile = $datafile.".gz";

$tmpfile = $datafile."_raw";
if (-e $datafile) {
  use File::Copy;
  copy($datafile, $tmpfile);
}
elsif (-e $gz_datafile) {
  `gunzip $gz_datafile`;
  use File::Copy;
  copy($datafile, $tmpfile);
}
else {
  die "File does not exist\n";
}

$num_cols = $num_inputs + $num_outputs;

open(in, $tmpfile);
open(out, ">$datafile");
while(<in>) {

  @Fld = split(' ', $_, 1000);
  if ($Fld[1] == 0. && $Fld[3] == 0.) {
    ;
  }
  elsif ($Fld[1] == 0.) {
    for ($i = 0; $i < $num_cols; ++$i) {
      $Fld1[$i] = $Fld[$i];
    }
    $Fld1[1] = $Fld1[3];
    $Fld1[2] = -$Fld1[4];
    $Fld1[3] = $Fld1[4] = 0;
    if ($num_outputs == 5) {
      $Fld1[$num_inputs + 2] = $Fld1[$num_inputs + 3];
      $Fld1[$num_inputs + 3] = 0;
    }
    else {
      $Fld1[$num_inputs + 1] = $Fld1[$num_inputs + 2];
      $Fld1[$num_inputs + 2] = 0;
    }
    for ($i = 0; $i < $num_cols; ++$i) {
      printf out "%.6f ", $Fld1[$i];
    }
    printf out "\n";
  }
  elsif ($Fld[3] == 0.) {
    for ($i = 0; $i < $num_cols; ++$i) {
      $Fld1[$i] = $Fld[$i];
    }
    $Fld1[3] = $Fld1[1];
    $Fld1[4] = -$Fld1[2];
    $Fld1[1] = $Fld1[2] = 0;
    if ($num_outputs == 5) {
      $Fld1[$num_inputs + 3] = $Fld1[$num_inputs + 2];
      $Fld1[$num_inputs + 2] = 0;
    }
    else {
      $Fld1[$num_inputs + 2] = $Fld1[$num_inputs + 1];
      $Fld1[$num_inputs + 1] = 0;
    }
    for ($i = 0; $i < $num_cols; ++$i) {
      printf out "%.6f ", $Fld1[$i];
    }
    printf out "\n";

  }
  
  printf out "%s", $_;

}
close(in);
close(out);

chdir($cur_dir);
