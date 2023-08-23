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
#  Synopsis     [ Convert old-style notices to new style ]
#  Description  [ Has meta knowledge of historical stuff at Simplex,
#                 such as the old CPP_EMBED_NOTICES convention.
#
#                 Requires the code was reasonably compliant with the
#                 old standard.
#               ]
########################################################################

use Getopt::Long;
GetOptions("exe:s", "sensitivity:s", "script_dir:s");
($extension, $modelfile_dir, $datafile_dir, $version, $options) = @ARGV;

if ($opt_sensitivity) {
  $sensitivity_fname = $opt_sensitivity;
}

if ($opt_script_dir eq "") {
  $script_dir = ".tech_scripts/";
}
else {
  $script_dir = $opt_script_dir;
}

if ($opt_exe eq "") {
  $model_writer = "modelgen write";  
}
else {
  $model_writer = "$opt_exe/modelgen write";
}
use Cwd;
$cur_dir = cwd;

if (index($datafile_dir, $cur_dir) == -1) {
  $data_dir = "$cur_dir"."/"."$datafile_dir";
}
else {
  $data_dir = $datafile_dir;
}
chdir($modelfile_dir);


if ($opt_sensitivity) {
  require "$script_dir"."/get_permutations.pl";
  ($perm_strings, $perm_active_layers, $perm_values, $num_permutations, $perm_actual_values_nm) 
     = get_permutations($sensitivity_fname);

  my $sz = @$perm_strings;
  for (my $kk = 0; $kk < $sz; $kk++) {
    #define output_scale for sensitivity model writer
    my $perm = $perm_strings->[$kk];
    my $val_nm = permutation_parse_vals_in_nm($perm_actual_values_nm->[$kk]);

    my $dval;
    my $actual_options = $options;
    if ($val_nm) {
      my $dval =  1e-6/$val_nm;
      $actual_options = $actual_options." ".$dval;  
    }
  
#    print "actual_options $$actual_options \n";
          
    $actual_extension = $perm."_".$extension;
#    print "actual_extension $actual_extension \n";
    call_modelgen($actual_extension, $data_dir, $model_writer, $data_dir, $version, $actual_options);
  }
}
else {
  my $actual_extension = $extension;
  call_modelgen($actual_extension, $data_dir, $model_writer, $data_dir, $version, $options);
}

chdir($cur_dir);

########################################################################################################  

sub call_modelgen() {
  use strict;
  my ($actual_extension, $data_dir, $model_writer, $data_dir, $version, $options) = @_; 
  my ($pos_beg, $pos_end, $probname, $datafile1, $datafile2, $input);
  my (@model_files);

  @model_files = glob("$actual_extension*.net_ascii");
  foreach $input (@model_files) {
  
    $pos_beg = rindex($input, '/') + 1;
    $pos_end = index($input, '.net_ascii');
    $probname = substr($input, $pos_beg, $pos_end - $pos_beg);
    $datafile1 = "$data_dir"."/"."$probname"."/"."$probname".".dat";
    $datafile2 = "$data_dir"."/"."$probname"."/"."$probname".".dat.gz";
    my $datafile3 = "$data_dir"."/"."$probname"."/"."$probname".".dat_mdl";

    my $model_dat_opt;
    if (-e $datafile3) {
      $model_dat_opt = " -points_file $datafile3 ";
    }

    if (-e $datafile1) {
#      print "$model_writer $input -2 $datafile1 $version $options \n";
      `$model_writer $model_dat_opt $input -2 $datafile1 $version $options`;
    }  
    elsif (-e $datafile2) {
      `gunzip $datafile2`;
#      print "$model_writer $input -2 $datafile1 $version $options \n";
      `$model_writer $model_dat_opt $input -2 $datafile1 $version $options`;
      `gzip -9 $datafile1`;
    }
    else {
#      print "$model_writer $input -2 \n";
      `$model_writer $model_dat_opt $input -2`;
    }
  }
}


