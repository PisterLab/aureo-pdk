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


($src_dir) = @ARGV;

$script_dir = substr($0, 0, rindex($0, "/"));
@cfiles = split('\n', `ls $src_dir/*.c`);
foreach $input (@cfiles) {
  printf "%s\n", $input;
  `perl $script_dir/tabs2spaces.pl -src $input`;
}

@cppfiles = split('\n', `ls $src_dir/*.cpp`);
foreach $input (@cppfiles) {
  printf "%s\n", $input;
  `perl $script_dir/tabs2spaces.pl -src $input`;
}

@hfiles = split('\n', `ls $src_dir/*.h`);
foreach $input (@hfiles) {
  printf "%s\n", $input;
  `perl $script_dir/tabs2spaces.pl -src $input`;
}
