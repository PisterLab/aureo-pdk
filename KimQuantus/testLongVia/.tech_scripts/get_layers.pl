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
sub get_layer_info2() {

  my($mbbfile) = @_;
  my($mbb_addr, $layer_cnt, $raw_layer_addr, $mbb_addr, $vhcnt_addr, $vh_addr);
  my($attrib_addr);
  my(@layers);

  ($layer_cnt, $raw_layer_addr, $mbb_addr, $vhcnt_addr, $vh_addr, $attrib_addr) = get_layer_info($mbbfile);
  
  $layers[$layer_cnt - 2] = $$raw_layer_addr[$layer_cnt - 2];
  $layers[$layer_cnt - 1] = $$raw_layer_addr[$layer_cnt - 1];
  for ($i = 0; $i < $layer_cnt - 2; ++$i) {
    $layers[$i] = "M".$i;
  }

  return($layer_cnt, $raw_layer_addr, \@layers, $mbb_addr, $vhcnt_addr, $vh_addr, $attrib_addr);
}
###########################################################################################
sub get_layer_info() {

  my($mbbfile) = @_;

  my($start_flag, $mbb, $layer_cnt, @layers, @layer_attrib, @mbb_vals, @vhalo, @vhalo_cnt, @Fld);

  $start_flag = 0;
  $layer_cnt = 0;
  open(mbb, "$mbb_file");
  while (<mbb>) {
    @Fld = split(' ', $_, 9999);
  
    if ($Fld[0] eq 'END') {
      last;
    }
    if ($start_flag == 1) {
      if ($#Fld == 3) {
        $layer_attrib[$layer_cnt] = $Fld[2];
      }
      else {
        $layer_attrib[$layer_cnt] = 0;
      }
      $layers[$layer_cnt] = $Fld[0];
      $mbb_vals[$layer_cnt++] = $Fld[1];
    }
    if ($Fld[1] eq 'layer' && $Fld[2] eq 'process') {
      $start_flag = 1;
    }
  }
  $layer_attrib[$layer_cnt] = 0;
  $layers[$layer_cnt] = "NONE";
  $mbb_vals[$layer_cnt++] = 0.;
  $layer_attrib[$layer_cnt] = 0;
  $layers[$layer_cnt] = "CSUBSTRATE";
  $mbb_vals[$layer_cnt++] = 0.;

  for ($i = 0; $i < $layer_cnt - 2; ++$i) {
    $vhalo_cnt[$i] = 0;
  }
  $vhalo[0] = 0;
  $start_flag = 0;
  while (<mbb>) {
    @Fld = split(' ', $_, 1000);
    if ($Fld[0] eq 'END') {
      last;
    }
    if ($start_flag == 1) {
      if ($layer_cnt == 0) {
        $vhalo_cnt[$layer_cnt++] = $#Fld - 1;
      }
      else {
        $vhalo_cnt[$layer_cnt] = $vhalo_cnt[$layer_cnt - 1] + $#Fld - 1;
        ++$layer_cnt;
      }
      for ($i = 1; $i < $#Fld; ++$i) {
         $vhalo[$cnt++] = $Fld[$i];
       }
    }
    if ($Fld[0] eq 'BEGIN' && $Fld[1] eq 'VHALO_DEFINITION') {
      $start_flag = 1;
      $layer_cnt = $cnt = 0;
    }
  }
  close(mbb);
  $layer_cnt = $#layers + 1;

  return($layer_cnt, \@layers, \@mbb_vals, \@vhalo_cnt, \@vhalo, \@layer_attrib);
}
################################################################################################
sub count_gray_layers() {

  my($layer_cnt, $attrib_addr) = @_;
  my($i, $cnt);
 
  $cnt = 0;
  for ($i = 0; $i < $layer_cnt; ++$i) {
    if ($$attrib_addr[$i] == 2) {
      ++$cnt;
    }
  }

  return($cnt);
}
################################################################################################
sub find_Rdl() {

  my($layer_no, $layer_cnt, $vhcnt_addr) = @_;
  my($vhalo_cnt, $IsRdl);
  
  $vhalo_cnt = $$vhcnt_addr[$layer_no];
  if ($layer_no > 0) {
    $vhalo_cnt -= $$vhcnt_addr[$layer_no - 1];
  }
  if ($vhalo_cnt == $layer_cnt - 2 && $layer_cnt > 2) {
    $IsRdl = 1;
  }
  else {
    $IsRdl = 0;
  }

  return($IsRdl);
}
################################################################################################
sub is_equal_backside_properties() {
  my($layer1, $layer2, $back_metals) = @_;

  if($back_metals) {
    @back_metals_arr = split(/,/, $back_metals);
    $back_metal1 = -1;
    $back_metal2 = -1;
    foreach $yui (@back_metals_arr)
    {
        if ($yui eq $layer1) { $back_metal1 = 1; }
        if ($yui eq $layer2) { $back_metal2 = 1; }
    }
#    $back_metal1 = index($back_metals, $layer1);
#    $back_metal2 = index($back_metals, $layer2);
    if($back_metal1 >= 0 && $back_metal2 <  0 ||
       $back_metal1 < 0  && $back_metal2 >= 0) {
      return 0;
    }
  }
  return 1;
}
################################################################################################
sub is_string_in_array() {
  my($str, $array) = @_;

  foreach(@$array) {
    if($_ eq $str) {
      return 1;
    }
  }
  return 0;
}
################################################################################################
1;
