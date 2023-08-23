# Copyright 2013 Cadence Design Systems, Inc. All rights reserved worldwide.

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
GetOptions("offset:i", "special:i", "q:s", "host:s", "h:s", "lsf_cmd:s", "sensitivity:s", "sens_dir:s", "corners=s", "sensitivity_halo=i", "high:i", 
"special4lat!", "back_metals:s", "targeting:s");
($mbb_file, $ict_file, $profile_dir, $model_dir, $script_dir, $fs_exe, $num_cases, $extension, $output, $queue_name, $mg_exe, $test) = @ARGV;

if ($opt_offset eq ""){
  $offset = 0;
}
else {
  $offset = $opt_offset;
}

if (index($fs_exe, "/") == -1) {
  $exe_dir = "";
}
else {
  $exe_dir = substr($fs_exe, 0, rindex($fs_exe, "/"));
}

if ($mg_exe eq "") {
  $mg_script = "$script_dir"."/generate_model_adaptive_x86.pl";
}
else {
  $mg_script = "$script_dir"."/generate_model_adaptive_test.pl";
}


if ($opt_sensitivity) {
  if ($opt_sens_dir eq ""){
    $sens_dir = "sensitivity_models";
  }
  else {
    $sens_dir = $opt_sens_dir;
  }
  $sens_file = $opt_sensitivity;
#  $sens_dir_models   = $sens_dir."/models";
  $sens_dir_models   = "models";
  $sens_dir_profiles = $sens_dir."/profiles";
  $mg_sens_script = "$script_dir"."/generate_sensitivity_model.pl";
}

if ($opt_corners) {
 $sens_dir = "sensitivity_models";
 $corner_fname = $opt_corners;
 $sens_dir_models   = $sens_dir."/models/";
 $sens_dir_profiles = $sens_dir."/profiles/";
 $mg_corner_script = "$script_dir"."/generate_corner_model.pl";
}

if (!$opt_targeting) {
  $targeting = "";
}
else {
  $targeting = "-targeting \"".$opt_targeting."\"";
}

require "$script_dir"."/get_layers.pl";
($layer_cnt, $raw_layer_addr, $layer_addr, $mbb_addr, $vhcnt_addr, $vh_addr, $attrib_addr) = get_layer_info2($mbb_file);
$none_layer = $layer_cnt - 2;
$gnd_layer = $layer_cnt - 1;

require "$script_dir"."/calc_all_models.pl";
$tmpfile = "";
($base_models_addr, $pruned_models_addr) = 
calc_models($extension, $layer_addr, $tmpfile, $vhcnt_addr, $vh_addr, $attrib_addr, $opt_special, $opt_special4lat, $opt_back_metals);

require "$script_dir"."/parse_profile.pl";
# Special models; not currently used
if ($opt_special == 1) {
  if ($extension == 2) {
    $num_base_models = $#$base_models_addr;
    $cnt = 0;
    for ($i = 0; $i <= $num_base_models; ++$i) {
      $model_name = $$base_models_addr[$i];

      $base1_models[$cnt++] = $model_name;

      ($same_layer_nbors, $up1_layer_nbors, $dn1_layer_nbors, $up2_layer_nbors, $dn2_layer_nbors,
       $src_layer_no, $up1_layer_no, $dn1_layer_no, $up2_layer_no, $dn2_layer_no) = 
	 parse_profile($model_name, $layer_addr);

      # 2-3-0-0-0 models
      if ($up1_layer_nbors == 3 && $dn1_layer_nbors == 0 && $up2_layer_nbors == 0) {
	$new_model = $model_name;
	$old_string = $up1_layer_nbors."_".$$layer_addr[$up1_layer_no];
	$new_model =~ s/$old_string/1_$$layer_addr[$up1_layer_no]/;
	$base1_models[$cnt++] = $new_model;
      }
      # 2-0-3-0-0 models
      elsif ($up1_layer_nbors == 0 && $dn1_layer_nbors == 3 && $dn2_layer_nbors == 0) {
	$new_model = $model_name;
	$old_string = $dn1_layer_nbors."_".$$layer_addr[$dn1_layer_no];
	$new_model =~ s/$old_string/1_$$layer_addr[$dn1_layer_no]/;
	$base1_models[$cnt++] = $new_model;
      }
      # 2-3-3-0-0 models
      elsif ($up1_layer_nbors == 3 && $dn1_layer_nbors == 3 &&
	     $up2_layer_nbors == 0 && $dn2_layer_nbors == 0) {
	$new_model = $model_name;
	$old_string = "3_".$$layer_addr[$up1_layer_no];
	$new_model =~ s/$old_string/1_$$layer_addr[$up1_layer_no]/;
	$base1_models[$cnt++] = $new_model;
	
	$new_model = $model_name;
	$old_string = "3_".$$layer_addr[$dn1_layer_no];
	$new_model =~ s/$old_string/1_$$layer_addr[$dn1_layer_no]/;
	$base1_models[$cnt++] = $new_model;
	
	$new_model = $model_name;
	$old_string = "3_".$$layer_addr[$up1_layer_no]."_3_".$$layer_addr[$dn1_layer_no];
	$new_model =~ s/$old_string/1_$$layer_addr[$up1_layer_no]_1_$$layer_addr[$dn1_layer_no]/;
	$base1_models[$cnt++] = $new_model;
      }
      # Nothing is done yet for 2-3-0-2-0, 2-0-3-0-2, 2-3-3-2-0 and 2-3-3-0-2 models
    }
  }
  @base_models = @base1_models;
}
else {
  @base_models = @$base_models_addr;
}
@pruned_models = @$pruned_models_addr;


#
# Treatment for filler specific models
#
if ($extension >= 8 && $extension < 13) {
  $num_base_models = $#$base_models_addr;
  for ($i = 0; $i <= $num_base_models; ++$i) {
    $model_name = $base_models[$i];

    ($same_layer_nbors, $up1_layer_nbors, $dn1_layer_nbors, $up2_layer_nbors, $dn2_layer_nbors,
     $src_layer_no, $up1_layer_no, $dn1_layer_no, $up2_layer_no, $dn2_layer_no) = 
       parse_profile($model_name, $layer_addr);

    ($valid_model) = filter_on_attribute($extension, $src_layer_no, $up1_layer_no, $dn1_layer_no, 
					 $up2_layer_no, $dn2_layer_no, $attrib_addr);

    if ($valid_model == 0) {
      splice @base_models, $i, 1;
      $num_base_models--;
      $i--;
      next;
    }

    if ($up1_layer_nbors == 3 && $dn1_layer_nbors == 0) {
      $old_string = $up1_layer_nbors."_".$$layer_addr[$up1_layer_no];
      $base_models[$i] =~ s/$old_string/F_$$layer_addr[$up1_layer_no]/;
      if ($up2_layer_nbors == 2) {
	$new_model = $model_name;
	$old_string = $up2_layer_nbors."_".$$layer_addr[$up2_layer_no];
	$new_model =~ s/$old_string/F_$$layer_addr[$up2_layer_no]/;
	push @base_models, $new_model;
      }
    }
    elsif ($up1_layer_nbors == 0 && $dn1_layer_nbors == 3) {
      $old_string = $dn1_layer_nbors."_".$$layer_addr[$dn1_layer_no];
      $base_models[$i] =~ s/$old_string/F_$$layer_addr[$dn1_layer_no]/;
      if ($dn2_layer_nbors == 2) {
	$new_model = $model_name;
	$old_string = $dn2_layer_nbors."_".$$layer_addr[$dn2_layer_no];
	$new_model =~ s/$old_string/F_$$layer_addr[$dn2_layer_no]/;
	push @base_models, $new_model;
      }
    }
    elsif ($up1_layer_nbors == 3 && $dn1_layer_nbors == 3) {
      $old_string = "3_".$$layer_addr[$dn1_layer_no];
      $base_models[$i] =~ s/$old_string/F_$$layer_addr[$dn1_layer_no]/;

      $new_model = $model_name;
      $old_string = "3_".$$layer_addr[$up1_layer_no];
      $new_model =~ s/$old_string/F_$$layer_addr[$up1_layer_no]/;
      push @base_models, $new_model;

      $new_model = $model_name;
      $old_string ="3_".$$layer_addr[$up1_layer_no]."_3_".$$layer_addr[$dn1_layer_no];
      $new_model =~ s/$old_string/F_$$layer_addr[$up1_layer_no]_F_$$layer_addr[$dn1_layer_no]/; 
      push @base_models, $new_model;     
    }
    elsif ($opt_special == 10 && $up1_layer_nbors == 0 && $dn1_layer_nbors == 0) {
#      $new_model = $model_name;
#      push @base_models, $new_model;
      ;
    }
    else {
      # Remove the base model
      splice @base_models, $i, 1;
    }
  }
}
# Plate specific models
if (($extension == 2 && $opt_special == 2) || 
    ($extension == 4 && $opt_special == 2) || 
    ($extension == 13 && $opt_special == 5)) {
  $num_base_models = $#$base_models_addr;
  for ($i = 0; $i <= $num_base_models; ++$i) {
    $model_name = $base_models[$i];
 
    ($same_layer_nbors, $up1_layer_nbors, $dn1_layer_nbors, $up2_layer_nbors, $dn2_layer_nbors,
     $src_layer_no, $up1_layer_no, $dn1_layer_no, $up2_layer_no, $dn2_layer_no) =
       parse_profile($model_name, $layer_addr);

    ($valid_model) = filter_on_attribute($extension, $src_layer_no, $up1_layer_no, $dn1_layer_no, 
					 $up2_layer_no, $dn2_layer_no, $attrib_addr);

    if ($valid_model == 0) {
      splice @base_models, $i, 1;
      $num_base_models--;
      $i--;
      next;
    }

    if (($up1_layer_nbors == 0 && $dn1_layer_nbors == 0 &&
         $up2_layer_nbors == 0 && $dn2_layer_nbors == 0) ||
        ($up1_layer_nbors > 0 && $up2_layer_nbors > 0) ||
        ($dn1_layer_nbors > 0 && $dn2_layer_nbors > 0)) {
      splice @base_models, $i, 1;
      $num_base_models--;
      $i--;
    } else {
      $up_layer_no = 0;
      $dn_layer_no = 0;
      $up_layer_nbors = 0;
      $dn_layer_nbors = 0;
      if ($up1_layer_nbors > 0) {
        $up_layer_no = $up1_layer_no;
        $up_layer_nbors = $up1_layer_nbors;
      }
      if ($dn1_layer_nbors > 0) {
        $dn_layer_no = $dn1_layer_no;
        $dn_layer_nbors = $dn1_layer_nbors;
      }
      if ($up2_layer_nbors > 0) {
        $up_layer_no = $up2_layer_no;
        $up_layer_nbors = $up2_layer_nbors;
      }
      if ($dn2_layer_nbors > 0) {
        $dn_layer_no = $dn2_layer_no;
        $dn_layer_nbors = $dn2_layer_nbors;
      }

      if ($up_layer_nbors > 0) {
        $old_string = $up_layer_nbors."_".$$layer_addr[$up_layer_no];
        $base_models[$i] =~ s/$old_string/P_$$layer_addr[$up_layer_no]/;
      }
      if ($dn_layer_nbors > 0) {
        $old_string = $dn_layer_nbors."_".$$layer_addr[$dn_layer_no];
        $base_models[$i] =~ s/$old_string/P_$$layer_addr[$dn_layer_no]/;
      }
    }
  }
}
# GP-Diffusion models
if ($extension == 2 && $opt_special == 3) {
  $num_base_models = $#$base_models_addr;
  for ($i = 0; $i <= $num_base_models; ++$i) {
    $model_name = $base_models[$i];
 
    ($same_layer_nbors, $up1_layer_nbors, $dn1_layer_nbors, $up2_layer_nbors, $dn2_layer_nbors,
     $src_layer_no, $up1_layer_no, $dn1_layer_no, $up2_layer_no, $dn2_layer_no) =
       parse_profile($model_name, $layer_addr);

    ($valid_model) = filter_on_attribute(12, $src_layer_no, $up1_layer_no, $dn1_layer_no, 
					 $up2_layer_no, $dn2_layer_no, $attrib_addr);

    if ($valid_model == 1) {
      $new_model = $model_name;
      $old_string = "2_".$$layer_addr[$src_layer_no];
      $new_string = "12_".$$layer_addr[$src_layer_no];
      $new_model =~ s/$old_string/$new_string/;
      push @base_models, $new_model;
    }
  }
}


# Special treatment for poly-diffusion for one- and zero-ended models
if ($extension == 0 || $extension == 1 || $extension == 4) {
  $num_base_models = $#$base_models_addr;
  for ($i = 0; $i <= $num_base_models; ++$i) {
    $model_name = $base_models[$i];
 
    ($same_layer_nbors, $up1_layer_nbors, $dn1_layer_nbors, $up2_layer_nbors, $dn2_layer_nbors,
     $src_layer_no, $up1_layer_no, $dn1_layer_no, $up2_layer_no, $dn2_layer_no) =
       parse_profile($model_name, $layer_addr);

    ($valid_model) = filter_on_attribute($extension, $src_layer_no, $up1_layer_no, $dn1_layer_no, 
					 $up2_layer_no, $dn2_layer_no, $attrib_addr);

    if ($valid_model == 0) {
      splice @base_models, $i, 1;
      $num_base_models--;
      $i--;
      next;
    }
  }
}
printf "No. of base models = %d; No. of pruned models = %d\n", $#base_models + 1, 
  ($#pruned_models + 1) / 2;

$output_wo_extension = substr($output, rindex($output, "/") + 1);
$output_models = "$output"."_wp.pl";
$output_base = "$output"."_base.pl";
open(outf, ">$output_base");

#if ($opt_sensitivity) {
#  $output_base_sens = $output."_base_sens.pl";
#  open(outf_sens, ">$output_base_sens");
#}

require "$script_dir"."/calc_model_io.pl";

if (!$opt_lsf_cmd) {
  $lsf_cmd = "";
}
else {
  $lsf_cmd = substr($opt_lsf_cmd, 1);
}

require "$script_dir"."/get_permutations.pl";
if ($opt_sensitivity) {
  ($perm_strings, $perm_active_layers, $perm_values, $num_permutations) 
  = get_permutations($sens_file);
}

$sum_model_complexity = 0;
($named_gray_layers) = count_gray_layers($layer_cnt, $attrib_addr);
for ($i = 0; $i <= $#base_models; ++$i) {

  $model_name = $base_models[$i];
  
#
#  Parse model name
#
  ($same_layer_nbors, $up1_layer_nbors, $dn1_layer_nbors, $up2_layer_nbors, $dn2_layer_nbors,
   $src_layer_no, $up1_layer_no, $dn1_layer_no, $up2_layer_no, $dn2_layer_no) = 
    parse_profile($model_name, $layer_addr);

  if($opt_back_metals) {
      if($up1_layer_no != $none_layer && $up1_layer_no != $gnd_layer &&
         !is_equal_backside_properties($$raw_layer_addr[$src_layer_no], $$raw_layer_addr[$up1_layer_no], $opt_back_metals) ||
         $up2_layer_no != $none_layer && $up2_layer_no != $gnd_layer &&
         !is_equal_backside_properties($$raw_layer_addr[$src_layer_no], $$raw_layer_addr[$up2_layer_no], $opt_back_metals) ||
         $dn1_layer_no != $none_layer && $dn1_layer_no != $gnd_layer &&
         !is_equal_backside_properties($$raw_layer_addr[$src_layer_no], $$raw_layer_addr[$dn1_layer_no], $opt_back_metals) ||
         $dn2_layer_no != $none_layer && $dn2_layer_no != $gnd_layer &&
         !is_equal_backside_properties($$raw_layer_addr[$src_layer_no], $$raw_layer_addr[$dn2_layer_no], $opt_back_metals)) {
        next;
      }
  }

  ($up1_offset) = calc_lyr_offset($src_layer_no, $none_layer, $gnd_layer, $up1_layer_no, 1);
  ($up2_offset) = calc_lyr_offset($src_layer_no, $none_layer, $gnd_layer, $up2_layer_no, 1);
  ($dn1_offset) = calc_lyr_offset($src_layer_no, $none_layer, $gnd_layer, $dn1_layer_no, 0);
  ($dn2_offset) = calc_lyr_offset($src_layer_no, $none_layer, $gnd_layer, $dn2_layer_no, 0);
  
  if ($extension >= 8) {
    $same_layer_nbors = 2;
  }
  
  if ($$attrib_addr[$src_layer_no] >= 2 &&
      $$attrib_addr[$up1_layer_no] == 1) {
    $up1_layer_nbors = 2;
  }
  elsif ($$attrib_addr[$src_layer_no] == 1 &&
	 $$attrib_addr[$dn1_layer_no] >= 2) {
    $dn1_layer_nbors = 2;
  }
  my ($varied);
  my (@sens_layer_perm_string);  
  $varied = 0;
  
  if ($opt_sensitivity) {
    
    @sens_layer_perm_string = check_modelname_varied($perm_strings, $perm_active_layers,
                                            $model_name, $raw_layer_addr, $layer_addr, 
                                            $script_dir, $gnd_layer, $none_layer, $opt_sensitivity_halo);
    $varied = @sens_layer_perm_string;
    print "varied $varied \n";
    my $src_layer_name = $$raw_layer_addr[$src_layer_no];
    #exlude width permutations for zero and one ended models.
    if ($extension == 0) {
      my (@tmp_array);
      foreach $i (@sens_layer_perm_string) {
        my ($value1, $value2, $value3, $pname, $type);
           ($value1, $value2, $value3, $pname, $type) = 
                parse_permutation_string($i);
        if ($type ne "W" ) {
          push(@tmp_array, $i);
         }
      } #foreach
      @sens_layer_perm_string = @tmp_array;
    }

  }

  if ($opt_host) {
    $jobs_string = "cd $profile_dir; ";
    if ($varied)  {
       $sens_jobs_string_base = "cd $sens_dir_profiles;";
    }
  } else {
    $jobs_string = "`bsub ";
    if ($opt_h) { $jobs_string .= "-m\"$opt_h\" "; }
    if ($opt_q) { $jobs_string .= "-q\"$opt_q\" "; }
    if ($varied)  {
#       $sens_jobs_string_base .= $jobs_string."-o jobs -e jobs $lsf_cmd \"cd $sens_dir_profiles; ";
       $sens_jobs_string_base  = "";
       $sens_jobs_string_base .= "cd $sens_dir_profiles; ";
    }
    $jobs_string .= "-o jobs -e jobs $lsf_cmd \" echo  $ict_file ;  cd $profile_dir; ";
    $jobs_string =~ s/'/"/g;

  }

#
#  Field solver job
#
  my ($num_inputs, $num_outputs, $model_order) = 
    calc_model_io($same_layer_nbors, $up1_layer_nbors, $dn1_layer_nbors, $up2_layer_nbors, 
    $dn2_layer_nbors, $src_layer_no, $up1_layer_no, $dn1_layer_no, $up2_layer_no, $dn2_layer_no,
    $extension, $opt_high);
  
  if ($extension == 1) {
    if (index($layers[$src_layer_no], "DIFFUSION") != -1 &&
	index($layers[$up1_layer_no], "POLYCIDE") != -1) {
      $num_outputs += 1;
    }
    elsif (index($layers[$src_layer_no], "POLYCIDE") != -1 &&
	index($layers[$dn1_layer_no], "DIFFUSION") != -1) {
      $num_outputs += 1;
    }
  }
  elsif ($extension == 2) {
# Gate Poly - Diffusion models
    if ($same_layer_nbors == 12) {
      $num_inputs -= 22;
      $num_outputs = (5 + $up1_layer_nbors);
      $model_order = ceil(2. * ($num_inputs + $num_outputs));
    }
  }
  elsif ($extension == 13) {
    $num_inputs = 3;
    $num_outputs = 2;
    $model_order = 6;
  }

  $raw_nbors[0] = $same_layer_nbors;
  $raw_nbors[1] = $up1_layer_nbors;  
  $raw_nbors[2] = $up2_layer_nbors;  
  $raw_nbors[3] = $dn1_layer_nbors;  
  $raw_nbors[4] = $dn2_layer_nbors;  

  ($l0_nbors_numerical, $l0_nbors_literal) = process_nbor(\$same_layer_nbors);
  ($up1_nbors_numerical, $up1_nbors_literal) = process_nbor(\$up1_layer_nbors);
  ($up2_nbors_numerical, $up2_nbors_literal) = process_nbor(\$up2_layer_nbors);
  ($dn1_nbors_numerical, $dn1_nbors_literal) = process_nbor(\$dn1_layer_nbors);
  ($dn2_nbors_numerical, $dn2_nbors_literal) = process_nbor(\$dn2_layer_nbors);

  ($nbors_addr) = process_nbors($extension, $same_layer_nbors, $up1_layer_nbors, 
				$dn1_layer_nbors, $up2_layer_nbors, $dn2_layer_nbors,
				$l0_nbors_literal, $up1_nbors_literal, $dn1_nbors_literal, 
				$up2_nbors_literal, $dn2_nbors_literal);
  $slyr = $src_layer_no + 1;
  $slyr -= $named_gray_layers;

# Lateral models
  if ($$nbors_addr[1] == 0 &&
      $$nbors_addr[2] == 0) {
    $num_profiles = $num_cases / 2;
  }
# M_k M_k+/-1 models
  elsif ($$nbors_addr[3] == 0 &&
         $$nbors_addr[4] == 0 &&
         ($$nbors_addr[1] == 0 ||
          $$nbors_addr[2] == 0)) {
    $num_profiles = ceil(3 * $num_cases / 4);
  }
# M_k M_k+/-1 M_k+/-2 models
  elsif (($$nbors_addr[1] == 0 &&
         $$nbors_addr[3] == 0) ||
         ($$nbors_addr[2] == 0 &&
          $$nbors_addr[4] == 0)) {
    $num_profiles = ceil(85 * $num_cases / 100);
  }
# M_k M_k+/-1 M_k-/+1 models
  elsif ($$nbors_addr[3] == 0 &&
         $$nbors_addr[4] == 0) {
    $num_profiles = ceil(95 * $num_cases / 100);
  }
  else {
    $num_profiles = $num_cases;
  }
      
  if  ($extension == 13) {
    $num_profiles = 200;
  }

  $model_type = $extension;
  if ($$nbors_addr[0] == 12) {
    $model_type = 12;
    $$nbors_addr[0] = 2;
  }

  my (@sens_jobs_string);
  if ($test ne 1) {
    $fs_job0_base = "$fs_exe "."-generate $targeting $ict_file ";
  } else {
    $fs_job0_base = "$fs_exe "."generate $ict_file ";
  }

  $fs_job0  = "$offset -1 $num_profiles $model_type 0 $slyr ";                
  $fs_job0 .= "$$nbors_addr[0] $$nbors_addr[1] $$nbors_addr[2] $$nbors_addr[3] $$nbors_addr[4] ";
  $fs_job0 .= "$up1_offset $dn1_offset $up2_offset $dn2_offset";    

  if ($varied) {    
    my ($fs_job0_sens);
    for (my $pindex = 0; $pindex < @sens_layer_perm_string; $pindex++) {
      $fs_job0_sens = "$fs_exe --permutation $sens_layer_perm_string[$pindex] ";      
      if ($test ne 1) {
        $fs_job0_sens .= "-generate $ict_file ";
      } else {
        $fs_job0_sens .= "generate $ict_file ";
      }
      $fs_job0_sens .= $fs_job0;
      $sens_jobs_string[$pindex] = $sens_jobs_string_base.$fs_job0_sens;
    }   

  }

  $fs_job0  = $fs_job0_base.$fs_job0;
  

#HACK
  if ($opt_corners) {
    $jobs_string .= "cd ..;"; 
  }
  else {
    $jobs_string .= $fs_job0;
    $jobs_string .= " ; cd ..;";
  }

#
#     $jobs_string .= " >> temp.log; cd ..;";
  if ($varied) {
    for (my $pindex = 0; $pindex < @sens_jobs_string; $pindex++) {
      $sens_jobs_string[$pindex] .= " ; cd ../..;";
#      print $sens_jobs_string[$pindex] ."\n";

    }
  }
#  print $jobs_string."\n";
#
# Model generator job
#
  if ($extension == 2 || $extension == 4) {
    if ($opt_special == 2) {
      if ($up1_layer_nbors eq "P" || $up2_layer_nbors eq "P") {
	$num_outputs += 1;
      }
      if ($dn1_layer_nbors eq "P" || $dn2_layer_nbors eq "P") {
	$num_outputs += 1;
      }
    }
  }

  $sum_model_complexity += ($num_inputs + $num_outputs + 2) * $model_order;

  $raw_model_name = join_profile($model_type, $raw_nbors[1],$raw_nbors[3], $raw_nbors[2], $raw_nbors[4], $src_layer_no, 
				 $up1_layer_no, $dn1_layer_no, $up2_layer_no, $dn2_layer_no, $raw_layer_addr);
  if ($mg_exe eq "") {
    $mg_job0 = "perl $mg_script $raw_model_name $profile_dir $num_inputs $model_order $num_outputs .9 50 2 $ict_file;";
  }
  else {
    $mg_job0 = "perl $mg_script $raw_model_name $profile_dir $model_dir $num_inputs $model_order $num_outputs .9 50 2 $mg_exe $ict_file;";
  }
  if ($corner_fname) {
    my $src_layer_name = $$raw_layer_addr[$src_layer_no];
    $mg_job0 = "perl $mg_corner_script $corner_fname $src_layer_name $sens_dir_profiles $sens_dir_models $raw_model_name $profile_dir $model_dir $num_inputs $model_order $num_outputs .9 50 2 $mg_exe $ict_file $mg_script; ";
  }
#  print "mg_job0 $mg_job0 \n*************\n  "; 
  if ($varied) {
    for (my $pindex = 0; $pindex < @sens_jobs_string; $pindex++) {
      $raw_model_name_var = $sens_layer_perm_string[$pindex]."_".$raw_model_name;
      if ($mg_exe eq "") {
        $mg_sense_job0 = "perl $mg_sens_script $raw_model_name_var $raw_model_name $sens_dir_profiles $profile_dir $sens_dir_models $num_inputs $model_order $num_outputs .9 50 2 $ict_file;";
      }
      else {
        $mg_sense_job0 = "perl $mg_sens_script $raw_model_name_var $raw_model_name $sens_dir_profiles $profile_dir $sens_dir_models $num_inputs $model_order $num_outputs .9 50 2 $mg_exe $ict_file;";
      }
      $sens_jobs_string[$pindex] .= $mg_sense_job0;
      $mg_job0 .= $sens_jobs_string[$pindex];
#      print "sens_jobs_string[$pindex] $sens_jobs_string[$pindex] \n"; 
    }
  } 

  $jobs_string .= $mg_job0;
  if ($opt_host) {
#      $jobs_string .= " >> temp.log";
  } else {
#      $jobs_string .= " >> temp.log\"`;";
    $jobs_string .= " \"`;";
  }
  printf outf "%s\n\n", $jobs_string;

#  if ($opt_sensitivity) {  
#    for (my $pindex = 0; $pindex < @sens_jobs_string; $pindex++) {
#      if ($opt_host) {
#      } else {
#        $sens_jobs_string[$pindex] .= " \"`;";
#      }
#      printf outf_sens "%s\n\n", $sens_jobs_string[$pindex];
#    }
#  } 

 
}

if (!$opt_host) {
  printf outf "#Total model complexity for current process = %d\n", $sum_model_complexity;
  if ($#base_models >= 0) {
    printf outf "#Average model complexity for current process = %d\n", 
    $sum_model_complexity / ($#base_models + 1);
  }
  printf outf "#No. of base models = %d\n", $#base_models + 1;
}
close(outf);

`chmod 0744 $output_base`;
#`chmod 0744 $output_base_sens`;


open(outf, ">$output_models");
printf outf "(\$techfile, \$model_dir, \$profile_dir, \$version) = \@ARGV;\n\n";
printf outf "\#\n\# Model writer section\n\#\n";
printf outf "my \$qts_dir = '%s';\n", $exe_dir;
printf outf "my \$script_dir = '%s';\n", $script_dir;
printf outf "`perl \$script_dir/mw_limits.pl %d \$model_dir \$profile_dir \$version -exe \$qts_dir`;\n\n", $extension;

printf outf "\#\n\# Model pruner section\n\#\n";
printf outf "use Cwd;\n\$cur_dir = cwd;\n\nchdir(\$model_dir);\n";
if ($exe_dir eq "") {
  printf outf "\$model_pruner = \"modelgen prune \";\n\n";
}
else {
  printf outf "\$model_pruner = \"\$qts_dir/modelgen prune \";\n\n";
}

for ($i = 0; $i <= $#pruned_models; $i += 2) {

  ($s_pnbors, $up1_pnbors, $dn1_pnbors, $up2_pnbors, $dn2_pnbors, $s_pno, $up1_pno, 
   $dn1_pno, $up2_pno, $dn2_pno) = parse_profile($pruned_models[$i], $layer_addr);

  ($s_bnbors, $up1_bnbors, $dn1_bnbors, $up2_bnbors, $dn2_bnbors, $s_bno, $up1_bno, 
   $dn1_bno, $up2_bno, $dn2_bno) = parse_profile($pruned_models[$i + 1], $layer_addr);

  $op_to_prune_from = -1;
  $op_to_prune = 0;
  if (($up2_bno != $up2_pno)) {
    $layer_to_prune = @$layer_addr[$up2_bno];

    if (@$layer_addr[$dn2_pno] ne 'CSUBSTRATE') {

      ($num_pin, $num_pout, $model_order) = 
	calc_model_io($s_pnbors, $up1_pnbors, $dn1_pnbors, $up2_pnbors, $dn2_pnbors, 
		      $s_pno, $up1_pno, $dn1_pno, $up2_pno, $dn2_pno, $extension);

      ($num_bin, $num_bout, $model_order) = 
	calc_model_io($s_bnbors, $up1_bnbors, $dn1_bnbors, $up2_bnbors, $dn2_bnbors, 
		      $s_bno, $up1_bno, $dn1_bno, $up2_bno, $dn2_bno, $extension);

      $op_to_prune = $num_bout - $num_pout;
      $op_to_prune_from = $num_bout - (2 * $op_to_prune);
    }
  }
  elsif ($dn2_bno != $dn2_pno) {
    $layer_to_prune = @$layer_addr[$dn2_bno];
  }
  $b_model = "$pruned_models[$i + 1]".".mdl";

  $mp_job = "(-e \"$b_model\") || warn \"\$!\";\n";
  printf outf "%s", $mp_job;
  $mp_job = "\$model_pruner $b_model 1 $op_to_prune_from $op_to_prune $layer_to_prune";

  printf outf "`%s`;\n", $mp_job;
}
printf outf "\n#\n#Store everything in the tech file\n#\n";
printf outf "`cat $extension*.mdl > \$techfile`;\n\n";
printf outf "`rm -f $extension*.mdl`;\n\nchdir(\$cur_dir);\n\n";

#write sensitivity models
if ($opt_sensitivity) {
 
  printf outf "\#\n\# Sensitivity Model writer section\n\#\n";
  printf outf "\$sensitivity_dir = \$cur_dir.\"%s\"; \n ", "/".$sens_dir."/";
  printf outf "\n{\n   \$pos = rindex (\$model_dir, \"/\"); \n "; 
  printf outf "  if (\$pos > 0) {  \n";
  printf outf "     \$model_dir = substr (\$model_dir, \$pos+1); \n   }  \n";
  printf outf "   \$pos = rindex (\$profile_dir, \"/\"); \n";
  printf outf "   if (\$pos > 0) {  \n";
  printf outf "     \$profile_dir = substr (\$profile_dir, \$pos+1); \n   }  \n";
  printf outf "}  \n";

  printf outf "\n\$sens_file = \"RCgenSenseFile\"; ";
  printf outf "\n\$sens_model_dir   = \$sensitivity_dir.\$model_dir;";
  printf outf   "\n\$sens_profile_dir = \$sensitivity_dir.\$profile_dir; \n";
  printf outf "`perl \$script_dir/mw_limits.pl %d \$sens_model_dir \$sens_profile_dir \$version -sensitivity \$sens_file -script_dir \$script_dir -exe \$qts_dir`;\n\n", $extension;

  printf outf "\#\n\# Store  everything in sensitivity tech file \n\#\n";
  printf outf "\nchdir(\$sens_model_dir);\n";
  printf outf "require \"%s\".\"/get_permutations.pl\";\n", $script_dir;
  printf outf "(\$perm_strings) = get_permutations(\$sens_file);\n";
  printf outf "\$extension = %d; \n", $extension;
  printf outf "\$techfile .= \".sen\"; \n";
  printf outf "if (-e \$techfile) { unlink(\$techfile); }; \n";  
  printf outf "foreach  \$perm (@\$perm_strings) { \n";
  printf outf "    \$actual_extension = \$perm.\"_\".\$extension;\n";
  printf outf "    `cat -s \$actual_extension*.mdl >> \$techfile 2>/dev/null`;\n"; #put stderr into null because we allow that some sensitivity models are not generated
  printf outf "    `rm -f \$actual_extension*.mdl`;\n";
  printf outf "}\n\nchdir(\$cur_dir);\n\n";

}

close(outf);

`chmod 0744 $output_models`;

################################################################################################
sub calc_lyr_offset() {

  my($src_no, $none, $gnd, $lyr_no, $flag) = @_;
  my($new_lyr_no);

  if ($lyr_no != $none && $lyr_no != $gnd) {
    if ($flag == 1) {
      $new_lyr_no = $lyr_no - $src_no;
    }
    else {
      $new_lyr_no = $src_no - $lyr_no;
    }
  }
  else {
     $new_lyr_no = 0;
  }
  return($new_lyr_no);
}
################################################################################################
sub process_nbors() {

  my($ext, $nb_same, $nb_up1, $nb_dn1, $nb_up2, $nb_dn2, $nb_s_l, $nb_u1_l, $nb_d1_l, 
     $nb_u2_l, $nb_d2_l) = @_;
  my(@nbors);
  my($i);

  $nbors[0] = $nb_same;
  $nbors[1] = $nb_up1;
  $nbors[2] = $nb_dn1;
  $nbors[3] = $nb_up2;
  $nbors[4] = $nb_dn2;

  if ($ext == 1) {
    $nbors[0] *= 2;
    if ($nbors[3] != 0) {
      $nbors[3] = "";
      for ($i = 0; $i < $nb_u2_l; ++$i) {
         $nbors[3] .= "D";
       }
    }
    if ($nbors[4] != 0) {
      $nbors[4] = "";
      for ($i = 0; $i < $nb_d2_l; ++$i) {
         $nbors[4] .= "D";
      }
    }
  }
  elsif ($ext == 8 || $ext == 9) {
    if ($nb_s_l > 0) {
      $nbors[0] = "";
      for ($i = 0; $i < $nb_s_l; ++$i) {
	$nbors[0] .= "F";
      }
    }
    if ($nb_u1_l > 0) {
      $nbors[1] = "";
      for ($i = 0; $i < $nb_u1_l; ++$i) {
	$nbors[1] .= "F";
      }
    }  
    if ($nb_d1_l > 0) {
      $nbors[2] = "";
      for ($i = 0; $i < $nb_d1_l; ++$i) {
	$nbors[2] .= "F";
      }
    }  
    if ($nb_u2_l > 0) {
      $nbors[3] = "";
      for ($i = 0; $i < $nb_u2_l; ++$i) {
	$nbors[3] .= "F";
      }
    }  
    if ($nb_d2_l > 0) {
      $nbors[4] = "";
      for ($i = 0; $i < $nb_d2_l; ++$i) {
	$nbors[4] .= "F";
      }
    }  
  }  
  return(\@nbors);
}
################################################################################################
sub filter_on_attribute() {

  my($ext, $l_src, $l_up1, $l_dn1, $l_up2, $l_dn2, $attrib) = @_;
  my($src_attrib, $up1_attrib, $dn1_attrib, $up2_attrib, $dn2_attrib);
  
  $src_attrib = $$attrib[$l_src];
  $up1_attrib = $$attrib[$l_up1];      
  $dn1_attrib = $$attrib[$l_dn1];
  $up2_attrib = $$attrib[$l_up2];
  $dn2_attrib = $$attrib[$l_dn2];

# Eliminate Source Polycide - diffusion combinations
  if ($src_attrib == 1 && $dn1_attrib > 1) {
    if ($ext != 12) {
      return(0);
    }
    else {
      return(1);
    }
  }
  if ($ext == 12) {
    return(0);
  }
# Eliminate Source diffusion - polycide combinations
  if ($src_attrib > 1 && $up1_attrib >= 1) {
    return(0);
  }

  if ($ext == 0 || $ext == 1) {
# Eliminate Victim poly - diffusion combinations
    if ($dn1_attrib == 1 && $dn2_attrib > 1) {
      return(0);
    }
  }
# Eliminate 4 lateral models in diffusion
  if ($ext == 4) {
    if ($src_attrib == 1 || $src_attrib == 3) {
      return(0);
    }
  }
# Eliminate filler in diffusion
  if ($ext == 8) {
    if ($dn2_attrib > 1) {
      return(0);
    }
  }
  return(1);
}
