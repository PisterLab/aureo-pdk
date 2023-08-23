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

#
#  Converts the old NX techfile format into the new NX techfile 
#  format so that it can be concatenated into the ICECAPS techfile
#  and read in directly through Hpy
#
($old_techfile, $new_techfile) = @ARGV;

if (-e $old_techfile) {
  open(old, $old_techfile);
  open(new, ">$new_techfile");

  while(<old>) {
    @Fld = split(' ', $_, 1000);
    printf new "NX %s", $_;
  }
  close(old);
  close(new);
}
else {
  printf "Techfile %s not found\n", $old_techfile;
}
