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


($model, $dir_profiles, $models_dir, $num_inputs, $num_hidden, $num_outputs, $tr_percent, $iter, $stage, $model_gen_src) = @ARGV;

$pos = rindex($0, "/");
if ($pos == -1) {
  $script_dir = ".";
}
else {
  $script_dir = substr($0, 0, $pos);
}

#
# Run 2d field solver on profiles
#
$profile_data_dir = "$dir_profiles/"."$model";
if ($stage == 0) {
    `./run2d_solver $profile_data_dir`;

    printf "Finished running field solver \n";
}
else {
    printf "Using available field solver data\n";
}
#
# Extract data into file from 2d field solver output
#
use Cwd;
$cur_dir = cwd;
$tmpdir = substr($dir_profiles, 0, rindex($dir_profiles, "/") + 1);
$dir_models = "$tmpdir"."$models_dir";
if (-d $dir_models) {
  ;
}
else {
  mkdir($dir_models, 0744);
}

$model_fn = "$dir_models/$model".".dat";

if ($stage <= 1) {
    mkdir($dir_models, 0700) || warn "mkdir : $!\n";
    `perl $script_dir/xtract_2dout.pl $profile_data_dir $model_fn $num_inputs $num_outputs 0`;

    printf "Finished extracting data \n";

}
else {
    printf "Using available data file\n";
}
use File::Copy;
if ($stage == 2) {
  $datafile1 = $profile_data_dir."/".$model.".dat";
  $datafile2 = $profile_data_dir."/".$model.".dat.gz";
  if (-e $datafile1) {
#    copy($datafile1, "$model_fn");
    `perl $script_dir/ignore_nan.pl $datafile1 $model_fn`;
    `touch $datafile1.time; gzip -f $datafile1`;
  }
  elsif (-e $datafile2) {
    `gunzip $datafile2`;
#    copy($datafile1, "$model_fn");
    `perl $script_dir/ignore_nan.pl $datafile1 $model_fn`;
    `gzip -f $datafile1`;
  }
  else {
    printf "Data file does not exist\n";
    exit;
  }
}
open(model_file, $model_fn);
$linecnt = 0;
while (<model_file>) {
    $linecnt++;
}
close(model_file);

printf "%d data points\n", $linecnt;

# It's not clear that this is useful
#./randomize.pl $model.dat $num_inputs;

#
# Feed this data into model generator
#
use POSIX;
if ($stage <= 3) {
    $tr_beg = 1;
    $tr_end = ceil($tr_percent * $linecnt);
    $tst_beg = $tr_end + 1;
    $tst_end = $linecnt;
    
    chdir($dir_models);
    
    `perl $script_dir/model_gen_adaptive_test.pl $model $num_inputs $num_hidden $num_outputs $tr_beg $tr_end $tst_beg $tst_end $iter 1 $model_gen_src`;

    chdir($cur_dir);
}

#
# Check model predictions
#

chdir($dir_models);
$rptfile = "$model".".rpt";
$tmpfile = "$model".".tmp";
$temp1_file = "$model".".tmp.temp1";
$errfile = "$model".".err";
`$model_gen_src net-plt t E $model.net > $tmpfile`;
$iteration = 0;
open(tfile, "$tmpfile");
while (<tfile>) {
  @Fld = split(' ', $_, 9999);
  $iteration = $Fld[0];
}
close(tfile);

$iter_start = $iteration - 5;
unlink($tmpfile);
# Unsigned histogram
`$model_gen_src net-pred itn $model.net $iter_start: > $errfile`;
`perl $script_dir/check_results.pl $errfile $tmpfile $num_inputs $num_outputs .01`;
#`perl $script_dir/preditn_test.pl $model $num_inputs $num_outputs $iter_start $iteration $model_gen_src`;
rename($tmpfile, $temp1_file);

# Signed histogram
`perl $script_dir/check_results_sign.pl $errfile $tmpfile $num_inputs $num_outputs .15`;

#Rejection rate
open(infile, ">>$tmpfile");
printf infile "\n\nRejection rate\n";
printf infile "--------------\n";
close(infile);
`$model_gen_src net-plt t r $model.net >> $tmpfile`;

open(infile, ">>$tmpfile");
printf infile "Time\n";
printf infile "-----\n";
close(infile);
`$model_gen_src net-plt t k $model.net >> $tmpfile`;

open(infile, ">>$tmpfile");
printf infile "PE\n";
printf infile "--\n";
close(infile);
`$model_gen_src net-plt t E $model.net >> $tmpfile`;

`cat $temp1_file $tmpfile > $rptfile`;
unlink($errfile);
unlink("$temp1_file");
unlink($tmpfile);
$pltfile = "$tmpfile".".plt";
unlink($pltfile);

if ($stage <= 2) {
  $filename = $model . ".dat";
  unlink($filename);
  $filename = $model . ".net";
  unlink($filename);
}
chdir($cur_dir);
