# Copyright 2010 Cadence Design Systems, Inc. All rights reserved worldwide.

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
GetOptions("final:i", "q:s", "mg:s", "model_dir:s", "host:s", "h:s", "lsf_cmd:s", "offset=i", "corners=s", "sensitivity:s", "sens_dir:s",
           "skip_aggr:s");

($executable, $profile_dir, $mbb_file, $ict_file, $num_files, $test) = @ARGV;

$offset = $opt_offset;
if (index($executable, "/") == -1) {
  $exe_dir = "";
}
else {
  $exe_dir = substr($executable, 0, rindex($executable, "/"));
}

$pos = rindex($0, "/");
if ($pos == -1) {
  $script_dir = ".";
}
else {
  $script_dir = substr($0, 0, $pos);
}
$script3d = "perl " . $script_dir ."/process_3d_corner.pl";

if ($opt_mg) {
  $mg_script = $script_dir . "/generate_model_adaptive_test.pl ";
}
else {
  $mg_script = $script_dir . "/generate_model_adaptive_x86.pl ";
}


if ($opt_sensitivity) {
  if ($opt_sensdir eq ""){
    $sens_dir = "sensitivity_models";
  }
  else {
    $sens_dir = $opt_sensdir;
  }
  $sens_file = $opt_sensitivity;
#  $sens_dir_models   = $sens_dir."/models";
  $sens_dir_models   = "models";
  $sens_dir_profiles = $sens_dir."/profiles";
  $mg_sens_script = "$script_dir"."/generate_sensitivity_model.pl";

  require "$script_dir"."/get_permutations.pl";

  ($perm_strings, $perm_active_layers, $perm_values, $num_permutations) 
   = get_permutations($sens_file);   
}

if($opt_skip_aggr) {
  @aggressors_to_skip = split(',', $opt_skip_aggr);
}


use Cwd;
$cur_dir = cwd;
$model_dir = $cur_dir."/models";
chdir($profile_dir);

require "$script_dir"."/get_layers.pl";
($layer_cnt, $layer_addr, $mbb_addr, $vhcnt_addr, $vh_addr, $attrib_addr) = get_layer_info($mbb_file);
@mbb_vals = @$mbb_addr;
@layers = @$layer_addr;

if ($test != 1) {
  $options = "-generate $ict_file $offset -1 $num_files 5 0";
} else {
  $options = "generate $ict_file $offset -1 $num_files 5 0";
}

$nbors = "0 0 0 0 0 0 0 0 0";
open(outfile, ">corner_models_base.pl");
if (!$opt_host) {
}

if (!$opt_lsf_cmd) {
  $lsf_cmd = "";
}
else {
  $lsf_cmd = substr($opt_lsf_cmd, 1);
}

$jobs_dir = $cur_dir."/jobs";
if (-d $jobs_dir) {
  ;
}
else {
  mkdir($jobs_dir, 0755);
}

($named_gray_layers) = count_gray_layers($layer_cnt, $attrib_addr);
for ($i = 0; $i <= $#layers - 2; ++$i) {
  if ($$attrib_addr[$i] == 2 || $$attrib_addr[$i] == 4 ) {
    next;
  }
  $src_layer = $layers[$i];
  if(is_string_in_array($src_layer, \@aggressors_to_skip)) {
    next;
  }

  $src_layer_no = $i + 1;
  $src_layer_no -= $named_gray_layers;

#
#   Check if models affected in sensitivity run
#
  my ($varied);
  $varied = 0;
  if ($opt_sensitivity) {
    my $src_layer_name = $src_layer;
    $varied = check_model_varied($perm_active_layers, $src_layer_name);
    if ($varied) {
#
#     get array of perm string;
#
       @sens_layer_perm_string =
              permutes_for_layer($perm_strings, $perm_active_layers, $src_layer_name);
    }
  } 


#
#   Generate 3d profiles
#
  $src_net = $src_layer."_src";
  $corner_profile_name = "5_".$src_layer."_0_NONE_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE";
      
  if ($opt_host) {
    $command_string = "cd $profile_dir;";
  } else {
    $command_string = "`bsub ";
    if ($opt_h) { $command_string .= "-m\"$opt_h\" "; }
    if ($opt_q) { $command_string .= "-q\"$opt_q\" "; }
    $command_string .= "-o jobs -e jobs $lsf_cmd \" echo  $ict_file ; cd $profile_dir;";        
    $command_string =~ s/'/"/g;
  }
  $command_string_base = $command_string;
  if ($opt_corners) {
    $sens_dir = "sensitivity_models";
    $corner_fname      = $opt_corners;
    $sens_dir_models   = $sens_dir."/models/";
    $sens_dir_profiles = $sens_dir."/profiles/";
    $mg_corner_script  = "$script_dir"."/generate_corner_model.pl";
    my $src_layer_name = $src_layer;
    my $mg_job0 = "$mg_corner_script $corner_fname $src_layer_name $sens_dir_profiles $sens_dir_models $corner_profile_name $profile_dir $opt_model_dir 2 6 1 .9 50 2 $opt_mg $ict_file $mg_script; ";
    $command_string .= "cd ..; perl $mg_job0";
  }
  else {
    $command_string .= "$executable $options $src_layer_no $nbors;";
    $command_string .= "$script3d -fs 1 $corner_profile_name $mbb_file $model_dir $src_net corner -exe $exe_dir;";
    if ($opt_final == 1) {
      $command_string .= "cd $corner_profile_name;perl $script_dir/randomize.pl corner;";
      $command_string .= "mv corner_rnd $corner_profile_name.dat;";   
      $command_string .= "cd ../..;";
      if (!$opt_mg) {
        $command_string .= "perl $mg_script $corner_profile_name $profile_dir 2 6 1 .9 50 2 $ict_file\n";
      }
      else {
        $command_string .= "perl $mg_script $corner_profile_name $profile_dir $opt_model_dir 2 6 1 .9 50 2 $opt_mg $ict_file";
      }
    }

    #
    # Generate sensitivity jobs
    #
    if ($varied) {    
      #generate var field solver jobs
      for (my $pindex = 0; $pindex < @sens_layer_perm_string; $pindex++) {
        my ($fs_job0_sens, $mg_sense_job0);
        my $perm_string = $sens_layer_perm_string[$pindex];
        my $corner_profile_name_perm = $perm_string."_".$corner_profile_name;
        $fs_job0_sens = "cd $sens_dir_profiles;";
        $fs_job0_sens .= "$executable  --permutation $perm_string";
        $fs_job0_sens .= " $options $src_layer_no $nbors; ";
        $fs_job0_sens .= "$script3d -fs 1 $corner_profile_name -prefix $perm_string $mbb_file $model_dir $src_net corner -exe $exe_dir;";
        $fs_job0_sens .= "cd $corner_profile_name_perm;perl $script_dir/randomize.pl corner;";
        $fs_job0_sens .= "mv corner_rnd $corner_profile_name_perm.dat;";   
        $fs_job0_sens .= "cd ../../..;";

        if (!$opt_mg) {
          $mg_sense_job0 = "perl $mg_sens_script $corner_profile_name_perm $corner_profile_name $sens_dir_profiles $profile_dir $sens_dir_models 2 6 1 .9 50 2 $ict_file";
        }
        else {
          $mg_sense_job0 = "perl $mg_sens_script $corner_profile_name_perm $corner_profile_name $sens_dir_profiles $profile_dir $sens_dir_models 2 6 1 .9 50 2 $opt_mg $ict_file";
        }
          
        $sens_jobs_string[$pindex]  = $sens_jobs_string_base.$fs_job0_sens;
        $sens_jobs_string[$pindex] .= $mg_sense_job0;
#        print " $sens_jobs_string[$pindex] \n\n";
        $command_string .= ";".$sens_jobs_string[$pindex];
      }   
    }

  }

  if ($opt_host) {
    $command_string .= "";
  } else {
    $command_string .= "\"`;";
  }
  printf outfile "%s\n\n", $command_string;

}

close(outfile);
use File::Copy;
copy("corner_models_base.pl", "$cur_dir/corner_models_base.pl");
unlink("corner_models_base.pl");
`chmod 0744 $cur_dir/corner_models_base.pl`;
chdir($cur_dir);

open(outf, ">corner_models_wp.pl");
printf outf "(\$techfile, \$model_dir, \$profile_dir, \$version) = \@ARGV;\n\n";
printf outf "\#\n\# Model writer section\n\#\n";
printf outf "my \$qts_dir = '%s';\n", $exe_dir;
printf outf "my \$script_dir = '%s';\n", $script_dir;
printf outf "`perl \$script_dir/mw_3d.pl 5 \$profile_dir \$model_dir \$techfile \$version -exe \$qts_dir`;\n\n";

#write sensitivity models
if ($opt_sensitivity) {
  printf outf "\n \#\n\# Sensitivity Model writer section\n\#\n";
  printf outf "`perl %s/mw_3d.pl 5 -sensitivity $sens_file \$profile_dir \$model_dir \$techfile \$version -exe \$qts_dir`;\n\n", $script_dir;
}
close(outf);

`chmod 0744 corner_models_wp.pl`;
