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
GetOptions("keep_models:i", "prefix:i", "exe:s", "sensitivity:s");

($extension, $profile_dir, $model_dir, $techfile, $version) = @ARGV;

$pos = rindex($0, "/");
if ($pos == -1) {
  $script_dir = ".";
}
else {
  $script_dir = substr($0, 0, $pos);
}

use Cwd;
$cur_dir = cwd;  
if ($opt_sensitivity) {
  $sensitivity_dir = $cur_dir."/sensitivity_models/";
  {
     $pos = rindex ($model_dir, "/"); 
     if ($pos > 0) {  
       $model_dir = substr ($model_dir, $pos+1); 
     }  
     $pos = rindex ($profile_dir, "/"); 
     if ($pos > 0) {  
       $profile_dir = substr ($profile_dir, $pos+1); 
     }  
  }
  $sens_file = $opt_sensitivity; 
  $sens_model_dir   = $sensitivity_dir.$model_dir;
  $sens_profile_dir = $sensitivity_dir.$profile_dir;
  $limits_option = "$sens_model_dir $sens_profile_dir -sensitivity $sens_file -script_dir $script_dir";
}
else {
  $limits_option = "$model_dir $profile_dir";
}

if ($extension == 6) {
  `perl $script_dir/mw_limits.pl $extension $limits_option $version .01 -exe $opt_exe`;
}
else {
  `perl $script_dir/mw_limits.pl $extension $limits_option $version 1 -exe $opt_exe`;
}


if ($opt_sensitivity) {
  # Store  everything in sensitivity tech file 
  chdir($sens_model_dir);
  require $script_dir."/get_permutations.pl";
  ($perm_strings) = get_permutations($sens_file);
  $techfile .= ".sen"; 

  if (-e $techfile) { unlink($techfile); }; 
  foreach  $perm (@$perm_strings) { 
    $actual_extension = $perm."_".$extension;
    `cat -s $actual_extension*.mdl >> $techfile 2>/dev/null`; #put stderr into null because we allow that some sensitivity models are not generated
    `rm -f $actual_extension*.mdl`;
  }

}
else  {
  # Store  everything in nominal tech file 
  chdir($model_dir);
 
  $string = "$extension"."*";
  if (!$opt_prefix) {
    `cat $string.mdl > $techfile`;
  }   
  else {
    `cat $string.mdl > __tmp__`;
    `perl $script_dir/convert_techfile_format.pl __tmp__ $techfile`;
    unlink("__tmp__");
  }


  if (!$opt_keep_models) {
    `rm -f $string.mdl`;
  }
}
chdir($cur_dir);

