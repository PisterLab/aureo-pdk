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
GetOptions("corners=s", "sensitivity:s", "sens_dir:s", "corners=s", "rcgen:i", "capgen:i", "offset=i", "sensitivity_halo:i", "back_metals:s", "targeting:s");
($executable, $profile_dir, $mbb_file, $techfile, $model_dir, $test, $version) = @ARGV;

if ($opt_offset eq ""){
  $offset = 0;
}
else {
  $offset = $opt_offset;
}

$| = 1;

use Cwd;
$cur_dir = cwd;

$pos = rindex($0, "/");
if ($pos == -1) {
  $script_dir = ".";
}
else {
  $script_dir = substr($0, 0, $pos);
}

#+
require $script_dir."/miscutils.pm";
$capgen_call = ProcessOptionalArg($opt_capgen, 1);
$rcgen_call = ProcessOptionalArg($opt_rcgen, 1);
$techgen_call_option = " ";
if ($capgen_call == 1 ) { $techgen_call_option = " -capgen"; }
if ($rcgen_call  == 1 ) { $techgen_call_option = " -rcgen"; }
#-

if ($opt_sensitivity) {
  if ($opt_sensdir eq ""){
    $sens_dir = "sensitivity_models";
  }
  else {
    $sens_dir = $opt_sensdir;
  }
  $sens_file = $opt_sensitivity;
#  $sens_dir_models   = $sens_dir."/models";
  $sens_dir_models   = $sens_dir."/models";
  $sens_dir_profiles = $sens_dir."/profiles";
  $mg_sens_script = "$script_dir"."/generate_sensitivity_model.pl";

  require "$script_dir"."/get_permutations.pl";

  ($perm_strings, $perm_active_layers, $perm_values, $num_permutations, $perm_actual_values_nm) 
   = get_permutations($sens_file);   
}

if (!$opt_targeting) {
  $targeting = "";
}
else {
  $targeting = "-targeting \"".$opt_targeting."\"";
}

chdir($profile_dir);

if ($test ne 1) {
  $options = "-generate $targeting $techfile $offset -1 1 3 0 ";
} else {
  $options = "generate $techfile $offset -1 1 3 0 ";
}
$nbors0 = "0 0 0 0 0 0 0 0 0";
require $script_dir."/get_layers.pl";
($layer_cnt, $layer_addr, $layers_not_raw, $mbb_addr, $vhcnt_addr, $vh_addr, $attrib_addr) = get_layer_info2($mbb_file);
@mbb_vals = @$mbb_addr;
@layers = @$layer_addr;
my $none_layer = $layer_cnt - 2;
my $gnd_layer  = $layer_cnt - 1;


chdir($cur_dir);

($named_gray_layers) = count_gray_layers($layer_cnt, $attrib_addr);
#$cur_lyr = 0;
for ($i = 0; $i <= $#layers - 2; ++$i) {
  if ($attrib_addr[$i] == 1 || $attrib_addr[$i] == 4 ) {
    next;
  }
#  ++$cur_lyr;
  $src_layer = $layers[$i];
  $src_net = "$src_layer"."_src:";
#  $src_layer_no = $cur_lyr;
  $src_layer_no = $i + 1;
  $src_layer_no -= $named_gray_layers;

  for ($j = 0; $j <= $#layers - 2; ++$j) {

    if($opt_back_metals && !is_equal_backside_properties($src_layer, $layers[$j], $opt_back_metals)) {
      next;
    }

    if ($opt_corners) {
      if ($i == $j) {
        $profile_name = "3_"."$src_layer"."_0_NONE_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE";   
        $mdlname = "\"3 $src_layer 0 NONE 0 CSUBSTRATE 0 NONE 0 CSUBSTRATE $version\"";
      }
      elsif ($i > $j) {
        $offset = $i - $j;
        $vic_layer = $layers[$j];
        $profile_name = "3_"."$src_layer"."_0_NONE_1_"."$vic_layer"."_0_NONE_0_CSUBSTRATE";
        $mdlname = "\"3 $src_layer 0 NONE 1 $vic_layer 0 NONE 0 CSUBSTRATE $version\""; 
      }
      else {
        next;
      }

      $sens_dir = "sensitivity_models";
      $corner_fname      = $opt_corners;
      $sens_dir_models   = $sens_dir."/models/";
      $sens_dir_profiles = $sens_dir."/profiles/";
      $mg_corner_script  = "$script_dir"."/generate_corner_model.pl";
      my $src_layer_name = $src_layer;
      my $mg_script = "dummy";
      my $mg_job0 = "$mg_corner_script -area $mdlname $corner_fname $src_layer_name $sens_dir_profiles $sens_dir_models $profile_name $profile_dir $model_dir 1 0 1 0 0 $opt_mg $ict_file $mg_script; ";
#      print $mg_job0."\n";
      `perl $mg_job0`;
      next;
    }

    chdir($profile_dir);
#
#   Generate area profiles
#
    if ($i == $j) {
      `$executable $techgen_call_option $options $src_layer_no $nbors0`;
      $nominal_options = "$options $src_layer_no $nbors0";
      $profile_name = "3_"."$src_layer"."_0_NONE_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE";
      $model_name   = "3_M".$i."_0_NONE_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE";
    }
    elsif ($i > $j) {
      $offset = $i - $j;
      $vic_layer = $layers[$j];
      `$executable $techgen_call_option $options $src_layer_no 0 0 1 0 0 0 $offset 0 0`;
      $nominal_options = "$options $src_layer_no 0 0 1 0 0 0 $offset 0 0";
      $profile_name = "3_"."$src_layer"."_0_NONE_1_"."$vic_layer"."_0_NONE_0_CSUBSTRATE";
      $model_name   = "3_M".$i."_0_NONE_1_M".$j."_0_NONE_0_CSUBSTRATE";
    }
    else {
      next;
    }
     
#    print "cwd ".cwd."\n";

    chdir($profile_name);
    $val  = 0.;
    $val0 = 0.;

    $datafile = "$profile_name".".dat";
    open(datf, "$datafile") || die "Error $datafile does not exist\n";
    while (<datf>) {
      @Fld = split(' ', $_, 9999);
      $input_val = $Fld[0];
      if ($val0 == 0.) {
	$val0 = $Fld[1];
      }
      last;
    }
    close(datf);

    $val  = $val0 / $input_val;
    $val *= 1.e-10;

    chdir($cur_dir);
    if (abs($val) > 0) {
      $model_file = "$model_dir"."/"."$profile_name".".mdl";
      open(mdlfile, ">$model_file");
      if ($i == $j) {
        $mdlname = "3 $src_layer 0 NONE 0 CSUBSTRATE 0 NONE 0 CSUBSTRATE $version\n";
        printf mdlfile "NX ".$mdlname;
      }
      elsif ($i > $j) {
        $mdlname = "3 $src_layer 0 NONE 1 $vic_layer 0 NONE 0 CSUBSTRATE $version\n"; 
        printf mdlfile "NX ".$mdlname;
      }
      printf mdlfile "0 1\n0 1\n1 1\n0\n1\n0\n%g\n", $val;
      close(mdlfile);
    }
 
    #
    #   Check if models affected in sensitivity run
    #
    my ($varied);
    my (@sens_layer_perm_string);  
    $varied = 0;

    if ($opt_sensitivity) {
      my $src_layer_name = $src_layer;

      @sens_layer_perm_string = check_modelname_varied($perm_strings, $perm_active_layers,
                                            $model_name, $layer_addr, $layers_not_raw,
                                            $script_dir, $gnd_layer, $none_layer, $opt_sensitivity_halo);
      $varied = @sens_layer_perm_string;
#      print "model_name $model_name \n";
#      foreach $i (@sens_layer_perm_string) {
#        print $i."\n";
#      }

    } 
    #
    # Generate sensitivity models
    #
    if ($varied) {    
      #field solver jobs
      for (my $pindex = 0; $pindex < @sens_layer_perm_string; $pindex++) {
          my $perm_string = $sens_layer_perm_string[$pindex];
          my ($value1, $value2, $value3, $pname, $type) 
                 =  parse_permutation_string($perm_string);
          if ($type eq "W" ) {
	    #only dielectric and metal thickness could affect area model
            next; 
          }

          chdir($sens_dir_profiles);
          my $profile_name_sens = $perm_string."_".$profile_name;

          `$executable $techgen_call_option --permutation $perm_string $nominal_options`;
#          print "$executable --permutation $perm_string $nominal_options\n";
          chdir($profile_name_sens);
          my $val_sens  = 0.;
          my $val_sens0 = 0.;
          my $datafile_sens = "$profile_name_sens".".dat";
          open(datf, "$datafile_sens") || die "Error: $datafile_sens does not exist\n Check correctness of permutation $perm_string \n";
          while (<datf>) {
            @Fld = split(' ', $_, 9999);
            $input_val_sens = $Fld[0];
            if ($val_sens0 == 0.) {
              $val_sens0 = $Fld[1];
            }
            last;
          }
          close(datf);

          $val_sens  = ($val_sens0 - $val0) / $input_val_sens;
          $val_sens *= 1.e-10;

          my $val_nm = get_actual_permutation_vals_in_nm($perm_string, $perm_strings, $perm_actual_values_nm);
          if ($val_nm) {$val_sens = $val_sens / $val_nm; }
          
          #generate data file with perturbation
         {
            my $datafile_sens_tmp = $datafile_sens."_tmp";
            open(dat_tmp, ">$datafile_sens_tmp");
            printf ( dat_tmp "%.5f %.5f",$input_val,  ($val_sens0 - $val0) ); 
            `mv $datafile_sens_tmp $datafile_sens`;
          }

          chdir($cur_dir);
          
          if (abs($val_sens) > 0)  {
            $model_file_sens = "$sens_dir_models"."/"."$profile_name_sens".".mdl";
            open(mdlfile_sens, ">$model_file_sens");
            $pname = substr($pname,2);
            $mdlname_sens = $type." ".$pname." ".$value1." ".
                         $value2." ".$value3." ".$mdlname;
            printf mdlfile_sens "NX ".$mdlname_sens;
            printf mdlfile_sens "0 1\n0 1\n1 1\n0\n1\n0\n%g\n", $val_sens;
            close(mdlfile_sens);
          } #if (abs($val_sens) > 0)
      }

    }
 
  }
}

chdir($cur_dir);
