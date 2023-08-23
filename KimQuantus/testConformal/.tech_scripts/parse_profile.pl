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
sub parse_profile {
  use strict;
  
  my($probname, $layer_addr) = @_;

  my(@layers, @layer_array);
  my($pos, $new_pos, $layer_cnt);
  my($same_layer_nbors, $up1_layer_nbors, $dn1_layer_nbors, $up2_layer_nbors, $dn2_layer_nbors, $src_layer_no);
  my($src_layer, $up1_layer, $dn1_layer, $up2_layer, $dn2_layer);
  my($up1_layer_no, $dn1_layer_no, $up2_layer_no, $dn2_layer_no);
  my ( $new_string );

  @layers = @$layer_addr;
  $layer_cnt = $#layers + 1;

  $pos = index($probname, '_');
  $same_layer_nbors = substr($probname, 0, $pos);
  ($new_pos, $src_layer_no) = parse_profile_for_layer($pos + 1, $probname, $layer_cnt, @layers);
  
  $pos = $new_pos;
  $up1_layer_nbors = substr($probname, $pos, 1);
  $pos += 2;
  ($new_pos, $up1_layer_no) = parse_profile_for_layer($pos, $probname, $layer_cnt, @layers);
  
  $pos = $new_pos;
  $dn1_layer_nbors = substr($probname, $pos, 1);
  $pos += 2;
  ($new_pos, $dn1_layer_no) = parse_profile_for_layer($pos, $probname, $layer_cnt, @layers);
  
  $pos = $new_pos;
  $new_string = substr($probname, $pos, length($probname) - $pos);
  $up2_layer_nbors = substr($probname, $pos, index($new_string, '_'));
  $pos += index($new_string, '_') + 1;
  ($new_pos, $up2_layer_no) = parse_profile_for_layer($pos, $probname, $layer_cnt, @layers);
  
  $pos = $new_pos;
  $new_string = substr($probname, $pos, length($probname) - $pos);
  $dn2_layer_nbors = substr($probname, $pos, index($new_string, '_'));
  $pos += index($new_string, '_') + 1;
  ($new_pos, $dn2_layer_no) = parse_profile_for_layer($pos, $probname, $layer_cnt, @layers);
  
  return($same_layer_nbors, $up1_layer_nbors, $dn1_layer_nbors, $up2_layer_nbors, $dn2_layer_nbors,
	 $src_layer_no, $up1_layer_no, $dn1_layer_no, $up2_layer_no, $dn2_layer_no);
}
#################################################################################################
sub parse_profile_for_layer() {
  use strict;
  my($strpos, $profile_string, $layer_cnt, @layers) = @_;
  my($string, $i, $tmp, $new_strbeg, $new_strend, $new_layer_pntr);
  my($lyr_found_flag);

  $lyr_found_flag = 0;

  $string = substr($profile_string, $strpos, length($profile_string));
  $new_strbeg = $new_strend = 100000000;
  for ($i = 0; $i < $layer_cnt; ++$i) {
    my $match_string = $layers[$i];
    if ($string =~ /^$match_string[\s_]/ ||
        $string =~ /^$match_string$/) {
      $tmp = index($string, $layers[$i]);
      if ($tmp < $new_strbeg) {
	$new_strbeg = $tmp;
	$new_strend = $tmp + length($layers[$i]);
	$new_layer_pntr = $i;
        $lyr_found_flag = 1;
        last;
      }
    }
  }

  if ($lyr_found_flag == 0) {
    warn("Layer not found in parse_profile_layer subroutine. Please check your layer stack names");
  }
  $new_strend += $strpos + 1;
  return($new_strend, $new_layer_pntr);
}
#####################################################################################################
sub join_profile() {
  use strict;
  my($ext, $up1, $dn1, $up2, $dn2, $src_no, $up1_no, $dn1_no, $up2_no, $dn2_no, $rawlayer_addr) = @_;
  my $model_name;
  $model_name = $ext."_".$$rawlayer_addr[$src_no]."_";
  $model_name .= $up1."_".$$rawlayer_addr[$up1_no]."_";
  $model_name .= $dn1."_".$$rawlayer_addr[$dn1_no]."_";
  $model_name .= $up2."_".$$rawlayer_addr[$up2_no]."_";
  $model_name .= $dn2."_".$$rawlayer_addr[$dn2_no];

  return($model_name);
}
1;
