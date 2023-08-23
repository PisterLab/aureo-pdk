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


($exmpl, $num_inputs, $num_outputs, $iter_start, $iter_end, $model_src) = @ARGV;
  
$model_gen_src = $model_src;

$pos = rindex($0, "/");
if ($pos == -1) {
  $script_src = ".";
}
else {
  $script_src = substr($0, 0, $pos);
}


$errfile = "$exmpl".".err";
$tmpfile = "$exmpl".".tmp";

`$model_gen_src net-pred itn $exmpl.net $iter_start: > $errfile`;
`perl $script_src/check_results.pl $errfile $tmpfile $num_inputs $num_outputs .01`;
