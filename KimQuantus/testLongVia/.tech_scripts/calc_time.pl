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
GetOptions("m=s", "p=s", "o=s", "ext:s", "time_type:s");

if (!$opt_m || !$opt_p || !$opt_o) {
  printf "Usage: <Perl script> -p <profiles directory> -m <models directory> -o <Output file>\n";
  printf "Optional arguments: -ext (default: all; options: two, one, zero, corner)\n";
  printf "                    -time_type (default : Wall clock; options : User)\n";

  die;
}

if (-d $opt_m) {
  $dir = $opt_m;
}
else {
  die "Models directory does not exist\n";
}
if (-d $opt_p) {
  $profile_dir = $opt_p;
}
else {
  die "Profiles directory does not exist\n";
}

if (!$opt_ext) {
  @files = glob("$dir/*.rpt");
}
else {
  @files = glob("$dir/$opt_ext*.rpt");
}
open(outfile, ">$opt_o");
$total_time = 0.;
$sumsq_time = 0.;
$num_models = 0;
foreach $input (@files) {
    open(infile, $input);
    $flag = 0;
    while (<infile>) {
	@Fld = split(' ', $_, 9999);
	if ($Fld[0] eq 'Time') {
	    $flag = 1;
	}
	if ($Fld[0] eq 'PE') {
	    $flag = 0;
	    last;
	}
	if ($flag == 1 & $#Fld == 2) {
	    $val = $Fld[1];
	}
    }
    close(infile);
    
    $beg = rindex($input, '/') + 1;
    $end = index($input, '.');
    $probname = substr($input, $beg, $end - $beg);
    printf outfile "MG: %s   %.2f\n", $probname, $val;

    $total_time += $val;
    $sum_sqtime += ($val * $val);
    $num_models++;
}

if ($profile_dir ne "") {
  if ($opt_time_type eq "") {
    $time_type = "Wall";
    $column = 2;
  }
  elsif ($opt_time_type eq "User") {
    $column = 6;
  }
  else {
    die "Time type undefined\n";
  }
  use Cwd;
  chdir($profile_dir);

  @profiles = split('\n', `ls `);
  $profile_total_time = $profile_total_sqtime = 0;
  $num_profiles = 0;
  foreach $input (@profiles) {
    if (-d $input) {
      if ($opt_ext ne "") {
	if (substr($input, 0, 1) ne $opt_ext) {
	  next;
	}
      }
      $input_file = $input . "/" . $input . ".log";
      if (-e $input_file) {
	open(infile, $input_file);
	$profile_time = 0;

	while (<infile>) {
	  if (/$time_type/) {
	    @Fld = split(' ', $_, 1000);

            ++$num_profiles;
	    $profile_time = $Fld[$column];
	    last;
	  }
	}
	close(infile);
	printf outfile "FS : %s   %.2f\n", $input, $profile_time / 60.;
	$profile_total_time += $profile_time;
	$profile_total_sqtime += ($profile_time * $profile_time);
      }
    }
  }
  $pmean = $profile_total_time / $num_profiles;
  $psd = sqrt(($profile_total_sqtime / $num_profiles) - ($pmean * $pmean));
  printf outfile "Total time for field solves = %f hours\n", $profile_total_time / 3600.;
  printf outfile "Average time for field solves = %f hours\n", $pmean / 3600.;
  printf "Total time for field solves = %f hours\n", $profile_total_time / 3600.;
  printf "Average time for field solves = %f hours\n", $pmean / 3600.;
  printf "SD = %f hours\n", $psd / 3600.; 
}
if ($num_models) {
  $mean = $total_time / $num_models;
  $sd = sqrt(($sum_sqtime / $num_models) - $mean * $mean);
}
printf outfile "Total time for model generation = %f hours\n", $total_time / 60.;
printf outfile "Average time for model generation = %f hours\n", $mean / 60.;
printf "Total time for model generation = %f hours\n", $total_time / 60.;
printf "Average time for model generation = %f hours\n", $mean / 60.;
printf "SD = %f hours\n", $sd / 60.; 


printf outfile "\nTotal time for models = %f hours \n", 
  ($profile_total_time / 3600.) + ($total_time / 60.);

printf "\nTotal time for models = %f hours \n", 
  ($profile_total_time / 3600.) + ($total_time / 60.);

close(outfile);
