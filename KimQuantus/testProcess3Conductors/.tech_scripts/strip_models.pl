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
GetOptions("ext=s", "old=s", "new=s", "delta=s");

(-e $opt_old) || die "Techfile not found in default path\n";

$string = "NX NX $opt_ext";
open(old, $opt_old);
open(new, ">$opt_new");
open(delta, ">$opt_delta");
$found_flag == 0;
while (<old>) {
  if (/$string/) {
    $found_flag = 1;
  }
  if ($found_flag == 0) {
    printf new $_;
  }
  elsif ($found_flag == 1) {
    if (/NX NX /) {
      if (/$string/) {
	printf delta $_;
      }
      else {
	$found_flag = 0;
        printf new $_;
      }
    }
    else {
      printf delta $_;
    }
  }
}
close(old);
close(new);
close(delta);

