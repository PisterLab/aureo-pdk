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
#  Synopsis     [ generate corner model from sensitivity data ]
#  Description  [ Has meta knowledge of historical stuff at Simplex,
#                 such as the old CPP_EMBED_NOTICES convention.
#
#                 Requires the code was reasonably compliant with the
#                 old standard.
#               ]
########################################################################
use Getopt::Long;
GetOptions("area:s");
my ($corner_fname, $src_layer_name, $sens_dir_profiles, $sens_model_dir, $model, $nominal_dir_profiles, $nominal_models_dir, $num_inputs, $num_hidden, $num_outputs, $tr_percent, $iter, $stage, $model_gen_src, $ict_file, $mg_script) = @ARGV;

my $pos = rindex($0, "/");
my $script_dir;
if ($pos == -1) {
  $script_dir = ".";
}
else {
  $script_dir = substr($0, 0, $pos);
}
require "$script_dir"."/get_permutations.pl";

require $script_dir."/miscutils.pm";
my $area_option =  ProcessOptionalArg($opt_area, 0);

use strict;

my $num_corners = get_number_of_corners($corner_fname);
#print "cur dir corner_fname $corner_fname  num_corners $num_corners\n";
for (my $ncorner = 0; $ncorner < $num_corners; $ncorner++) {
  my  $regenerate = 0;
  #
  #  Check if model is permuted for corners. If not - copy from nominal run
  #
  my $corname = get_corner_name($corner_fname, $ncorner); 
  #
  #  Anyway we have to create model directory and put dat file in it. 
  #
  my $corner_model_dir = $corname."/models/";
  my $corner_profile_dir = $corname."/profiles";
  my $corner_datname_dir = $corner_profile_dir."/".$model;                                   

  #create directory for corner profile
  if ( -d $corner_datname_dir) {
     ;
  }  
  else {
    mkdir ($corner_datname_dir);
  }
  #copy dat file from nominal dir to corner dir
  my $nominal_datname_dir = $nominal_dir_profiles."/".$model."/";
  my $nominal_datname = $nominal_datname_dir.$model.".dat";
  # print "nominal_datname $nominal_datname \n";
  my $corner_datname = $corner_datname_dir."/".$model.".dat";
  copy_dat_file($nominal_datname, $corner_datname, $script_dir);

  my ($perm_strings, $perm_active_layers, $perm_values, $num_permutations) 
                  = get_permutations_for_corner($corner_fname, $ncorner);

#
# Try to find any permutation for this model. If there no permutation for this model just copy nominal model 
#
  {
    for (my $i = 0; $i < @$perm_strings; $i++) {
      my ($value1, $value2, $value3, $pname, $type) =
                    parse_permutation_string($perm_strings->[$i]);   

      #don't interpolate into fast corners metal width permutations. We model it by ict file top and bottom enlargement fields
      if ($type eq "W" ) {next;};

      #Find all sensitivity dat files corresponding to current model
      my ($perm_files_list, $perm_strings_list) = 
                      find_all_permutation_model ($model, $sens_dir_profiles, $pname);
      if (@$perm_strings_list == 0) {
        next;
      }
      else {
        if (@$perm_strings_list > 1) {
           print "\nWARNING: more than one sensitive models for $model model\n";
        }
        $regenerate = 1;
        my $sens_dat_file = $perm_files_list->[$0]."/".
                            $perm_strings_list->[0]."_".$model.".dat";
        my $sens_dat_file_tmp = $corner_datname_dir."/". #$sens_dat_file_dir_tmp."/".
                                $perm_strings_list->[0]."_".$model.".dat";
#        print "sens_dat_file_dir_tmp  $sens_dat_file_dir_tmp \n";
#        $sens_dat_file = $sens_dat_file.$sens_dat_file.".dat";
#        $sens_dat_file = $sens_dat_file;
        copy_dat_file($sens_dat_file, $sens_dat_file_tmp, $script_dir);
        #print "sens_dat_file $sens_dat_file \n  sens_dat_file_tmp = $sens_dat_file_tmp \n";
        interpolate($corner_datname, $sens_dat_file_tmp, $perm_strings_list->[0], $perm_strings->[$i], $num_inputs, $script_dir);
      }     
    } #for (i < perm_string)
    if ($regenerate) {
      if ($area_option) {
        my $mdlname = $area_option;
#
#        special procedure for area models
#
        my $val  = 0.;
        my $val0 = 0.;
        my $input_val;

        my $datafile = $corner_datname;
        open(datf, "$datafile") || die "$datafile does not exist\n";
        while (<datf>) {
          my @Fld = split(' ', $_, 9999);
          $input_val = $Fld[0];
          if ($val0 == 0.) {
            $val0 = $Fld[1];
          }
          last;
        }
    
        close(datf);

        $val  = $val0 / $input_val;
        $val *= 1.e-10;

        my $model_file = "$corner_model_dir"."/"."$model".".mdl";
#        print "model_file $model_file \n";
        open(mdlfile, ">$model_file");
        printf mdlfile "NX ".$mdlname."\n";
        printf mdlfile "0 1\n0 1\n1 1\n0\n1\n0\n%g\n", $val;
        close(mdlfile);
      }
      else { #not area option - calling of model generation procedure.
        #model generation
        #print "#model generation \n";
        #decrease the number of hidden neurons for affected models.
        my $speedup_coeff = 0.75;
        $num_hidden = $num_hidden * $speedup_coeff;

        my $raw_model_name = $model; 
        my $profile_dir    = $corner_profile_dir;
        my $model_dir      = "models";

        my $mg_job0 = "$mg_script $raw_model_name $profile_dir $model_dir $num_inputs $num_hidden $num_outputs .9 50 2 $model_gen_src $ict_file;";
  #      print "mg_job0 $mg_job0 \n";
        `perl $mg_job0`;
      }
    }
    else {
#        print "cp $nominal_models_dir/$model.* $corner_model_dir/\n";
        `cp $nominal_models_dir/$model.* $corner_model_dir/`;
        zero_model_time("$corner_model_dir/$model.rpt");
    }

  }
#  `gzip $nominal_datname`;
} 
########################################################################
sub copy_dat_file() {
  use strict;
  use File::Copy;
  my ($dat_file_from, $dat_file_to, $script_dir) = @_;
  
#  print "in copy: \n dat_file_from $dat_file_from \n dat_file_to $dat_file_to \n";

  my $datafile1 = $dat_file_from;
  my $datafile2 = $datafile1.".gz";
  if (-e $datafile1) {
  }
  elsif (-e $datafile2) {
    `gunzip $datafile2`;
  }
  else {
    printf "Data file does not exist\n";
    exit;
  }
  `perl $script_dir/ignore_nan.pl $datafile1 $dat_file_to`;
}
########################################################################
sub zero_model_time() {
  use strict;
  use File::Copy;
  my ($input) = @_;

  my $output = $input."_tmp";

  if (!-e $input) {
    return;
  }

  open(infile, $input);
  open(outfile, "> $output");
  my $flag = 0;
  while (<infile>) {
    my $line = $_;
    my @Fld = split(' ', $line, 9999);
    if ($Fld[0] eq 'Time') {
      $flag = 1;
    }
    if ($Fld[0] eq 'PE') {
      $flag = 0;
    }
    if ($flag == 1 & $#Fld == 2) {
      $Fld[1] = 0.0;
      print outfile join(" ", @Fld)."\n";
    }
    else {
      print outfile $line;
    }
  }
  close(infile);
  close(outfile);
  rename ($output, $input) 

}
