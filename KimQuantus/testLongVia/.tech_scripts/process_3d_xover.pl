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
GetOptions("fs:i", "exe:s", "print:i", "debug:i");

($dir, $mbb_file, $area_models_dir, $netname, $xover_output) = @ARGV;

if ($opt_exe eq "") {
  $exe_dir = "";
  $modelgen_exe = "modelgen";
}
else {
  $exe_dir = $opt_exe;
  $modelgen_exe = $exe_dir."/modelgen";
}

if (!$opt_fs) {
  $fs_done = 0;
}
else {
  $fs_done = 1;
}
if (!$opt_print) {
  $print_flag = 0;
}
else {
  $print_flag = 1;
}

$fs3d_loc = $exe_dir . "/Fd3_standalone";

$overwrt_outfile = 0;
#
#   Get layer info
#
$pos = rindex($0, "/");
if ($pos == -1) {
  $script_dir = ".";
}
else {
  $script_dir = substr($0, 0, $pos);
}
require "$script_dir"."/get_layers.pl";
($layer_cnt, $layer_addr, $mbb_addr) = get_layer_info($mbb_file);
@layers = @$layer_addr;

use Cwd;
$cur_dir = cwd;

chdir($dir);
$pos = rindex($dir, '/');
if ($pos != -1 ) {
  $probname = substr($dir, $pos + 1, length($dir) - $pos);
}
else {
  $probname = $dir;
}

#
#   Get area cap info
#
($area_model0, $area_model1, $lyr1, $lyr2) = get_area_model_names($probname, @layers);

$src_layer = $layers[$lyr1];
$corner_model_file = "$area_models_dir"."/";
$corner_model_file .= "5_".$src_layer."_0_NONE_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE.mdl";

$existence = $corner_model_file if -e $corner_model_file;
if ($existence eq "") {
  printf "%s file does not exist\n", $corner_model_file;
  exit;
}

#
#  Run 3D field solver
#
if ($fs_done == 0) {
  $fileno = $single_line_flag = 0;
  @files_3d = split('\n', `ls *.in`);
  foreach $input (@files_3d) {
    
    if (index($input, '_single') != -1) {
      $single_line_flag = 1;
    }
    else {
      $single_line_flag = 0;
    }
    
    ($w, $l) = parse_input($input, $netname);
    
    $outfile = substr($input, 0, index($input, ".in"));
    $outfile = $outfile . ".out";
    
    use File::Copy;
    if ($overwrt_outfile == 1) {
      copy($input, "tmp_0000.in");
      `$fs3d_loc tmp_0000.in tmp_0000.out`;
      copy("tmp_0000.out", $outfile);
    }
    else {
      if (-e $outfile) {
	;
      }
      else {
	copy($input, "tmp_0000.in");
	`$fs3d_loc tmp_0000.in tmp_0000.out`;
	copy("tmp_0000.out", $outfile);
      }
    }
    
    if ($single_line_flag == 0) {
      $filename[$fileno] = $input;
      
      $widths[$fileno] = $w;
      $lengths[$fileno] = $l;
      ($cap3d[$fileno]) = parse_output($outfile, $netname);
      $fileno++;
    }
    else {
      ($row, $tmpval) = find_3d_cap($fileno, $w, $l, \@widths, \@lengths, \@cap3d);
      ($cap3d_single[$row]) = parse_output($outfile, $netname);
    }

    #  unlink($outfile);
  }
  unlink("tmp_0000.in");
  unlink("tmp_0000.out");
}

#
#  Calculate correction factors for crossover and corner
#
$prev_value = 0.;
$datafile_exists = 0;
use File::Copy;
$datafile = "$probname".".dat";
if (-e $datafile) {
  $new_datafile = "$probname".".dat2d";
  if (-e $new_datafile) {
    $datafile_exists = 1;
  }
  else {
    copy($datafile, $new_datafile);
  }
}
else {
  printf "Data file %s does not exist\n", $datafile;
  exit;
}
$output_3d = "$xover_output"."_3d";

if ($datafile_exists == 1) {
  open(dataf, "$new_datafile");
}
else {
  open(dataf, "$datafile");
}
open(xover_outfile, ">$xover_output");
$lineno = 0;
while (<dataf>) {

  @Fld = split(' ', $_, 9999);
  $w = $Fld[0];
  $spacing = $Fld[2];
  $l = $Fld[3];

  if ($lyr1 > $lyr2) {
    $cap2d_area = $w * (($l - $w) * $area_model0  + $w * $area_model1);
  }
  else {
    $cap2d_area = $w * ($l * $area_model0  + $w * $area_model1);
  }
  $cap2d_area_single = $w * $l * $area_model0;

  if ($#Fld == 9) {
    $l_victim = $l;
    $cap2d_xz = $Fld[4];
    $cap2d_yz = $Fld[5];
    $cap2d_xz_single = $Fld[6];
    $cap2d_yz_single = $Fld[7];
    
    if ($fs_done == 0) {
      ($row, $cap3d_val) = find_3d_cap($fileno, $w, $l, \@widths, \@lengths, \@cap3d);
    }
    else {
      $cap3d_val = $Fld[8];
    }
    #  $cap3d_val_single = $cap3d_single[$row];
  }
  else {
    $l_victim = $Fld[4];

    $cap2d_xz = $Fld[5];
    $cap2d_yz = $Fld[6];
    
    if ($fs_done == 0) {
      ($row, $cap3d_val) = find_3d_cap($fileno, $w, $l, \@widths, \@lengths, \@cap3d);
    }
    else {
      $cap3d_val = $Fld[7];
    }
  }

  ($corner_correction) = get_corner_cap($corner_model_file, 10000 * $w, 10000 * $l);
  $corner_correction *= 4;

  $excess_cap = $cap3d_val - ($cap2d_xz + $cap2d_yz - $cap2d_area);
#  $corner_correction = $cap3d_val_single - 
#      ($cap2d_xz_single + $cap2d_yz_single - $cap2d_area_single);
  $xover_correction = $excess_cap - $corner_correction;

  $left_coordinate = ($l_victim / 2.) - $spacing;
  $right_coordinate = ($l_victim / 2.) + $spacing;
  $left_overhang = $left_coordinate - ($w / 2.);
  $right_overhang = $right_coordinate - ($w / 2.);
  $half_l = $l / 2.;
  if ($xover_correction < 0.) {
    printf "Warning: Negative crossover value for pair (%f, %f) = %f\n", 
    $w, $l, $xover_correction;

    printf "3d components %s: %f %f\n", $filename[$row], $cap3d_val, $corner_correction;
    printf "2d components :%f %f  Area : %f\n", $cap2d_xz, $cap2d_yz, $cap2d_area;
    $xover_correction = 0.;

    next;
  }
  if ($left_overhang < 0.) {
    printf "Warning: Negative overhang value for pair (%f, %f) = %f\n", 
    $w, $l, $xover_correction;

    next;
  }
  
  if ($opt_debug == 1) {
    printf "Line : %d 3d : %f %f\n", $lineno, $cap3d_val, $corner_correction;
    printf "          2d :%f %f  Area : %f\n", $cap2d_xz, $cap2d_yz, $cap2d_area;
  }
  if ($print_flag == 1) {
    printf "%f %f\n", $excess_cap, $corner_correction;
  }
  printf xover_outfile "%f %f %f %f %f\n", $w, $left_overhang, $right_overhang, 
  $half_l - ($w / 2.), $xover_correction / 2.;

  ++$lineno;
}
close(dataf);
close(xover_outfile);
chdir($cur_dir);
###################################################################################
sub parse_input() {

  my($infile_name, $netname) = @_;

  my($infile, $w, $l, $net_found_flag, $tmpvar, @Fld);

  $net_found_flag = 0;
  open(infile, "$infile_name");
  while (<infile>) {
    @Fld = split(' ', $_, 9999);

    if ($net_found_flag == 1) {
      $l = $Fld[4] - $Fld[1];
      
      $tmpvar = substr($Fld[0], 1, length($Fld[0]) - 1);
      $w = $Fld[3] - $tmpvar;

      last;
    }

    if (($Fld[0] eq 'net') && ($Fld[1] eq $netname)) {
      $net_found_flag = 1;
    }

  }
  close(infile);
  
  return($w, $l);
}
###################################################################################
sub parse_output() {

  my($infile_name, $netname) = @_;

  my($infile, $fs3d, @Fld);

  open(infile, "$infile_name");
  while (<infile>) {
    @Fld = split(' ', $_, 9999);

    if (index($Fld[0], 'net(') != -1 && index($Fld[0], $netname) != -1) {
      $fs3d = $Fld[2];
    }
    if (index($Fld[1], 'DD') != -1) {
      $fs3d = $Fld[6];
      last;
    }
  }
  close(infile);

  return($fs3d);
}
###################################################################################
sub find_3d_cap(\$\$\$\@\@\@) {

  my($num_files, $ref_w, $ref_l, $w, $l, $cap3d) = @_;

  my($i);

  for ($i = 0; $i < $num_files; ++$i) {
    if (abs_percent($$w[$i], $ref_w) < .1 &&
	abs_percent($$l[$i], $ref_l) < .1) {

      return($i, $$cap3d[$i]);
    }
  }
  
  return(-1,-1);
}
###################################################################################
sub abs_percent() {
  if ($_[0] == 0.) {
    return(100000);
  }
  return(100. * abs(1. - ($_[1] / $_[0])));
}
###################################################################################
sub get_area_model_names(\$\@) {

  my($name, @lyrs) = @_;
  my($tmpfile, $area_model1_file, $area_model0_file, $pos, $new_pos, $layer_cnt);
  my($same_layer_nbors, $up1_layer_nbors, $dn1_layer_nbors, $layer_no, $lyr1, $lyr2);
  my($src_layer, $up1_layer, $dn1_layer);
  my($existence);
  my($area_model0_file, $area_model1_file, $area0, $area1);

  require "$script_dir"."/parse_profile.pl";
  $same_layer_nbors = $up1_layer_nbors = $dn1_layer_nbors = 0;
  $layer_cnt = $#lyrs + 1;
  $pos = index($name, '_');
  $same_layer_nbors = substr($name, 0, $pos);
  ($new_pos, $lyr1) = parse_profile_for_layer($pos + 1, $name, $layer_cnt, @lyrs);
  $src_layer = $lyrs[$lyr1];

  $pos = $new_pos;
  $up1_layer_nbors = substr($name, $pos, 1);
  ($new_pos, $layer_no) = parse_profile_for_layer($pos + 2, $name, $layer_cnt, @lyrs);
  $up1_layer = $lyrs[$layer_no];
  if ($up1_layer ne 'NONE' && $up1_layer ne 'CSUBSTRATE') {
    $lyr2 = $layer_no;
  }

  $pos = $new_pos;
  $dn1_layer_nbors = substr($name, $pos, 1);
  ($new_pos, $layer_no) = parse_profile_for_layer($pos + 2, $name, $layer_cnt, @lyrs);
  $dn1_layer = $lyrs[$layer_no];
  if ($dn1_layer ne 'NONE' && $dn1_layer ne 'CSUBSTRATE') {
    $lyr2 = $layer_no;
  }

  $area_model0_file = "$area_models_dir"."/";
  $area_model0_file .= "3_"."$src_layer"."_0_NONE_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE";
  $area_model0_file .= ".mdl";
  $existence = $area_model0_file if -e $area_model0_file;
  if ($existence eq "") {
    printf "%s file does not exist\n", $area_model0_file;
    exit;
  }
  `$modelgen_exe eval $area_model0_file 1 0 > __a`;
  open(tmpfile, "__a");
  while(<tmpfile>) {
    @Fld = split(' ', $_, 9999);
    $area0 = 1.e+8 * $Fld[0];
  }
  close(tmpfile);

  $area_model1_file = "$area_models_dir"."/";
  if ($up1_layer_nbors == 1) {
    $area_model1_file .= "3_"."$up1_layer"."_0_NONE_1_"."$src_layer"."_0_NONE_0_CSUBSTRATE";
  }
  elsif ($dn1_layer_nbors == 1) {
    $area_model1_file .= "3_"."$src_layer"."_0_NONE_1_"."$dn1_layer"."_0_NONE_0_CSUBSTRATE";
  }
  $area_model1_file .= ".mdl";

  $existence = $area_model1_file if -e $area_model1_file;
  if ($existence eq "") {
    printf "%s file does not exist\n", $area_model1_file;
    exit;
  }
  `$modelgen_exe eval $area_model1_file 1 0 > __a`;
  open(tmpfile, "__a");
  while(<tmpfile>) {
    @Fld = split(' ', $_, 9999);
    $area1 = 1.e+8 * $Fld[0];
  }
  close(tmpfile);
  unlink("__a");

  return($area0, $area1, $lyr1, $lyr2);
}
###################################################################################
sub get_corner_cap() {

  my($model_file, $i0, $i1) = @_;
  
  `$modelgen_exe eval $model_file 1 1 $i0 $i1 > __a`;
  open(tmpfile, "__a");
  while(<tmpfile>) {
    @Fld = split(' ', $_, 100);
    $corner_cap = $Fld[2];
  }
  close(tmpfile);
  unlink("__a");

  return($corner_cap);
}
