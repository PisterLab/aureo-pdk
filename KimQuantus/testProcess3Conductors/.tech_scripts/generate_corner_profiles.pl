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
GetOptions("2d:i", "final:i", "fs:i");

($executable, $profile_dir, $mbb_file, $ict_file, $num_files) = @ARGV;

$exe_dir = substr($executable, 0, rindex($executable, "/"));

if (!$opt_2d) {
  $twod_run_flag = 0;
}
else {
  $twod_run_flag = 1;
}

if (!$opt_fs) {
  $run_fs = 0;
}
else {
  $run_fs = $opt_fs;
}

$pos = rindex($0, "/");
if ($pos == -1) {
  $script_dir = ".";
}
else {
  $script_dir = substr($0, 0, $pos);
}
$script3d = "perl " . $script_dir ."/process_3d_corner.pl";

use Cwd;
$cur_dir = cwd;
$model_dir = $cur_dir."/models";
chdir($profile_dir);

require "$script_dir"."/get_layers.pl";
($layer_cnt, $layer_addr, $mbb_addr) = get_layer_info($mbb_file);
@mbb_vals = @$mbb_addr;
@layers = @$layer_addr;

$options = "-generate $ict_file 0 -1 $num_files 5 0";
$nbors = "0 0 0 0 0 0 0 0 0";
open(outfile, ">3druns.pl");

$top_layer = $layers[$#layers - 2];
for ($i = 0; $i <= $#layers - 2; ++$i) {
  $src_layer = $layers[$i];
  $src_layer_no = $i + 1;

#
#   Generate 3d profiles
#
  $src_net = $src_layer."_src";
  $corner_profile_name = "5_".$src_layer."_0_NONE_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE";
  $profile_name = "5_".$src_layer;
      
  if ($twod_run_flag == 1) {
    $command_string = "`bsub -mSUN300 \"cd $profile_dir;";
    $command_string =~ s/'/"/g;
    $jobs_string = "$executable $options $src_layer_no $nbors";
    if ($run_fs == 1) {
      `$jobs_string`;
    }
    else {
      $command_string .= "$jobs_string".";";
    }
  }
  else {
    $command_string = "`cd $profile_dir;";
  }

  $profile_name .= "_0_NONE_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE";
    
  $command_string .= "$script3d $profile_name $mbb_file $exe_dir $model_dir $src_net corner;";
  if ($opt_final == 1) {
    $command_string .= "cd $profile_name;perl $script_dir/randomize.pl corner;";
    $command_string .= "mv corner_rnd $profile_name.dat;";   
  }
  if ($twod_run_flag == 1) {
    $command_string .= "\"`;";
  }
  else {
    $command_string .= "`;";
  }
  printf outfile "%s\n\n", $command_string;

}

close(outfile);
use File::Copy;
copy("3druns.pl", "$cur_dir/3dcorner_runs.pl");
unlink("3druns.pl");
chdir($cur_dir);
