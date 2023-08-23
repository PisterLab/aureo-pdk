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


($exmpl, $num_inputs, $num_hidden, $num_outputs, $tr_beg, $tr_end, $tst_beg, $tst_end, $iter, $restart, $model_src) = @ARGV;

use POSIX;
$batch0 = ceil($iter / 5);
$batch1 = 2 * $batch0;
$batch2 = 3 * $batch0;
$batch3 = 4 * $batch0;

$model_gen_src = $model_src;

$filename = "$exmpl".".net";
if ((-s $filename) && ($restart == 0)) {
    ;
}
else {
    `$model_gen_src/bin/net-spec $exmpl.net $num_inputs  $num_hidden $num_outputs / - 0.05:0.5 0.05:0.5 - x0.05:0.5 - 100`;
    `$model_gen_src/bin/model-spec $exmpl.net real 0.05:0.5`;
    `$model_gen_src/bin/net-spec $exmpl.net`;
    $trans_inputs = "/ ";
    for ($i = 0; $i < $num_inputs; $i++) {
	$trans_inputs = $trans_inputs . "+\@x\@ ";
    }
#$trans_targets = "/ ";
#for ($i = 0; $i < $num_outputs; $i++) {
#  $trans_targets = $trans_targets . "+\@x\@ ";
#}
#`$model_gen_src/bin/data-spec $exmpl.net $num_inputs $num_outputs / $exmpl.dat\@$tr_beg:$tr_end . $exmpl.dat\@$tst_beg:$tst_end . $trans_inputs $trans_targets`;
    `$model_gen_src/bin/data-spec $exmpl.net $num_inputs $num_outputs / $exmpl.dat\@$tr_beg:$tr_end . $exmpl.dat\@$tst_beg:$tst_end . $trans_inputs`;
    `$model_gen_src/bin/net-gen $exmpl.net fix 0.5`;
    `$model_gen_src/bin/mc-spec $exmpl.net repeat 10 sample-noise heatbath hybrid 500:20 0.05`;
    `$model_gen_src/bin/net-mc $exmpl.net 1`;
}
$tmpfile = "$exmpl".".tmp";
$stepsize = 0.35;
for ($i = 2; $i <= $batch0; ++$i) {
  `$model_gen_src/bin/mc-spec $exmpl.net repeat 10 sample-sigmas heatbath hybrid 200:25 $stepsize`;
  `$model_gen_src/bin/net-mc $exmpl.net $i`;

  `$model_gen_src/bin/net-plt t r $exmpl.net > $tmpfile`;
  ($rejection_ratio) = parse_rejection_data($tmpfile);
  if ($rejection_ratio > .3) {
    $stepsize *= .9;
  }
}
 
if ($stepsize > .2) {
    $stepsize *= .7;
}
`$model_gen_src/bin/mc-spec $exmpl.net repeat 10 sample-sigmas heatbath hybrid 200:20 $stepsize`;
`$model_gen_src/bin/net-mc $exmpl.net $batch1`;
if ($stepsize > .15) {
    $stepsize *= .4;
}

$convergence_achieved = 0;
`$model_gen_src/bin/mc-spec $exmpl.net repeat 10 sample-sigmas heatbath hybrid 200:10 $stepsize`;
for ($i = $batch1 + 1; $i <= $batch2; ++$i) {
  `$model_gen_src/bin/net-plt t E $exmpl.net > $tmpfile`;
  $terminating_iteration = parse_energy_data($tmpfile);
  if ($terminating_iteration < $i) {
    $convergence_achieved = 1;
    last;
  }
  else {
    `$model_gen_src/bin/net-mc $exmpl.net $i`;
  }
}
if ($stepsize > .075) {
    $stepsize *= .5;
}
else {
  $stepsize = .05;
}
if ($convergence_achieved == 0) {
  `$model_gen_src/bin/mc-spec $exmpl.net repeat 10 sample-sigmas heatbath hybrid 200:10 $stepsize`;
  for ($i = $batch2 + 1; $i <= $batch3; ++$i) {
    `$model_gen_src/bin/net-plt t E $exmpl.net > $tmpfile`;
    ($terminating_iteration) = parse_energy_data($tmpfile);
    if ($terminating_iteration < $i) {
      $convergence_achieved = 1;
      last;
    }
    else {
      `$model_gen_src/bin/net-mc $exmpl.net $i`;
    }
  }
}
if ($convergence_achieved == 0) {
  `$model_gen_src/bin/mc-spec $exmpl.net sample-sigmas heatbath hybrid 200:20 0.25`;
  `$model_gen_src/bin/net-mc $exmpl.net $iter`;
}

unlink($tmpfile);

#####################################################################################################
sub parse_rejection_data() {

  my($filename) = @_;

  my($ratio, @Fld);

  open(infile, "$filename");
  while (<infile>) {
    @Fld = split(' ', $_, 9999);
    
    $ratio = $Fld[1];
  }
  close(infile);

  return($ratio);
}
#####################################################################################################
sub parse_energy_data() {

  my($filename) = @_;

  my($iter, @Fld, @energy, $stop_iteration);

  $iter = 0;
  open(infile, "$filename");
  while (<infile>) {
    @Fld = split(' ', $_, 9999);
    
    $energy[$iter] = $Fld[1];
    $iter++;
  }
  close(infile);

  ($stop_iteration) = apriori_stopping($iter, .025, @energy);
  return($stop_iteration);
}
###################################################################
sub apriori_stopping() {
    my($no, $variation, $start_iteration, @pe) = @_;

    my($i, $j, $converged, $tmp, $val, $lb, $ub, $bound);
    
    $bound = $variation / 2.;
    for ($i = 20; $i < $no; ++$i) {
	$val = $pe[$i];
	$lb = (1 + $bound) * $val;
	$ub = (1 - $bound) * $val;
	if ($val > 0.) {
	    $tmp = $lb;
	    $lb = $ub;
	    $ub = $tmp;
	}
	
	$converged = 1;
	for ($j = 4; $j >= 0; --$j) {
	    $val = $pe[$i - $j];
	    if (!($val  < $ub && $val > $lb)) {
		$converged = 0;
		last;
	    }
	}

	if ($converged == 1) {
	    return($i);
	}
    }
    
    return($no + 1);
}
