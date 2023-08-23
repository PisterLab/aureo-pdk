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
GetOptions("final:i", "q:s", "mg:s", "model_dir:s", "host:s", "h:s", "lsf_cmd:s", "rcgen:i", "capgen:i", "offset:i");

($executable, $profile_dir, $mbb_file, $ict_file, $num_files) = @ARGV;

if ($opt_offset eq ""){
  $offset = 0;
}
else {
  $offset = $opt_offset;
}

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

if ($opt_mg) {
  $mg_script = $script_dir . "/generate_model_adaptive_test.pl ";
}
else {
  $mg_script = $script_dir . "/generate_model_adaptive_x86.pl ";
}

use Cwd;
$cur_dir = cwd;
$model_dir = $cur_dir."/models";
chdir($profile_dir);

#+
require $script_dir."/miscutils.pm";
$capgen_call = ProcessOptionalArg($opt_capgen, 1);
$rcgen_call = ProcessOptionalArg($opt_rcgen, 1);
$techgen_call_option = " ";
if ($capgen_call == 1 ) { $techgen_call_option = " -capgen"; }
if ($rcgen_call  == 1 ) { $techgen_call_option = " -rcgen"; }
#-
require "$script_dir"."/get_layers.pl";
($layer_cnt, $layer_addr, $mbb_addr, $vhcnt_addr, $vh_addr, $attrib_addr) = get_layer_info($mbb_file);
@mbb_vals = @$mbb_addr;
@layers = @$layer_addr;

$options = "-generate $ict_file $offset -1 $num_files 7 0";
$nbors = "2 0 0 0 0 0 0 0 0";
open(outfile, ">ziglat_models_base.pl");

if (!$opt_lsf_cmd) {
  $lsf_cmd = "";
}
else {
  $lsf_cmd =  substr($opt_lsf_cmd, 1);
}

$jobs_dir = $cur_dir."/jobs";
if (-d $jobs_dir) {
  ;
}
else {
  mkdir($jobs_dir, 0755);
}

for ($i = 0; $i <= $#layers - 2; ++$i) {
  ($IsRdl[$i]) = find_Rdl($i, $#layers, $vhcnt_addr);
}
($named_gray_layers) = count_gray_layers($layer_cnt, $attrib_addr);

for ($i = 0; $i <= $#layers - 2; ++$i) {
  if ($$attrib_addr[$i] == 1 ||
      $$attrib_addr[$i] == 2 || $$attrib_addr[$i] == 4 || $IsRdl[$i] ) {
    next;
  }
  $src_layer = $layers[$i];
  $src_layer_no = $i + 1;
  $src_layer_no -= $named_gray_layers;

#
#   Generate 3d profiles
#
  $src_net = $src_layer."_src";
  $ziglat_profile_name = "7_".$src_layer."_0_NONE_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE";
      
  if (!$opt_host) {
    $command_string = "`bsub ";
    if ($opt_h) { $command_string .= "-m\"$opt_h\" "; }
    if ($opt_q) { $command_string .= "-q\"$opt_q\" "; }
    $command_string .= "-o jobs -e jobs $lsf_cmd \" echo  $ict_file ; cd $profile_dir;";
  } else {
    $command_string = "cd $profile_dir; ";
  }
  $command_string .= "$executable $techgen_call_option $options $src_layer_no $nbors;";
  $command_string .= "perl $script_dir/process_zig_laterals.pl $ziglat_profile_name;";
  if ($opt_final== 1) {
    $command_string .= "cd $ziglat_profile_name;cp $ziglat_profile_name.dat zig;";
    $command_string .= "perl $script_dir/randomize.pl zig;";
    $command_string .= "mv zig_rnd $ziglat_profile_name.dat;";
    $command_string .= "cd ../..;";
    if ($opt_mg) {
      $command_string .= "perl $mg_script $ziglat_profile_name $profile_dir $opt_model_dir 6 14 1 .9 50 2 $opt_mg $ict_file";
    }
    else {
      $command_string .= "perl $mg_script $ziglat_profile_name $profile_dir 6 14 1 .9 50 2 $ict_file\n";
    }
  }
  if (!$opt_host) {
    $command_string .= "\"`;";
  }
  $command_string =~ s/'/"/g;

  printf outfile "%s\n\n", $command_string;
}

close(outfile);
use File::Copy;
copy("ziglat_models_base.pl", "$cur_dir/ziglat_models_base.pl");
unlink("ziglat_models_base.pl");
chdir($cur_dir);

open(outf, ">ziglat_models_wp.pl");
printf outf "(\$techfile, \$model_dir, \$profile_dir, \$version) = \@ARGV;\n\n";
printf outf "\#\n\# Model writer section\n\#\n";
printf outf "my \$qts_dir = '%s';\n", $exe_dir;
printf outf "my \$script_dir = '%s';\n", $script_dir;
printf outf "`perl \$script_dir/mw_3d.pl 7 \$profile_dir \$model_dir \$techfile \$version -exe \$qts_dir`;\n\n";
close(outf);
