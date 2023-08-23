######################################################################
#
#  CdnLglNtc    [ Copyright (c) 2002-2004
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
#  Synopsis     [ generate sensitivity model ]
#  Description  [ Has meta knowledge of historical stuff at Simplex,
#                 such as the old CPP_EMBED_NOTICES convention.
#
#                 Requires the code was reasonably compliant with the
#                 old standard.
#               ]
########################################################################


($model_var, $model_nominal, $dir_profiles, $dir_profiles_nominal, $models_dir, $num_inputs, $num_hidden, $num_outputs, $tr_percent, $iter, $stage, $model_gen_src) = @ARGV;

$pos = rindex($0, "/");
if ($pos == -1) {
  $script_dir = ".";
}
else {
  $script_dir = substr($0, 0, $pos);
}

#
# Extract data into file from 2d field solver output
#

$profile_data_dir_nominal = "$dir_profiles_nominal/".$model_nominal."/";
$profile_data_dir_var     = "$dir_profiles/".$model_var."/";

$model_fn_nominal = "$profile_data_dir_nominal/$model_nominal".".dat";
$model_fn_var     = "$profile_data_dir_var/$model_var".".dat";
printf "Using available data file\n";

#print "\n profile_data_dir_nominal $profile_data_dir_nominal";
#print "\n profile_data_dir_var $profile_data_dir_var \n";
#print " model_fn_nominal $model_fn_nominal \n model_fn_var $model_fn_var\n";


use File::Copy;
if ($stage == 2) {
#  $datafile1 = $profile_data_dir_nominal.$model_nominal.".dat";
  $datafile1 = $model_fn_nominal;
#  print " datafile1 $datafile1 \n";
  $datafile2 = $datafile1.".gz";
  if (-e $datafile1) {
  }
  elsif (-e $datafile2) {
    `gunzip $datafile2`;
  }
  else {
    printf "Data file does not exist\n";
    exit;
  }

#  $datafile1 = $profile_data_dir_var.$model_var.".dat";
  $datafile1 = $model_fn_var;
  $datafile2 = $datafile1.".gz";
#  print " datafile1 $datafile1 \n";
  if (-e $datafile1) {
  }
  elsif (-e $datafile2) {
    `gunzip $datafile2`;
  }
  else {
    printf "Data file does not exist\n";
    exit;
  }
}
#
#  Get difference between two runs 
#
# $model_fn_var_delta = alpha * $model_fn_nominal + beta * $model_fn_var 
$alpha = 1.0;
$beta  = -1.0;
$model_fn_var_delta = $model_fn_var.".tmp";
#if this script is called second time skip difference.  
$model_fn_var_field_solver    = $model_fn_var."._fs";
$model_fn_var_field_solver_gz = $model_fn_var."._fs.gz";

#print "$script_dir/caps_a_pls_b.pl $model_fn_var $model_fn_nominal $model_fn_var_delta $alpha $beta $num_inputs $num_outputs \n";
`perl  $script_dir/caps_a_pls_b.pl $model_fn_var $model_fn_nominal $model_fn_var_delta $alpha $beta $num_inputs $num_outputs  `;
system ("cp  $model_fn_var $model_fn_var_field_solver");
system ("gzip -9f $model_fn_var_field_solver");
system ("mv $model_fn_var_delta $model_fn_var");


#
#estimate the norm of the difference. 
#
#my $generate_var_model = 0;
#{
#  my (@norm_nominal,  @norm_difference);
#  @norm_nominal    = norm_of_dat_file($model_fn_nominal, $num_inputs, $num_outputs);
#  @norm_difference = norm_of_dat_file($model_fn_var, $num_inputs, $num_outputs);
#  my $norm_out_sz = @norm_nominal;
#  for (my $i = 0; $i < $norm_out_sz; ++$i) {
#    if( abs( percent($norm_difference[$i], $norm_nominal[$i]) ) > 0.01 ) {
#      $generate_var_model = 1;
#    }
#  }
#  
#}


#
#  generate sensitivity model
#

#$num_hidden = 0.75 * $num_hidden; 

if(is_model_generated($model_fn_nominal, $model_fn_var, $num_inputs, $num_outputs)) {
  `perl   $script_dir/generate_model_adaptive_test.pl $model_var $dir_profiles $models_dir $num_inputs $num_hidden $num_outputs $tr_percent $iter $stage $model_gen_src`;
}

#compress 
if(-e $datafile1) {
  `touch $datafile1.time; gzip $datafile1`;
}

#erase field solver files
if(-e $model_fn_var_field_solver) {
  `rm $model_fn_var_field_solver`;
}
if(-e $model_fn_var_field_solver_gz) {
  `rm $model_fn_var_field_solver_gz`;
}
`touch $model_fn_var_field_solver`;

############################################################################
sub is_model_generated()
{
	my $generate_var_model = 0;
  my ($model_fn_nominal_loc, $model_fn_var_loc, $num_inputs_loc, $num_outputs_loc)  = @_;
  my (@norm_nominal,  @norm_difference);
  @norm_nominal    = norm_of_dat_file($model_fn_nominal_loc, $num_inputs_loc, $num_outputs_loc);
  @norm_difference = norm_of_dat_file($model_fn_var_loc, $num_inputs_loc, $num_outputs_loc);
  my $norm_out_sz = @norm_nominal;
  for (my $i = 0; $i < $norm_out_sz; ++$i) {
    if( abs( percent($norm_difference[$i], $norm_nominal[$i]) ) > 0.01 ) {
      return 1;
    }
  }
  return 0;
}  


##############################################################################
sub norm_of_dat_file() {
use strict;
 my ($fname, $num_inputs, $number_of_outputs) = @_;
 open(filein, "< $fname") || die("Cannot open $ARGV[0]:\n$!\n");

 my @norm_out;
 my $linecnt = 0;
 my $line0 = <filein>;
 while ($line0) {
   ++($linecnt);
   my @Fld = split(' ', $line0, 10000);

   my $n_output = 0;

   for (my $i = $num_inputs; $i <= $#Fld-1; ++$i) {         
     $norm_out[$n_output] += $Fld[$i];
     $n_output++; 
   }

   $line0 = <filein>;
 }

 if ($linecnt) {
   for (my $i = 0; $i < @norm_out; ++$i) {
     $norm_out[$i] = $norm_out[$i] / $linecnt;
   }
 }

 return (@norm_out);
}

#########################################################################
sub percent {
    my ($result);

    if ($_[0] == 0.) {
	$result = 0.;
    }
    else {
	$result = 100. * ($_[1] - $_[0]) / $_[0];
    }

    return $result;
}

