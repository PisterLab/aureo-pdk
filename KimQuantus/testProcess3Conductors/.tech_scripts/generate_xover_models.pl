# Copyright 2011 Cadence Design Systems, Inc. All rights reserved worldwide.

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
GetOptions("final:i", "q:s", "xovernbors:i", "offset=i", "mg:s", "model_dir:s", 
           "host:s", "h:s", "QXC321a:i", "lsf_cmd:s", "corners=s", "sensitivity:s", "sens_dir:s", "high:i", "xover_rdl:i",
           "back_metals:s", "skip_aggr:s", "targeting:s");

($executable, $profile_dir, $mbb_file, $ict_file, $num_files, $test) = @ARGV;

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
$script3d = "perl " . $script_dir ."/process_xover_inputs.pl";

if ($opt_mg) {
  $mg_script = $script_dir . "/generate_model_adaptive_test.pl ";
  $mg_exe = $opt_mg;
}
else {
  $mg_script = $script_dir . "/generate_model_adaptive_x86.pl ";
  $mg_exe = "";
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

if (!$opt_targeting) {
  $targeting = "";
}
else {
  $targeting = "-targeting \"".$opt_targeting."\"";
}

use Cwd;
$cur_dir = cwd;
$model_dir = $cur_dir."/models";
chdir($profile_dir);

require "$script_dir"."/get_layers.pl";
($layer_cnt, $layer_addr, $mbb_addr, $vhcnt_addr, $vh_addr, $attrib_addr) = get_layer_info($mbb_file);
@mbb_vals = @$mbb_addr;
@layers = @$layer_addr;
# Loading the vertical halo information

if (!$opt_xovernbors) {
  $Xnbors = 1;
}
else {
  $Xnbors = $opt_xovernbors;
}

if ($opt_test) {
  if ($opt_QXC321a == 1) {
    $options = "--with_QXC321a generate $ict_file $opt_offset -1 $num_files 6 0";
    $options1 = "--with_QXC321a generate $ict_file $opt_offset -1 19 6 0";
  }
  else {
    $options = "generate $ict_file $opt_offset -1 $num_files 6 0";
    $options1 = "generate $ict_file $opt_offset -1 19 6 0";
  }
}
else {
  if ($opt_QXC321a == 1) {
    $options = "--with_QXC321a -generate $targeting $ict_file $opt_offset -1 $num_files 6 0";
    $options1 = "--with_QXC321a -generate $targeting $ict_file $opt_offset -1 19 6 0";
  }
  else {
    $options = "-generate $targeting $ict_file $opt_offset -1 $num_files 6 0";
    $options1 = "-generate $targeting $ict_file $opt_offset -1 19 6 0";
  }
}

$output_filename = "xover".$Xnbors."_models_base.pl";
open(outfile, ">$output_filename");

if (!$opt_lsf_cmd) {
  $lsf_cmd = "";
}
else {
  $lsf_cmd = substr($opt_lsf_cmd, 1);
## "\"".$opt_lsf_cmd."\""; 
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
$cnt = 0;
for ($i = 0; $i <= $#layers - 2; ++$i) {
  if ($$attrib_addr[$i] == 2 || $$attrib_addr[$i] == 4) {
    next;
  }
  $src_layer = $layers[$i];
  if(is_string_in_array($src_layer, \@aggressors_to_skip)) {
    next;
  }

  $src_layer_no = $i + 1;
  $profile_layer = $src_layer_no - $named_gray_layers;

  $beg = 0;
  $vhalo_cnt = $$vhcnt_addr[$i];
  if ($i > 0) {
    $beg = $$vhcnt_addr[$i - 1];
    $vhalo_cnt -= $$vhcnt_addr[$i - 1];
  }
  for ($vlyr = 0; $vlyr < $vhalo_cnt; ++$vlyr) {
   $tmp_lyr = $i + $$vh_addr[$beg + $vlyr];
   $vhalo[$vlyr] = $layers[$tmp_lyr];
  }

#
#   Generate 3d profiles
#
  my $nbors;
  my $uplr = $i + 1; 
  my $vu_lyr, $vd_lyr;
  my $ii;
  while($uplr < $#layers - 1 && $$attrib_addr[$uplr] == 4)  { 
    $uplr++;
  }

  if(($uplr >= $#layers - 1) || ($$attrib_addr[$i] > 2 && $$attrib_addr[$uplr] == 1) || $IsRdl[$uplr]) {
    $uplr = -1;
  }
  else {
    $vu_lyr = $layers[$uplr];
    unless ($opt_xover_rdl) {
      for ($ii = 0; $ii < $vhalo_cnt; ++$ii) {
        if($vu_lyr eq $vhalo[$ii]) {
            $uplr = -1;
  	    last;
        }
      }
    }
  }
  
    
  my $dnlr = $i - 1;
  while($dnlr >= 0 && $$attrib_addr[$dnlr] == 4)  { 
    $dnlr--;
  }

  if(($dnlr < 0) || ($$attrib_addr[$i] > 2 && $$attrib_addr[$dnlr] == 1) || $IsRdl[$dnlr]) {
    $dnlr = -1;
  }
  else {
    $vd_lyr = $layers[$dnlr];
    unless ($opt_xover_rdl) {      
      for($ii = 0; $ii < $vhalo_cnt; ++$ii) {
      if($vd_lyr eq $vhalo[$ii]) {
	      $dnlr = -1;
	      last;
	    }
	}
    }
  }

  $src_net = $src_layer."_src";
  $no_xover_profiles = 2;
  if ($Xnbors == 3) { $no_xover_profiles = 3; }
  for ($j = 0; $j < $no_xover_profiles; ++$j) {
    if ($j == 0) {
      if($uplr >= 0)
      {
        if($opt_back_metals && !is_equal_backside_properties($src_layer, $vu_lyr, $opt_back_metals)) {
          next;
        }

        my $ofs = $uplr - $i;
        if ($opt_QXC321a == 1) {
          $nbors = "0 $Xnbors 0 0 0 $ofs 0 0 0";
        }
        else {
          $nbors = "2 $Xnbors 0 0 0 $ofs 0 0 0";
        }
	      $xover_profile_name = "6_".$src_layer."_".$Xnbors."_".$vu_lyr."_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE";
      }
      else {
        next;
      }
    }
    elsif ($j == 1) {
      if($dnlr >= 0) {
        if($opt_back_metals && !is_equal_backside_properties($src_layer, $vd_lyr, $opt_back_metals)) {
          next;
        }

        my $ofs = $i - $dnlr; 
        if ($opt_QXC321a == 1) {
          $nbors = "0 0 $Xnbors 0 0 0 $ofs 0 0";
        }
        else {
          $nbors = "2 0 $Xnbors 0 0 0 $ofs 0 0";
        }
	      $xover_profile_name = "6_".$src_layer."_0_NONE_".$Xnbors."_".$vd_lyr."_0_NONE_0_CSUBSTRATE";
      }
      else {
        next; 
      }
    }
    elsif ($j == 2) {
      if($dnlr >= 0 && $uplr > 0 && !$IsRdl[$i]) {
        if($opt_back_metals && (!is_equal_backside_properties($src_layer, $vu_lyr, $opt_back_metals) ||
                                !is_equal_backside_properties($src_layer, $vd_lyr, $opt_back_metals))) {
          next;
        }

        my $ofsup =   $uplr - $i;
        my $ofsdown = $i - $dnlr; 
        $nbors = "2 $Xnbors $Xnbors 0 0 $ofsup $ofsdown 0 0";
	      $xover_profile_name = "6_".$src_layer."_".$Xnbors."_".$vu_lyr."_".$Xnbors."_".$vd_lyr."_0_NONE_0_CSUBSTRATE";
      } 
      else {
        next; 
      }
    }
      

    if ($opt_host) {
      $command_string = "cd $profile_dir;";
    } 
    else {
      $command_string = "`bsub ";
      if ($opt_h) { $command_string .= "-m\"$opt_h\" "; }
      if ($opt_q) { $command_string .= "-q\"$opt_q\" "; }
      $command_string .= "-o jobs -e jobs $lsf_cmd \" echo  $ict_file ; cd $profile_dir;";
      $command_string =~ s/'/"/g;
    }

    $fs_options = "";
    $script3d_options1 = "";
    $script3d_options2 = "";
    $reflect_options   = "";
    my $base_command_string = $command_string;
    if ($j < 2) { 
      $fs_options = "$options $profile_layer $nbors;";
      $command_string .= "$executable $fs_options";
      $script3d_options1 = " $script3d -prof "; 
      $script3d_options2 = " -nbors $Xnbors -out xover;";
      $command_string .= " $script3d_options1 $xover_profile_name $script3d_options2 ";
      if ($opt_final == 1) {
	      $command_string .= "cd $xover_profile_name;cp $xover_profile_name.dat $xover_profile_name.dat3d;";
	      $command_string .= "perl $script_dir/randomize.pl xover;";
	      $command_string .= "mv xover_rnd $xover_profile_name.dat;";
	      if ($Xnbors > 1) {
	        if ($opt_QXC321a != 1) {
            $reflect_options = " 7 5 ";
	          $command_string .= "cd ..;perl $script_dir/reflect_profiles.pl $xover_profile_name $reflect_options;";
	          $command_string .= "cd ..;";
            $mg_options      =  " 7 24 5 .95 50 2 ";
	          $command_string .= "perl $mg_script $xover_profile_name $profile_dir $opt_model_dir $mg_options $mg_exe $ict_file;";
	        }
	        else {
	          $command_string .= "cd ../..;";
            $mg_options      =  " 3 10 2 .95 50 2 ";
	          $command_string .= "perl $mg_script $xover_profile_name $profile_dir $opt_model_dir $mg_options $mg_exe $ict_file;";
	        }
	      }
	      else {
	        if ($opt_QXC321a != 1) {
            $reflect_options = " 7 4 ";
	          $command_string .= "cd ..;perl $script_dir/reflect_profiles.pl $xover_profile_name $reflect_options;";
	          $command_string .= "cd ..;";
            $mg_options      =  " 7 20 4 .95 50 2 ";
	          $command_string .= "perl $mg_script $xover_profile_name $profile_dir $opt_model_dir  $mg_options $mg_exe $ict_file;";  
	        }
	        else {
	          $command_string .= "cd ../..;";
            $mg_options      = " 3 8 1 .95 50 2 ";
	          $command_string .= "perl $mg_script $xover_profile_name $profile_dir $opt_model_dir $mg_options $mg_exe $ict_file;";
	        }
	      }
      }
    }
    #   Up and down crossover option
    else {
      if ($opt_QXC321a != 1) {
        $fs_options = " $options1 $profile_layer $nbors;";
	      $command_string .= " $executable $fs_options ";        
        $mg_options      = " 1 8 1 .9 50 2 ";
	      $command_string .= "cd ..;perl $mg_script $xover_profile_name $profile_dir $opt_model_dir  $mg_options $mg_exe $ict_file;";  
      }
      else {
	      next;
      }
    }

    if ($opt_corners) {
      $sens_dir = "sensitivity_models";
      $corner_fname      = $opt_corners;
      $sens_dir_models   = $sens_dir."/models/";
      $sens_dir_profiles = $sens_dir."/profiles/";
      $mg_corner_script  = "$script_dir"."/generate_corner_model.pl";
      my $src_layer_name = $src_layer;
      my $mg_job0        = "$mg_corner_script $corner_fname $src_layer_name $sens_dir_profiles $sens_dir_models $xover_profile_name $profile_dir $opt_model_dir $mg_options $opt_mg $ict_file $mg_script; ";
      $command_string    = $base_command_string."cd ..; perl $mg_job0";
    }

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
    # Generate sensitivity jobs
    #
    if ($varied) {    
      #generate var field solver jobs
      for (my $pindex = 0; $pindex < @sens_layer_perm_string; $pindex++) {
        my ($fs_job0_sens, $mg_sense_job0);
        my $perm_string = $sens_layer_perm_string[$pindex];
        my $xover_profile_name_perm = $perm_string."_".$xover_profile_name;
        $fs_job0_sens = "cd $sens_dir_profiles;";
        $fs_job0_sens .= "$executable  --permutation $perm_string ";
        $fs_job0_sens .= $fs_options;
        if ($script3d_options1) {
          $fs_job0_sens .= " $script3d_options1 $xover_profile_name_perm $script3d_options2 ";
          $fs_job0_sens .= "cd $xover_profile_name_perm;cp $xover_profile_name_perm.dat $xover_profile_name_perm.dat3d;";
          $fs_job0_sens .= "perl $script_dir/randomize.pl xover;";
          $fs_job0_sens .= "mv xover_rnd $xover_profile_name_perm.dat;";
        }
        if ($reflect_options)  {
	  $fs_job0_sens .= "cd ..;perl $script_dir/reflect_profiles.pl $xover_profile_name_perm $reflect_options;";
        }
        $fs_job0_sens .= "cd ../..;";

        $mg_sense_job0 = "perl $mg_sens_script $xover_profile_name_perm $xover_profile_name $sens_dir_profiles $profile_dir $sens_dir_models $mg_options $mg_exe $ict_file;";       
          
        $sens_jobs_string[$pindex]  = $sens_jobs_string_base.$fs_job0_sens;
        $sens_jobs_string[$pindex] .= $mg_sense_job0;
        print " $sens_jobs_string[$pindex] \n\n";
        $command_string .= $sens_jobs_string[$pindex];
      }   
    }


    if ($opt_host) {
      $command_string .= "";
    } else {
      $command_string .= "\"`;";
    }

    printf outfile "%s\n\n", $command_string;
  }

}
close(outfile);

$tmpstr = $cur_dir."/".$output_filename;
use File::Copy;
copy($output_filename, $tmpstr);
unlink($output_filename);

chdir($cur_dir);

open(outf, ">xover_models_wp.pl");
printf outf "(\$techfile, \$model_dir, \$profile_dir, \$version) = \@ARGV;\n\n";
printf outf "\#\n\# Model writer section\n\#\n";
printf outf "my \$qts_dir = '%s';\n", $exe_dir;
printf outf "my \$script_dir = '%s';\n", $script_dir;
printf outf "`perl \$script_dir/mw_3d.pl 6 \$profile_dir \$model_dir \$techfile \$version -exe \$qts_dir`;\n\n";



#write sensitivity models
if ($opt_sensitivity) {
  printf outf "\n \#\n\# Sensitivity Model writer section\n\#\n";
  printf outf "`perl \$script_dir/mw_3d.pl -sensitivity $sens_file 6 \$profile_dir \$model_dir \$techfile \$version -exe \$qts_dir`;\n\n";
}

close(outf);
