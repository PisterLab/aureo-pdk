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


$[ = 1;                 # set array base to 1

($exmpl) = @ARGV;

$out = "$exmpl"."_rnd";
open(infile, $exmpl);
open(trnfile, ">$out");
$max_cols = 0;
$num_samples = 0;
line: while (<infile>) { 
    @Fld = split(' ', $_, 9999);

    if ($#Fld != 0) {
	$num_samples++;
	if ($max_cols < $#Fld) {
	    $max_cols = $#Fld;
	}
	for ($i = 1; $i <= $#Fld; $i++) {
	    $array[$num_samples][$i] = $Fld[$i];
	}
    }
}
close(infile);

srand(1);
for ($i = 1; $i <= $num_samples; $i++) {
    $pos = int rand($num_samples + 1);
    while ($array[$pos][1] == -1) {
	$pos = int rand($num_samples + 1);
    }
    for ($j = 1; $j < $max_cols; $j++) {
	printf trnfile "%.6f  ", $array[$pos][$j];
    }
    printf trnfile "\n";
    $array[$pos][1] = -1;
}
close(trnfile);

