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
#####################################################################

# option -high lead to increasing of 2d models order
# option -special4lat leads to turning on 
#

use Getopt::Long;
GetOptions("ict=s", "p2lvs=s", "exe=s", "rcgen:i", "capgen:i", "n=i", "mg_exe=s", 
           "v:s", "mbb:i", "area:i", "3d:i", "zig:i", "fill:i", "q:s", "h:s", "QXC321a:i", 
           "offset:i", "host:s", "test:i", "lsf_cmd:s", "special:i", "sensitivity:s", "corners:s", "sensitivity_halo:i",
           "fl:i", "with_lext:i", "high=i", "special4lat:s", "xover_rdl:i", "iset:i", "back_metals:s", "skip_3d_aggr:s", "targeting:s");

$| = 1;

if (!$opt_ict || !$opt_exe || !$opt_n || !$opt_mg_exe || !$opt_v) {
  printf "Usage: <Perl script> \n -ict ICT_file -exe RCgen_executable_name -n Number_of_cases\n";
  printf "                        -mg_exe Full_pathname_of_model_generator_executable\n";
  printf "                        -v version_string\n";
  printf "Optional arguments: -mbb Overwrite_Mbb_flag(default :0 = NO, 1 = YES)\n";
  printf "                    -area Area_models_flag(default : 0 = NO, 1 = YES)\n";
  printf "                    -3d 3D_models_flag(default : 0 = NO, 1 = YES)\n";
  printf "                    -zig zig_models_flag(default : 0 = NO, 1 = YES)\n";
  printf "                    -fill farlateral_models_flag(default : 0 = NO, 1 = YES)\n";
  printf "                    -fl floatingfill_models_flag(default : 0 = NO, 1 = YES)\n";
  printf "                    -QXC321a QXC321a_models_flag(default : 0 = NO, 1 = YES)\n";
  printf "                    -q Queue name \n";
  printf "                    -h Host name\n";
  printf "                    -lsf_cmd \"\Valid LSF options\"\n";
  printf "                    -offset Layer offset (default = 0; xtor = -2)\n";
  printf "                    -test testflag  (default = 0)\n";
  printf "                    -back_metals \"MB,MB1\"\n";
 
  exit;
}

# check perl version no earlier than 5.004
$version2 = "5";
$subversion2 = "004";
$VERSION = $];
$perlversion = 1;
if ($VERSION =~ /^(\d+)\.(\d+)\.(\d+)$/) {
  if ($1 < $version2) { $perlversion = 0; }
  if ($1 == $version2 && $2 < $subversion2) { $perlversion = 0; }
} elsif ($VERSION =~ /^(\d+)\.(\d+)$/) {
  if ($1 < $version2) { $perlversion = 0; }
  if ($1 == $version2 && $2 < $subversion2) { $perlversion = 0; }
} elsif ($VERSION =~ /^(\d+)/) {
  if ($1 < $version2) { $perlversion = 0; }
} else {
  printf  "error, perl version $VERSION not numeric at all\n";
}
if ($perlversion == 0) {
  printf("error, perl version should be later than 5.004 \n");
  exit;
}

use Cwd;
$cur_dir = cwd;

$pos = rindex($0, "/");
if ($pos == -1) {
  $script_dir = $cur_dir;
}
else {
  $script_dir = substr($0, 0, $pos);
}

require $script_dir."/miscutils.pm";
if($opt_sensitivity || $opt_corners) {
  require $script_dir."/get_permutations.pl";
}
#+
$rcgen_p2lvsfile = " ";
if($opt_p2lvs) {
    $rcgen_p2lvsfile = $opt_p2lvs; 
}
#-
$ict_file = $opt_ict;
$nxcaps_exe = $opt_exe;
$mg_exe = $opt_mg_exe;
$num_cases = $opt_n;
#+
$capgen_call = ProcessOptionalArg($opt_capgen, 1);
$rcgen_call = ProcessOptionalArg($opt_rcgen, 1);
#-
$overwrite_mbb = ProcessOptionalArg($opt_mbb, 0);
$area_flag = ProcessOptionalArg($opt_area, 0);
$threed_flag = ProcessOptionalArg($opt_3d, 0);
$zig_flag = ProcessOptionalArg($opt_zig, 0);
$fill_flag = ProcessOptionalArg($opt_fill, 0);
$fl_flag = ProcessOptionalArg($opt_fl, 0);
$QXC321a_flag = ProcessOptionalArg($opt_QXC321a, 0);
$queue_name = ProcessOptionalArg($opt_q, 0);
$host_name = ProcessOptionalArg($opt_h, 0);
$offset = ProcessOptionalArg($opt_offset, 0);
$test = ProcessOptionalArg($opt_test, 0);
$special_flag = 0;
$special_fill_flag = 0;
$sensitivity_fname = ProcessOptionalArg($opt_sensitivity, 0);
$corner_fname = ProcessOptionalArg($opt_corners, 0);
$sensitivity_halo = ProcessOptionalArg($opt_sensitivity_halo, 0);
$with_lext = ProcessOptionalArg($opt_with_lext, 0);
my $high_opt = ProcessOptionalArg($opt_high, 0);

if ($opt_special == 5) {
  $special_fill_flag = 10;
}
if ($opt_special >= 3) {
  $special_flag = 3;
  $opt_special = 2;
}

if (!$opt_lsf_cmd) {
  $lsf_cmd = "";
}
else {
  $lsf_cmd = "\"".$opt_lsf_cmd."\"";
}

if (!$opt_back_metals) {
  $back_metals = "";
}
else {
  $back_metals = "-back_metals \"".$opt_back_metals."\"";
}

if (!$opt_targeting) {
  $targeting = "";
}
else {
  $targeting = "-targeting \"".GetFileName($opt_targeting)."\"";
}


(-e $ict_file) || die "Ict file not found in default path\n";

$error_logfile = $opt_ict.".log";
#
#   Analyze profile
#
if ($test ne 1) {
  printf "Techgen -cell version %s\n", $opt_v;
}
    #`$nxcaps_exe analyze $ict_file $offset .05 >> $error_logfile`;
if ( $sensitivity_fname ) {
  $sensOption =  "--sensitivity $sensitivity_fname"; 
  if (-e 'RCgenSenseFile')  {  `rm -rf RCgenSenseFile`;  }
}

if ( $corner_fname ) {
  $corner_Option =  "--corners $corner_fname"; 
  if (-e 'RCgenCornerFile') {  `rm -rf RCgenCornerFile`; }
  if (-e 'RCgenSenseFile')  {  `rm -rf RCgenSenseFile`;  }
}

#+
$techgen_run_type = " ";
if ($capgen_call == 1 ) { $techgen_run_type = " -capgen"; }
if ($rcgen_call  == 1 ) { $techgen_run_type = " -rcgen"; }
$no_banner = " -no_banner";
#-
if ($overwrite_mbb == 1) {
  printf "Analyzing process %s and generating minimum bounding box values\n", $ict_file;

  if ($test ne 1) {
#    print("$nxcaps_exe $corner_Option $sensOption -analyze $ict_file $offset .05");
    system("$nxcaps_exe $techgen_run_type $corner_Option $sensOption -analyze $ict_file $rcgen_p2lvsfile $offset .05 $no_banner");

  } else {
#    print("$nxcaps_exe $corner_Option $sensOption analyze $ict_file $offset .05");
    system("$nxcaps_exe $techgen_run_type $corner_Option $sensOption analyze $ict_file $rcgen_p2lvsfile $offset .05 $no_banner");
  }
#  `$nxcaps_exe header $ict_file $offset`;
}
else {
  if (-e 'Mbb_data') {
    ;
  }
  else {
    if ($test ne 1) {
      #`$nxcaps_exe -analyze $ict_file $offset .05 >> $error_logfile`;
      system("$nxcaps_exe $techgen_run_type $corner_Option $sensOption -analyze $ict_file $rcgen_p2lvsfile $offset .05 $no_banner");
    } else {
      system("$nxcaps_exe $techgen_run_type $corner_Option $sensOption analyze $ict_file $rcgen_p2lvsfile $offset .05 $no_banner");
    }
    `$nxcaps_exe $techgen_run_type header $ict_file $offset $no_banner`;
  }
}
if (! -e 'Mbb_data') {
  printf "Error, process analyzing failed\n";
  exit;
}

if ( $sensitivity_fname ) {
  if (! -e 'RCgenSenseFile') {
    printf "Error, process sensitivity analyzing failed\n";
    exit;
  }
}

if ( $corner_fname ) {
  if (! -e 'RCgenCornerFile') {
    printf "Error, process corner analyzing failed\n";
    exit;
  }
}

#
#   Create directory structure
#
printf "Creating directory structure\n";

$profile_dir = "profiles";
if (-d $profile_dir) {
  ;
}
else {
  mkdir($profile_dir, 0755);
}
$model_dir = "models";
if (-d $model_dir) {
  ;
}
else {
  mkdir($model_dir, 0755);
}

$sensitivity_dir = "sensitivity_models/";
if ($sensitivity_fname) {
  if (-d $sensitivity_dir) {
    printf  "Warning: $sensitivity_dir directory exists. This directory must not contain result from previous sensitivity Techgen -cell run \n"    ;
  }
  else {
    mkdir($sensitivity_dir, 0755);
  }
  
  #models
  if (-d $sensitivity_dir."models") {
    ;
  }
  else {
    mkdir($sensitivity_dir."models", 0755);
  }

  #profiles
  if (-d $sensitivity_dir."profiles") {
    ;
  }
  else {
    mkdir($sensitivity_dir."profiles", 0755);
  }

}

$jobs_dir = "jobs";
if (-d $jobs_dir) {
  ;
}
else {
  mkdir($jobs_dir, 0755);
}

use File::Copy;
(-e 'Mbb_data') || die "Minimum bounding box information not found in default path\n";

copy("Mbb_data", "$profile_dir/Mbb_data");
copy($ict_file, $profile_dir);
if($opt_p2lvs) {
    copy($rcgen_p2lvsfile, $profile_dir);
}
if ($opt_targeting) {
    copy($opt_targeting, $profile_dir);
}
if (index($ict_file, "/") != -1) {
#  copy($ict_file, $cur_dir);
  `cp $ict_file $cur_dir 2> /dev/null`;
  $ict_file = GetFileName($ict_file);
}
copy("Mbb_data", "$model_dir/Mbb_data");

if ($sensitivity_fname) {
  copy("Mbb_data", "$sensitivity_dir/$profile_dir/Mbb_data");
  copy($ict_file, $sensitivity_dir.$profile_dir);
  copy("Mbb_data", "$sensitivity_dir/$model_dir/Mbb_data");
  copy("RCgenSenseFile", "$sensitivity_dir/$model_dir/RCgenSenseFile");
  copy(".InputSensFile", "$sensitivity_dir/$model_dir/.InputSensFile");
}

if ($corner_fname) {
  $cor_file = "RCgenCornerFile";
  my $num_corners = get_number_of_corners($cor_file);
  for (my $ncorner = 0; $ncorner < $num_corners; $ncorner++) {
    my $corname = get_corner_name($cor_file, $ncorner); 

    if (-d $corname) {
      ;
    }
    else {
      mkdir($corname, 0755);
    }
  
    #models
    if (-d $corname."/models") {
      ;
    }
    else {
      mkdir($corname."/models", 0755);
    }
    copy("Mbb_data",  "$corname/models/Mbb_data");
    copy("$cor_file", "$corname/models/$cor_file");
    copy("$cor_file", "$corname/$cor_file");

    #profiles
    if (-d $corname."/profiles") {
      ;
    }
    else {
      mkdir($corname."/profiles", 0755);
    }
    copy("Mbb_data", "$corname/profiles/Mbb_data");
  }
}


if($opt_host) { $para_mode = "-host $opt_host "; }
if($opt_q) { $para_mode = "-q $queue_name "; }
if($opt_h) { $para_mode = $para_mode."-h $host_name "; }

if ( $sensitivity_fname ) {
  $sensOption =  "-sensitivity RCgenSenseFile -sens_dir $sensitivity_dir"; 
  $sensOption2d_Area =   $sensOption." -sensitivity_halo $sensitivity_halo ";
}

if ( $corner_fname ) {
  $cornerOption =  "-corners $cor_file"; 
}

#
#  Generate area cap models
#
if ($area_flag != 0) {
  printf "Generating area models\n";

  if ( $corner_fname ) {
    my $num_corners = get_number_of_corners($cor_file);
    for (my $ncorner = 0; $ncorner < $num_corners; $ncorner++) {
      my $corname_ict_name = get_corner_ict_name($cor_file, $ncorner, $ict_file); 
      my $corname = get_corner_name($cor_file, $ncorner); 
      my $corner_prof_dir = $corname."/profiles";
      my $corner_models_dir = $corname."/models";

      copy("$corname_ict_name", "$corner_prof_dir");
      copy("$corname_ict_name", "$corner_models_dir");

#      print "perl $script_dir/generate_area_models.pl $nxcaps_exe $corner_prof_dir Mbb_data $corname_ict_name $corner_models_dir $offset $test $opt_v $back_metals $targeting\n";
      `perl $script_dir/generate_area_models.pl $nxcaps_exe $techgen_run_type $corner_prof_dir Mbb_data $corname_ict_name $corner_models_dir -offset "$offset" $test $opt_v $back_metals $targeting`;
    }
  } 
  else {
#    printf "perl $script_dir/generate_area_models.pl $sensOption2d_Area $nxcaps_exe $techgen_run_type profiles Mbb_data $ict_file models -offset ".$offset." $test $opt_v $back_metals $targeting\n";
    `perl $script_dir/generate_area_models.pl $sensOption2d_Area $nxcaps_exe $techgen_run_type profiles Mbb_data $ict_file models -offset "$offset" $test $opt_v $back_metals $targeting`;
  }
#  print "perl $script_dir/generate_area_models.pl $sensOption $cornerOption $nxcaps_exe profiles Mbb_data $ict_file models $offset $test $opt_v $back_metals $targeting\n";
}
#
#  Generate corner and crossover profile data and models
#
if ($threed_flag != 0) {
 
  copy($ict_file, "$profile_dir/$ict_file");
  printf "Generating 3d model list\n";
  cmd;
  
  if($opt_skip_3d_aggr) {
    $skip_3d_aggr = "-skip_aggr \"$opt_skip_3d_aggr\"";
  }
  
  $nxcaps_3d_exe = $nxcaps_exe." $techgen_run_type --with_hmg ";  
  `perl $script_dir/generate_corner_models.pl $sensOption $cornerOption -lsf_cmd $lsf_cmd $para_mode -final 1 -mg $mg_exe -model_dir models -offset "$offset" "$nxcaps_3d_exe" profiles Mbb_data $ict_file 100 $test $skip_3d_aggr`;
#  print "perl $script_dir/generate_corner_models.pl $sensOption $cornerOption -lsf_cmd $lsf_cmd $para_mode -final 1 -mg $mg_exe -model_dir models -offset $offset \"$nxcaps_3d_exe\" profiles Mbb_data $ict_file 100 $test $skip_3d_aggr\n";
  if ($opt_QXC321a == 0) {
#    print "perl $script_dir/generate_xover_models.pl $cornerOption $sensOption -lsf_cmd $lsf_cmd $para_mode -final 1 -xovernbors 1 -mg $mg_exe -model_dir models -offset $offset -QXC321a $opt_QXC321a \"$nxcaps_3d_exe\" profiles Mbb_data $ict_file 400 $test  $back_metals $targeting $skip_3d_aggr\n";
    `perl $script_dir/generate_xover_models.pl $cornerOption $sensOption -lsf_cmd $lsf_cmd $para_mode -final 1 -xovernbors 1 -mg $mg_exe -model_dir models -offset "$offset" -QXC321a $opt_QXC321a "$nxcaps_3d_exe" profiles Mbb_data $ict_file 400 $test -high $high_opt -xover_rdl $opt_xover_rdl $back_metals $targeting $skip_3d_aggr`;
    `perl $script_dir/generate_xover_models.pl $cornerOption $sensOption -lsf_cmd $lsf_cmd $para_mode -final 1 -xovernbors 3 -mg $mg_exe -model_dir models -offset "$offset" -QXC321a $opt_QXC321a "$nxcaps_3d_exe" profiles Mbb_data $ict_file 450 $test -high $high_opt -xover_rdl $opt_xover_rdl $back_metals $targeting $skip_3d_aggr`;
  }
  else {
    `perl $script_dir/generate_xover_models.pl $cornerOption $sensOption -lsf_cmd $lsf_cmd $para_mode -final 1 -xovernbors 1 -mg $mg_exe -model_dir models -offset "$offset" -QXC321a $opt_QXC321a "$nxcaps_3d_exe" profiles Mbb_data $ict_file 200 $test -xover_rdl $opt_xover_rdl $back_metals $targeting $skip_3d_aggr`;
    `perl $script_dir/generate_xover_models.pl $cornerOption $sensOption -lsf_cmd $lsf_cmd $para_mode -final 1 -xovernbors 3 -mg $mg_exe -model_dir models -offset "$offset" -QXC321a $opt_QXC321a "$nxcaps_3d_exe" profiles Mbb_data $ict_file 250 $test -xover_rdl $opt_xover_rdl $back_metals $targeting $skip_3d_aggr`;
  }

#  if ( !$corner_fname ) {
  if ($opt_host) {
    $submit_string .= "` parallel -lsf f $opt_host ./xover1_models_base.pl `;\n";
    $submit_string .= "`mv parallel_*.log jobs/.`;\n";
    $submit_string .= "` parallel -lsf f $opt_host ./xover3_models_base.pl `;\n";
    $submit_string .= "`mv parallel_*.log jobs/.`;\n";
    $submit_string .= "` parallel -lsf f $opt_host ./corner_models_base.pl `;\n";
    $submit_string .= "`mv parallel_*.log jobs/.`;\n";
  } else {
    $submit_string .= "` perl ./xover1_models_base.pl `;\n";
    $submit_string .= "` perl ./xover3_models_base.pl `;\n";
    $submit_string .= "` perl ./corner_models_base.pl `;\n";
  }
  
#  }
#  else {
#    print "\n Debug code for corner models \n";
#    $cor_file = "RCgenCornerFile";
#    my $num_corners = get_number_of_corners($cor_file);
#    for (my $ncorner = 0; $ncorner < $num_corners; $ncorner++) {
#      my $corname = get_corner_name($cor_file, $ncorner); 
#      `cp -r models/5_* $corname/models/`;
#      `cp -r models/6_* $corname/models/`;
#      `cp -r profiles/5_* $corname/profiles/`;
#      `cp -r profiles/6_* $corname/profiles/`;
#     }

#  }
  `chmod 0744 corner_models_base.pl`;
  `chmod 0744 xover1_models_base.pl`;
  `chmod 0744 xover3_models_base.pl`;
  `chmod 0744 corner_models_wp.pl`;
  `chmod 0744 xover_models_wp.pl`;
}
#  Calculate base and pruned models list
#  Run profile data generator for each base model
#  Run model generator for each base model
#
printf "Creating model list \n";

$jobs_header = "";

$nxcaps_2d_exe = $nxcaps_exe.$techgen_run_type." --with_fem2d ";
if ($opt_iset) {
 $nxcaps_2d_exe = $nxcaps_2d_exe." --iset";
}
 
$tmpfile2 = $jobs_header . "two_ended_models";

`perl $script_dir/generate_pack.pl $cornerOption $sensOption2d_Area -offset "$offset" -lsf_cmd $lsf_cmd -special $special_flag $para_mode Mbb_data $ict_file profiles models $script_dir "$nxcaps_2d_exe" $num_cases 2 $tmpfile2 "$queue_name" $mg_exe $test -high $high_opt $back_metals $targeting`;

if ($opt_special >= 2) {
  $tmpfile2 = $jobs_header . "two_ended_plate_models";
  `perl $script_dir/generate_pack.pl $cornerOption $sensOption2d_Area -offset "$offset" -lsf_cmd $lsf_cmd -special $opt_special $para_mode Mbb_data $ict_file profiles models $script_dir "$nxcaps_2d_exe" $num_cases 2 $tmpfile2 "$queue_name" $mg_exe $test -high $high_opt $back_metals $targeting`;
}


{
  my $spec_4lat_option;  
  if ($opt_special4lat) {
    $spec_4lat_option = "-special4lat";
  }
  
  if ($opt_special4lat) {
    my $tmpfile4_plate = $jobs_header . "two_ended_4lat_plate_models";
    `perl $script_dir/generate_pack.pl $cornerOption $sensOption2d_Area -offset "$offset" -lsf_cmd $lsf_cmd -special $opt_special $para_mode Mbb_data $ict_file profiles models $script_dir "$nxcaps_2d_exe" $num_cases 4 $tmpfile4_plate "$queue_name" $mg_exe $test -high $high_opt $spec_4lat_option  $back_metals $targeting`;
#  print "perl $script_dir/generate_pack.pl $cornerOption $sensOption2d_Area -offset \"$offset\" -lsf_cmd $lsf_cmd -special $opt_special $para_mode Mbb_data $ict_file profiles models $script_dir \"$nxcaps_2d_exe\" $num_cases 4 $tmpfile4_plate \"$queue_name\" $mg_exe $test -high $high_opt $spec_4lat_option $back_metals $targeting\n";
  }

  $tmpfile4 = $jobs_header . "two_ended_4lat_models";
    `perl $script_dir/generate_pack.pl $cornerOption $sensOption2d_Area -offset "$offset" -lsf_cmd $lsf_cmd -special $special_flag $para_mode Mbb_data $ict_file profiles models $script_dir "$nxcaps_2d_exe" $num_cases 4 $tmpfile4 "$queue_name" $mg_exe $test -high $high_opt $spec_4lat_option $back_metals $targeting`;
}
my $nxcaps_2d_exe_one_ended = $nxcaps_2d_exe;
if ($with_lext) {
  $nxcaps_2d_exe_one_ended .= " --with_lext ";
}
$tmpfile1 = $jobs_header . "one_ended_models";
  `perl $script_dir/generate_pack.pl $cornerOption $sensOption2d_Area -offset "$offset" -lsf_cmd $lsf_cmd $para_mode Mbb_data $ict_file profiles models $script_dir "$nxcaps_2d_exe_one_ended" $num_cases 1 $tmpfile1 "$queue_name" $mg_exe $test -high $high_opt $back_metals $targeting`;

$tmpfile0 = $jobs_header . "zero_ended_models";
  `perl $script_dir/generate_pack.pl $cornerOption $sensOption2d_Area -offset "$offset" -lsf_cmd $lsf_cmd $para_mode Mbb_data $ict_file profiles models $script_dir "$nxcaps_2d_exe" $num_cases 0 $tmpfile0 "$queue_name" $mg_exe $test -high $high_opt $back_metals $targeting`;

if ($opt_host) {
  $submit_string .= "` parallel -lsf f $opt_host ./two_ended_models_base.pl `;\n";
  $submit_string .= "`mv parallel_*.log jobs/.`;\n";
  $submit_string .= "` parallel -lsf f $opt_host ./two_ended_4lat_models_base.pl `;\n";
  $submit_string .= "`mv parallel_*.log jobs/.`;\n";
  $oneend_string .= "` parallel -lsf f $opt_host ./one_ended_models_base.pl `;\n";
  $oneend_string .= "`mv parallel_*.log jobs/.`;\n";
  $zeroend_string .= "` parallel -lsf f $opt_host ./zero_ended_models_base.pl `;\n";
  $zeroend_string .= "`mv parallel_*.log jobs/.`;\n";
  if ($opt_special >= 2) {
    $submit_string .= "` parallel -lsf f $opt_host ./two_ended_plate_models_base.pl `;\n";
    $submit_string .= "`mv parallel_*.log jobs/.`;\n";
  }
  if ($opt_special4lat) {
    $submit_string .= "` parallel -lsf f $opt_host ./two_ended_4lat_plate_models_base.pl `;\n";
  }
#  if ($sensitivity_fname) {
#    $submit_string_sens .= "` parallel -lsf f $opt_host ./two_ended_models_base_sens.pl `;\n";
#    $submit_string_sens .= "`mv parallel_*.log jobs/.`;\n";
#    if ($opt_special >= 2) {
#      $submit_string_sens .= "` parallel -lsf f $opt_host ./two_ended_plate_models_base_sens.pl `;\n";
#      $submit_string_sens .= "`mv parallel_*.log jobs/.`;\n";
#    }
#  }  
} else {
  $submit_string .= "` perl ./two_ended_models_base.pl `;\n";
  $submit_string .= "` perl ./two_ended_4lat_models_base.pl `;\n";
  if ($opt_special4lat) {
    $submit_string .= "` perl ./two_ended_4lat_plate_models_base.pl `;\n";
  }
  $submit_string .= "` perl ./one_ended_models_base.pl `;\n` perl ./zero_ended_models_base.pl `;\n";
  if ($opt_special >= 2) {
    $submit_string .= "` perl ./two_ended_plate_models_base.pl `;\n";
  }
#  if ($sensitivity_fname) {
#    $submit_string_sens .= "` perl ./two_ended_models_base_sens.pl `;\n";
#    if ($opt_special >= 2) {
#      $submit_string_sens .= "` perl ./two_ended_plate_models_base_sens.pl `;\n";
#    }
#  }
}
#
#  Generate zig models
#
if ($zig_flag != 0 && $corner_fname eq 0) {
  printf "Generating zig model list\n";
  `perl $script_dir/generate_ziglat_models.pl -lsf_cmd $lsf_cmd $para_mode -final 1 -mg $mg_exe -model_dir models $nxcaps_exe  $techgen_run_type profiles Mbb_data $ict_file -offset "$offset" 100`;
  if ($opt_host) {
    $submit_string .= "` parallel -lsf f $opt_host ./ziglat_models_base.pl `;\n";
    $submit_string .= "`mv parallel_*.log jobs/.`;\n";
  } else {
    $submit_string .= "` perl ./ziglat_models_base.pl `;\n";
  }
  `chmod 0744 ./ziglat_models_base.pl`;
  `chmod 0744 ./ziglat_models_wp.pl`;
}
elsif (-e "./ziglat_models_wp.pl" && $corner_fname) {
  unlink("ziglat_models_wp.pl");
  $cor_file = "RCgenCornerFile";
  my $num_corners = get_number_of_corners($cor_file);
  for (my $ncorner = 0; $ncorner < $num_corners; $ncorner++) {
     my $corname = get_corner_name($cor_file, $ncorner); 
     `cp -r models/7_* $corname/models/`;
  }

}

#
#  Generate floating fill models
#
if ($fill_flag != 0) {
  $tmpfile8 = $jobs_header . "fill2D_models";
  `perl $script_dir/generate_pack.pl $cornerOption $sensOption2d_Area -offset "$offset" -lsf_cmd $lsf_cmd -special $special_fill_flag $para_mode Mbb_data $ict_file profiles models $script_dir "$nxcaps_2d_exe"  $num_cases 8 $tmpfile8 "$queue_name" $mg_exe $test $back_metals $targeting`;

  $tmpfile9 = $jobs_header . "fill3D_models";
# Commented out till fill3D models are available
#  `perl $script_dir/generate_pack.pl -lsf_cmd $lsf_cmd $para_mode -offset $offset Mbb_data $ict_file profiles models $script_dir $nxcaps_exe $num_cases 9 $tmpfile9 "$queue_name" $test $mg_exe`;

#  $submit_string .= "` perl ./fill2D_models_base.pl `;\n` perl ./fill3D_models_base.pl `;\n";
  if ($opt_host) {
    $submit_string .= "` parallel -lsf f $opt_host ./fill2D_models_base.pl `;\n";
    $submit_string .= "`mv parallel_*.log jobs/.`;\n";
  } else {
    $submit_string .= "` perl ./fill2D_models_base.pl `;\n";
  }
  `chmod 0744 ./fill2D_models_base.pl`;
  `chmod 0744 ./fill2D_models_wp.pl`;
#  `chmod 0744 ./fill3D_models_base.pl`;
#  `chmod 0744 ./fill3D_models_wp.pl`;
}

#
#  Generate far lateral models
#
if ($fl_flag != 0) {
   printf "Generating far coupling model list\n";
   $tmpfile13 = $jobs_header . "two_ended_farlat_models";
   $tmp_flag = 5;
   `perl $script_dir/generate_pack.pl $cornerOption  -offset "$offset" -lsf_cmd $lsf_cmd -special $tmp_flag $para_mode Mbb_data $ict_file profiles models $script_dir "$nxcaps_2d_exe" $num_cases 13 $tmpfile13 "$queue_name" $mg_exe $test $back_metals $targeting`;
 
   if ($opt_host) {
     $submit_string .= "` parallel -lsf f $opt_host ./two_ended_farlat_models_base.pl `;\n";
     $submit_string .= "`mv parallel_*.log jobs/.`;\n";
   } else {
     $submit_string .= "` perl ./two_ended_farlat_models_base.pl `;\n";
   }
   `chmod 0744 ./two_ended_farlat_models_base.pl`;
   `chmod 0744 ./two_ended_farlat_models_wp.pl`;
}
elsif (-e "./two_ended_farlat_models_wp.pl") {
  unlink("two_ended_farlat_models_wp.pl");
}

open(sub1, ">submit_all_jobs.pl");
printf sub1 "%s%s%s\n", $oneend_string, $zeroend_string, $submit_string;
close(sub1);

#open(sub1, ">submit_all_jobs_sens.pl");
#printf sub1 "%s\n", $submit_string_sens;
#`chmod 0744 ./submit_all_jobs_sens.pl`;

