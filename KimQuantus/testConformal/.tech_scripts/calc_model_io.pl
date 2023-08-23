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

sub calc_model_io() {

  my($same_layer_nbors, $up1_layer_nbors, $dn1_layer_nbors, $up2_layer_nbors, $dn2_layer_nbors,
     $src_layer_no, $up1_layer_no, $dn1_layer_no, $up2_layer_no, $dn2_layer_no, $extension, $high_opt) = @_;
     
  my($neighbors, $num_op_to_subtract, $offset1, $offset2);
  my($num_inputs, $num_outputs, $order);
  
  # introduce -high options for 2d modeling
  my $num_hidden_multiplier = 1.0;  
#  if ($high_opt && $extension < 5 && $extension > 7) {
  if ($high_opt) { 
    $num_hidden_multiplier = $num_hidden_multiplier * 1.3;
  }

  ($l0_nbors_numerical, $l0_nbors_literal) = process_nbor(\$same_layer_nbors);
  ($up1_nbors_numerical, $up1_nbors_literal) = process_nbor(\$up1_layer_nbors);
  ($up2_nbors_numerical, $up2_nbors_literal) = process_nbor(\$up2_layer_nbors);
  ($dn1_nbors_numerical, $dn1_nbors_literal) = process_nbor(\$dn1_layer_nbors);
  ($dn2_nbors_numerical, $dn2_nbors_literal) = process_nbor(\$dn2_layer_nbors);
  
  $distinct_nbors = $l0_nbors_numerical + $up1_nbors_numerical + $up2_nbors_numerical + 
    $dn1_nbors_numerical + $dn2_nbors_numerical;
  $density_nbors = $l0_nbors_literal + $up1_nbors_literal + $up2_nbors_literal + 
    $dn1_nbors_literal + $dn2_nbors_literal;

  $neighbors = $distinct_nbors + $density_nbors;
  $num_inputs = 2 * $distinct_nbors + $density_nbors + 1;
  $num_outputs = $distinct_nbors + 1;

  $num_op_to_subtract = 0;
  if ($extension == 2) {
    $num_op_to_subtract = 2;
  }
  elsif ($extension == 1) {
    $num_op_to_subtract = 2;
  }
  elsif ($extension == 0) {
    $num_op_to_subtract = 1;
  }
  
  if ($up2_nbors_numerical != 0) {
    $num_outputs -= $num_op_to_subtract;
  }
  if ($dn2_nbors_numerical != 0) {
    $num_outputs -= $num_op_to_subtract;
  }
  
  if ($extension == 1) {
    $num_inputs += 1;
    
    if ($up1_nbors_numerical != 0) {
      $num_outputs -= 1;
    }
    if ($up2_nbors_numerical != 0) {
      $num_outputs -= (1 - $up2_nbors_literal);
    }
    if ($dn1_nbors_numerical != 0) {
      $num_outputs -= 1;
    }
    if ($dn2_nbors_numerical != 0) {
      $num_outputs -= (1 - $dn2_nbors_literal);
    }
    
  }
  elsif ($extension == 0) {
    $num_inputs += 2;
    $num_outputs = 1;
  }
  elsif ($extension == 2) {
    if ($num_outputs > 9) {
      $num_outputs = 9;
    }
  }
  elsif ($extension == 8) {
    $num_inputs -= $density_nbors;
    if ($density_nbors == 0) {
      $num_outputs -= 2;
    }
  }
  elsif ($extension == 9) {
    $num_inputs += $density_nbors;
  }
  use POSIX;
  if ($num_layer < 4) {
    if ($extension == 4) {
      $order = ceil($num_hidden_multiplier*1.25 * ($num_inputs + $num_outputs));
    }
    elsif ($extension == 1) {
      $order = ceil(2 * ($num_inputs + $num_outputs));
    }
    elsif ($extension == 0) {
      $order = ceil($num_hidden_multiplier*1.25 * ($num_inputs + $num_outputs));
    }
    else {
      $order = ceil($num_hidden_multiplier*1.5 * ($num_inputs + $num_outputs));
    }
  }
  elsif ($num_layer < 5) {
    if ($extension == 4) {
      $order = ceil($num_hidden_multiplier*1.25 * ($num_inputs + $num_outputs));
    }
    elsif ($extension == 1) {
      $order = ceil($num_hidden_multiplier*2.5 * ($num_inputs + $num_outputs));
    }
    elsif ($extension == 0) {
      $order = ceil($num_hidden_multiplier*1.5 * ($num_inputs + $num_outputs));
    }
    else {
      $order = ceil($num_hidden_multiplier*2. * ($num_inputs + $num_outputs));
    }
  }
  else {
    if ($extension == 4) {
      $order = ceil($num_hidden_multiplier*1.25 * ($num_inputs + $num_outputs));
    }
    elsif ($extension == 1) {
      $order = ceil($num_hidden_multiplier*2.75 * ($num_inputs + $num_outputs));
    }
    elsif ($extension == 0) {
      $order = ceil($num_hidden_multiplier*1.75 * ($num_inputs + $num_outputs));
    }
    else {
      $order = ceil($num_hidden_multiplier*2.25 * ($num_inputs + $num_outputs));
    }
  }
  
  return($num_inputs, $num_outputs, $order);
}
##########################################################################################
sub process_nbor() {

  my($address) = @_;
  my($nbors, $pos);

  $nbors = $$address;
  
  $density_term = "D";
  if (index($nbors, 'F') != -1) {
    $density_term = "F";
  }

  $pos = index($nbors, $density_term);
  if ($pos == -1) {
    return($nbors, 0);
  }
  else {
    my(@Fld);
    @Fld = split($density_term, $nbors, 1000);
    if ($pos == 0) {
      $$address = $#Fld;
      return(0, $#Fld);
    }
    else {
      $$address = substr($nbors, 0, $pos) + $#Fld;
      return(substr($nbors, 0, $pos), $#Fld);
    }
  }

}

1;
