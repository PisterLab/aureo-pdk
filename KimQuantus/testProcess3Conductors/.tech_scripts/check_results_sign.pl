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


eval 'exec perl -S $0 ${1+"$@"}'
    if $running_under_some_shell;
			# this emulates #! processing on NIH machines.
			# (remove #! line above if indigestible)

eval '$'.$1.'$2;' while $ARGV[0] =~ /^([A-Za-z_0-9]+=)(.*)/ && shift;
			# process any FOO=bar switches

$[ = 1;			# set array base to 1

($input_file, $outfile, $num_inputs, $num_targets, $ratio) = @ARGV;
@limits = (-20., -15, -10, -7.5, -5., -2.5, 0., 2.5, 5., 7.5, 10., 12.5, 15., 20., 25.);

open(errfile, ">$outfile");
open(plotfile, ">$outfile.plt");

for ($j = 1; $j <= $num_targets; $j++) {
    for ($i = 1; $i <= $#limits; $i++) {
	$histogram[$j][$i] = 0;
    }
}
open(infile, $input_file);
while(<infile>) {
    @Fld = split(' ', $_, 9999);
    if ($Fld[1] eq 'Case') {
	last;
    }
}
$target_beg = $num_inputs + 2;
$target_end = $target_beg + $num_targets;
$num_samples = 0;
for ($i = 1; $i <= $num_targets; $i++) {
    $sigma_x[$i] = $sigma_xsq[$i] = 0.;
    $valid_samples[$i] = 0;
}
while(<infile>) {
    @Fld = split(' ', $_, 9999);
    if ($#Fld eq 0) {
	next;
    }
    if ($Fld[1] eq 'Average') {
	last;
    }

    $num_samples++;
    for ($j = 1; $j <= $num_targets; $j++) {
	$val1 = $Fld[$target_beg + $j - 1];
	$val2 = $Fld[$target_end + $j - 1];

	if ($j == 1) {
	    $self_cap = $val1;
	}

	if ($j > 1) {
	    if ($self_cap == 0 || fabs($val1 / $self_cap) < $ratio) {
		next;
	    }
	}
	$tmpvar = $val1 - $val2;
	if ($val1 == 0.) {
	    $val = 0.;
	}
	else {
#	    $val = 100. * fabs($tmpvar / $val1);
	    $val = 100. * ($tmpvar / $val1);
	}
	$sigma_x[$j] += $tmpvar;
	$sigma_xsq[$j] += ($tmpvar * $tmpvar);
	$valid_samples[$j] += 1;
	
	printf plotfile "%f    %f\n", $val, $val2;
#  
#   Put stuff into bins to construct the histogram
#
	$flag = 0;
	if ($val < $limits[1]) {
	    $histogram[$j][1] = $histogram[$j][1] + 1;
	    $flag = 1;
	}
	for ($i = 2; $i <= $#limits; $i++) {
	    if (($val >= $limits[$i - 1]) && ($val < $limits[$i])) {
		$histogram[$j][$i] = $histogram[$j][$i] + 1;
		
		$flag = 1;
		last;
	    }
	}
	if ($flag == 0) {
	    $histogram[$j][$#limits + 1] = $histogram[$j][$#limits + 1] + 1;
	}
    }
}
close(infile);
close(plotfile);

for ($j = 1; $j <= $num_targets; $j++) {
    $mean = 0.;
    $variance = 0.;
    for ($i = 1; $i <= $#limits; $i++) {
	if (($i % 6) == 0) {
	    printf errfile "<%5.1f:%4d|\n", $limits[$i], $histogram[$j][$i];
	}
	else {
	    printf errfile "<%5.1f:%4d|", $limits[$i], $histogram[$j][$i];
	}
    }

    printf errfile ">%4.1f    %d\n", $limits[$#limits], 
    $histogram[$j][$#limits + 1];
    
    if ($valid_samples[$j] > 0) {
	$mean = $sigma_x[$j] / $valid_samples[$j];
	$variance = ($sigma_xsq[$j] / $valid_samples[$j]) - ($mean * $mean);
    }
    printf errfile "Samples : %d Error mean = %f; Error variance = %f\n", 
    $valid_samples[$j], $mean, $variance;
}

close(errfile);
#########################################################################
sub fabs {

    if ($_[1] lt 0.) {
        return (-$_[1]);
    }
    else {
	return ($_[1]);
    }
}
