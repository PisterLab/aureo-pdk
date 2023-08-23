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


($techfile) = @ARGV;

for ($i = 0; $i < 100; ++$i) {
  $model_cnt[$i] = 0;
}

open(tech, $techfile);
while(<tech>) {
  if (/NX NX/) {
    @Fld = split(' ', $_, 1000);

    $model_cnt[$Fld[2]] += 1;
  }
}
close(tech);

for ($i = 0; $i < 100; ++$i) {
  if ($model_cnt[$i] > 0) {
    printf "Number of NX %d models = %d\n", $i, $model_cnt[$i];
  }
}
