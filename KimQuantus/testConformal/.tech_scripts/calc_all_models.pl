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
sub calc_models($$$) {
#  use strict;
  my($extension, $layer_addr, $output, $vhcnt_addr, $vh_addr, $attrib_addr, $special, $special4lat, $backside_metals) = @_;

  my $layer_cnt = $#$layer_addr + 1;
  my @layers = @$layer_addr;
  my @attribs = @$attrib_addr;

  my (@new_layers, @new_layer_attribs);
  @layer_map_ = (); # global variable
 
  my $i , $h = 0;
  my $is_cap_layers = 0;
  for($i = 0; $i <= $#layers; $i++)  {
    if($attribs[$i] != 4) {
      $new_layers[$h] = $layers[$i];
      $new_layer_attribs[$h] = $attribs[$i];
      $layer_map_[$h] = $i;
      $h++;
    }
    else {
      $is_cap_layers = 1;
    }
  }
  
  $possible_2models[0] = "1 0 0 0 b";
  $possible_2models[1] = "2 0 0 0 b";
  $possible_2models[2] = "0 1 0 0 b";
  $possible_2models[3] = "0 2 0 0 b";

  if ($extension < 3 || $extension == 13 || ($special4lat && $extension == 4) ) {
    $possible_2models[4] = "3 0 0 0 b";
    $possible_2models[5] = "4 0 0 0 b";
    $possible_2models[6] = "0 3 0 0 b";
    $possible_2models[7] = "0 4 0 0 b";
    $possible_2models[8] = "5 0 0 0 b";
    $possible_2models[9] = "6 0 0 0 b";
    $possible_2models[10] = "0 5 0 0 b";
    $possible_2models[11] = "0 6 0 0 b";
  }

  if ($extension < 3 || $extension >= 8 || ($special4lat && $extension == 4) ) {
    $possible_3models[0] = "1 0 2 0 b";
    $possible_3models[1] = "0 1 0 2 b";
    $possible_3models[2] = "1 1 0 0 b";
    $possible_3models[3] = "1 2 0 0 b";
    $possible_3models[4] = "2 1 0 0 b";
    $possible_3models[5] = "2 2 0 0 b";
  }
  if ($extension < 3 ||  ($special4lat && $extension == 4) ) {
    $possible_3models[6] = "1 0 3 0 b";
    $possible_3models[7] = "0 1 0 3 b";
    $possible_3models[8] = "2 0 3 0 b";
#    $possible_3models[9] = "2 0 4 0 p";
    $possible_3models[9] = "2 0 4 0 b";
    $possible_3models[10] = "0 2 0 3 b";
#    $possible_3models[11] = "0 2 0 4 p";
    $possible_3models[11] = "0 2 0 4 b";
  }

  if ($extension ==  2 && $special == 2 ) {
    $possible_3models[12] = "3 1 0 0 b";
    $possible_3models[13] = "3 2 0 0 b";
    $possible_3models[14] = "3 3 0 0 b";
    $possible_3models[15] = "4 1 0 0 b";
    $possible_3models[16] = "4 2 0 0 b";
    $possible_3models[17] = "4 3 0 0 b";
    $possible_3models[18] = "4 4 0 0 b";
    $possible_3models[19] = "5 1 0 0 b";
    $possible_3models[20] = "5 2 0 0 b";
    $possible_3models[21] = "5 3 0 0 b";
    $possible_3models[22] = "5 4 0 0 b";
    $possible_3models[23] = "5 5 0 0 b";
    $possible_3models[24] = "6 1 0 0 b";
    $possible_3models[25] = "6 2 0 0 b";
    $possible_3models[26] = "6 3 0 0 b";
    $possible_3models[27] = "6 4 0 0 b";
    $possible_3models[28] = "6 5 0 0 b";
    $possible_3models[29] = "6 6 0 0 b";
    
    $possible_3models[30] = "1 3 0 0 b";
    $possible_3models[31] = "2 3 0 0 b";
    $possible_3models[32] = "1 4 0 0 b";
    $possible_3models[33] = "2 4 0 0 b";
    $possible_3models[34] = "3 4 0 0 b";
    $possible_3models[35] = "1 5 0 0 b";
    $possible_3models[36] = "2 5 0 0 b";
    $possible_3models[37] = "3 5 0 0 b"; 
    $possible_3models[38] = "4 5 0 0 b";
    $possible_3models[39] = "1 6 0 0 b";
    $possible_3models[40] = "2 6 0 0 b";
    $possible_3models[41] = "3 6 0 0 b";
    $possible_3models[42] = "4 6 0 0 b";
    $possible_3models[43] = "5 6 0 0 b";
  }
  


# Since the 4 layer and 5 layer models are unused, eliminate them for now
  $possible_4models[0] = "1 1 2 0 b";
  $possible_4models[1] = "1 1 3 0 p";
  $possible_4models[2] = "1 1 0 2 b";
  $possible_4models[3] = "1 1 0 3 p";
  $possible_4models[4] = "2 1 3 0 p";
  $possible_4models[5] = "2 1 4 0 p";
  $possible_4models[6] = "2 1 0 2 b";
  $possible_4models[7] = "2 1 0 3 p";
  $possible_4models[8] = "1 2 2 0 b";
  $possible_4models[9] = "1 2 3 0 p";
  $possible_4models[10] = "1 2 0 3 p";
  $possible_4models[11] = "1 2 0 4 p";
  $possible_4models[12] = "2 2 3 0 p";
  $possible_4models[13] = "2 2 4 0 p";
  $possible_4models[14] = "2 2 0 3 p";
  $possible_4models[15] = "2 2 0 4 p";
 
  $possible_5models[0] = "1 1 2 2 b";
  $possible_5models[1] = "1 1 3 2 p";
  $possible_5models[2] = "1 1 2 3 p";
  $possible_5models[3] = "1 1 3 3 p";
  $possible_5models[4] = "2 1 3 2 p";
  $possible_5models[5] = "2 1 4 2 p";
  $possible_5models[6] = "2 1 3 3 p";
  $possible_5models[7] = "2 1 4 3 p";
  $possible_5models[8] = "1 2 2 3 p";
  $possible_5models[9] = "1 2 3 3 p";
  $possible_5models[10] = "1 2 2 4 p";
  $possible_5models[11] = "1 2 3 4 p";
  $possible_5models[12] = "2 2 3 3 p";
  $possible_5models[13] = "2 2 4 3 p";
  $possible_5models[14] = "2 2 3 4 p";
  $possible_5models[15] = "2 2 4 4 p";
  
  if ($output ne "") {
    $out1 = "$output"."_base";
    $out2 = "$output"."_pruned";
    open(outfile, ">$output");
    open(outfile1, ">$out1");
    open(outfile2, ">$out2");
  }
  $total_models = 0;
  $num_pruned_models = 0;
  my $special_lyr = -1;
  for ($i = 0; $i <= $#layers - 2; ++$i) {

    if($attribs[$i] != 4 ){
      $special_lyr++; 
    }
#  Iflayer attribute is 2, this layer is not to be extracted
    if ($attribs[$i] == 2 || $attribs[$i] == 4 ) {
      next;
    }

    if ($output ne "") {
      printf outfile "L %s\n_______\n", $layers[$i];
    }

#
#  Getting the vertical halo information in
#
    $SrcIsRdl = 0;
    $beg = 0;
    $vhalo_cnt = $$vhcnt_addr[$i];
    if ($i > 0) {
      $beg = $$vhcnt_addr[$i - 1];
      $vhalo_cnt -= $$vhcnt_addr[$i - 1];
    }
    if ($vhalo_cnt == $#layers - 2 && $#layers > 2) {
      $SrcIsRdl = 1;
    }
    for ($vlyr = 0; $vlyr < $vhalo_cnt; ++$vlyr) {
      $vhalo[$vlyr] = $i + $$vh_addr[$beg + $vlyr];
    }

#
#  Computing models from degrees 1 to 5
#
    $single_layer_model = 0;
    # Ignoring models 
    if ($SrcIsRdl == 1 &&
        ($extension == 2 || $extension == 4 || $extension == 8 || $extension == 13)) {
      #in case of TSV create single-layer model anyway
      if ($backside_metals)
      {
        $single_layer_model = 1;
      }
      else
      {
        next;
      }
    }
    $start = $pstart = 0;
    if (($extension == 8 || $extension == 9) && ($special != 10)) {
      $deg_start = 2;
    }
    else {
      $deg_start = 1;
    }
    $deg_end = 3;
    #in calse of single_layer model launch compute_models only once  
    if (single_layer_model != 0)
    {
      $deg_end = 1;
      if ($deg_end < $deg_start)
      {
        next;
      }
    }

       
#    for ($degree = 1; $degree <= 5; $degree++) {
    for ($degree = $deg_start; $degree <= $deg_end; $degree++) {
      ($models_addr, $pmodel_addr) = compute_models($i, $special_lyr, $degree, \@layers, \@attribs, $is_cap_layers, \@new_layers,\@new_layer_attribs, $special);
      
      $cnt = $#$models_addr + 1;
      for ($k = 0; $k < $cnt; ++$k) {
        $models[$i][$start + $k] = @$models_addr[$k];
        $model_type[$i][$start + $k] = "B";
        $model_derived[$i][$start + $k] = "";
      }
      
      $pcnt = ($#$pmodel_addr + 1) / 2;
      if ($pcnt > 0) {
        @ptmp_models = @$pmodel_addr;
        for ($k = 0; $k < $pcnt; ++$k) {
          $pmodels[$i][2 * ($pstart + $k)] = $ptmp_models[2 * $k];
          $pmodels[$i][2 * ($pstart + $k) + 1] = $ptmp_models[2 * $k + 1];
        }
      }
      $num_models[$i][$degree - 1] = $cnt;
      $start += $cnt;
      $total_models += $cnt;
      
      $num_pmodels[$i][$degree - 1] = $pcnt;
      $pstart += $pcnt;
      $num_pruned_models += $pcnt;
    }
    
    #
    #   Tag specific base models to be pruned models
    #
    for ($j = $pstart - 1; $j >= 0; --$j) {
      $pmdl = $pmodels[$i][2 * $j + 1];
      ($model_no1) = match_model($pmdl, $start);
      if ($model_no1 != -1) {
        $base_flag = 0;
	($base_flag) = find_model_type($pmodels[$i][2 * $j], $start);
        if ($base_flag > 0) {
          $model_type[$i][$model_no1] = "P";
          $model_derived[$i][$model_no1] = $pmodels[$i][2 * $j];
	}
      }
    }
    #
    #  Print models
    #
    $start = 0;
    for ($j = 0; $j < 5; ++$j) {
      for ($k = $start; $k < ($start + $num_models[$i][$j]); ++$k) {
	if ($output ne "") {
	  printf outfile "D %d:%s %s%s\n", $j + 1, $models[$i][$k],
	  $model_type[$i][$k], $model_derived[$i][$k];
	}
	
	if ($model_type[$i][$k] eq 'B') {
	  print_models(\*outfile1, \@base_models, $extension, $layers[$i], 
                       $models[$i][$k]);
	}
	else {
          print_models(\*outfile2, \@pruned_models, $extension, $layers[$i], 
                       $models[$i][$k], $model_derived[$i][$k]);
	}
      }
      $start += $num_models[$i][$j];
    }
    if ($output ne "") {
      printf outfile "Deg %d: %d ; ", 1, $num_models[$i][0];
      for ($j = 1; $j < 5; ++$j) {
	printf outfile "Deg %d: %d ; ", $j + 1, $num_models[$i][$j];
      }
      printf outfile "\n";
      printf outfile1 "\n";
      printf outfile2 "\n";
    }
  }
  if ($output ne "") {
    close(outfile);
    close(outfile1);
    close(outfile2);
  }

  printf "Total models = %d\n", $total_models;
  return(\@base_models, \@pruned_models);
}
############################################################################################
sub compute_models(\$\$\@\@$\@\@) {
  
  my($lyr_no, $s_lyr_no, $deg, $layers_addr, $attribs_addr, $is_cap_layers, $new_layers, $new_layer_attribs, $special) = @_;
  my($m_addr, $pm_addr);
 
  if ($deg == 1) {
    ($m_addr) = compute_deg1_models();
  }
  elsif ($deg == 2) {
    ($m_addr, $pm_addr) = compute_deg_models_new($deg, $lyr_no, $s_lyr_no,  $layers_addr, $attribs_addr, \@possible_2models, $is_cap_layers, $new_layers, $new_layer_attribs, $special);
  }
  elsif ($deg == 3) {
    ($m_addr, $pm_addr) = compute_deg_models_new($deg, $lyr_no, $s_lyr_no,  $layers_addr, $attribs_addr, \@possible_3models, $is_cap_layers, $new_layers, $new_layer_attribs, $special);
  }
  elsif ($deg == 4) {
    ($m_addr, $pm_addr) = compute_deg_models_new($deg, $lyr_no, $s_lyr_no,  $layers_addr, $attribs_addr, \@possible_4models, $is_cap_layers, $new_layers, $new_layer_attribs, $special);
  }
  elsif ($deg == 5) {
    ($m_addr, $pm_addr) = compute_deg_models_new($deg, $lyr_no, $s_lyr_no,  $layers_addr, $attribs_addr, \@possible_5models, $is_cap_layers, $new_layers, $new_layer_attribs, $special);
  }
  
  return($m_addr, $pm_addr);
}
############################################################################################
sub compute_deg1_models() {
  
  my(@model_name);

  $model_name[0] = " NONE CSUBSTRATE NONE CSUBSTRATE";
  return(\@model_name);
}
############################################################################################
sub compute_deg_models_new()
{
   
  my($deg, $s_lyr, $s_special_lyr,  $addr1, $addr2, $addr3, $is_cap_layer, $addr4, $addr5, $special) = @_;
  my(@layers, @possible_models);

  @layers = @$addr1;
  my @attribs = @$addr2;
  my @new_layers = @$addr4;
  my @new_layer_attribs = @$addr5;

  if($is_cap_layer)  {
    my ($model1, $p_model1) = compute_deg_models($deg, $s_lyr,         $addr1, $addr2, $addr3, 0, $special);
    my ($model2, $p_model2) = compute_deg_models($deg, $s_special_lyr, $addr4, $addr5, $addr3, 1, $special);
    return (merge_model_names("$s_lyr"."_$deg",$model1, $model2), merge_model_names("$s_lyr"."$deg",$p_model1, $p_model2));
  }
 
  else {
    return compute_deg_models($deg, $s_lyr, $addr1, $addr2, $addr3, 0, $special);
  }

}

############################################################################################

sub merge_model_names($\@\@)
{
  my($number, $addr1, $addr2) = @_;

  my %seen = ();
  foreach $item (@$addr1) {
    $seen{$item}++;
  }
 
  foreach $item (@$addr2) {
    $seen{$item}++;
  }
  
  my @return_mas = keys %seen;
  return (\@return_mas);
}
############################################################################################
sub compute_deg_models() {
  my($deg, $s_lyr, $addr1, $addr2, $addr3, $need_map, $special) = @_;
  my(@layers, @possible_models);
  my($num_models, @model_name);
  my($i, $j, $v_lyr, $tmp_name, $cntr, $sign, @Fld);
  my($p_addr, @p_models);

  @layers = @$addr1;
  my @attribs = @$addr2;
  @possible_models = @$addr3;
  my $num_possible_models = $#possible_models + 1;
  
  $num_models = 0;
  for ($i = 0; $i < $num_possible_models; ++$i) {
    @Fld = split(' ', $possible_models[$i], 100);
    
    my $disallowed_layer = 0;
    $sign = -1;
    $cntr = 0;
    $tmp_name = "";
    for ($j = 0; $j < $#Fld; ++$j) {
      $sign *= -1;
      if ($Fld[$j] == 0) {
        if ($j == 0 || $j == 2) {
          $tmp_name .= " NONE";
        }
        else {
          $tmp_name .= " CSUBSTRATE";
        }
        next;
      }
      
      $v_lyr = $s_lyr + $sign * $Fld[$j];
      my $v_lyr_for_halo = $v_lyr ;
      my $s_lyr_for_halo = $s_lyr;
      
      if($need_map == 1) {
        $v_lyr_for_halo = $layer_map_[$v_lyr]; 
        $s_lyr_for_halo = $layer_map_[$s_lyr];
      }
        
            
        
      if ($deg > 2) {
        for (my $ii = 0; $ii < $vhalo_cnt; ++$ii) {
          if ($v_lyr_for_halo == $vhalo[$ii] && abs($v_lyr_for_halo - $s_lyr_for_halo) > 2 && $special != 2 ) {
            $disallowed_layer = 1;
            last;
          }
        }
        if ($disallowed_layer == 1) {
          last;
        }
      }
      if ($v_lyr > ($#layers - 2) || $v_lyr < 0) {
        $disallowed_layer = 1;
        next;
      }
      else {
        $cntr++;
        $tmp_name .= " "."$layers[$v_lyr]";
      }

      if ($disallowed_layer == 1) {
        last;
      }
    }   # end loop for model parser

    if ($cntr == ($deg - 1)) {
      if ($Fld[$#Fld] eq 'p') {
        ($p_addr) = get_pruned_models($deg, $possible_models[$i], $tmp_name);
        if ($#$p_addr > -1) {
          push @p_models, @$p_addr;
        }
      }   
      $model_name[$num_models] = $tmp_name;
      $num_models++;
     
      for (my $ii = 0; $ii < $vhalo_cnt; ++$ii) {
        if ($v_lyr_for_halo == $vhalo[$ii] && abs($v_lyr_for_halo - $s_lyr_for_halo) > 2) {
          $disallowed_layer = 1;
          last;
        }
      }
    }
  }   # end loop for possible models


  #
  #   The array numbering is due to the fact that every 2nd element is the
  #   pruned model
  $i = $j = 0;
  for ($i = 1; $i < $#p_models; $i += 2) {
    for ($j = $i + 2; $j <= $#p_models; $j += 2) {
      if ($p_models[$i] eq $p_models[$j]) {
      splice @p_models, ($j - 1), 2;
      }
    }
  }  
  
  return(\@model_name, \@p_models);
}

sub get_pruned_models() {

    my($deg, $combination, $name) = @_;
    my($num_models, @pruned_combination);
    my(@Fld, @Fld1);

    $num_models = 0;
    @Fld = split(' ', $combination, 10);
    @Fld1 = split(' ', $name, 10);

    if ($Fld[2] - $Fld[0] >= 2) {
      $pruned_combination[2 * $num_models] = $name;
      $pruned_combination[2 * $num_models + 1] = 
        " ".$Fld1[0]." ".$Fld1[1]." NONE ".$Fld1[3];
      $num_models++;
    }
    if ($Fld[3] - $Fld[1] >= 2) {
      $pruned_combination[2 * $num_models] = $name;
      $pruned_combination[2 * $num_models + 1] = 
        " ".$Fld1[0]." ".$Fld1[1]." ".$Fld1[2]." CSUBSTRATE";
      $num_models++;
    }
    if ($deg >= 4) {
      if ($Fld[2] == 3 && ($Fld[2] - $Fld[0]) == 1) {
      $pruned_combination[2 * $num_models] = $name;
      $pruned_combination[2 * $num_models + 1] = 
        " ".$Fld1[0]." ".$Fld1[1]." NONE ".$Fld1[3];
      $num_models++;
      }
      if ($Fld[3] == 3 && ($Fld[3] - $Fld[1]) == 1) {
      $pruned_combination[2 * $num_models] = $name;
      $pruned_combination[2 * $num_models + 1] = 
        " ".$Fld1[0]." ".$Fld1[1]." ".$Fld1[2]." CSUBSTRATE";
      $num_models++;
      }
    }

    return(\@pruned_combination);
}
###############################################################################
sub print_models(\*) {

  my($file, $m_addr, $ext, $str1, $str2, $str3) = @_;
  my($model_name, @Fld);
  my(@nbor);

  if ($ext == 2 || $ext == 4 || $ext >= 8) {
    $nbor[0] = $nbor[1] = 3;
    $nbor[2] = $nbor[3] = 2;
  }
  elsif ($ext == 1) {
    $nbor[0] = $nbor[1] = 3;
    $nbor[2] = $nbor[3] = "DD";
  }
  elsif ($ext == 0) {
    $nbor[0] = $nbor[1] = 3;
    $nbor[2] = $nbor[3] = 3;
  }

  if (length($str2) != 0) {
    $model_name = "$ext"."_"."$str1";
    @Fld = split(' ', $str2, 100);
    if ((index($str1, "DIFFUSION") != -1) && (index($Fld[0], "POLYCIDE") != -1)) {
      if ($ext == 0) {
         return;
      }
      elsif ($ext == 1) {
         $nbor[0] -= 2;
       }
      else {
         $nbor[0] -= 1;
       }
    }
    elsif ((index($Fld[1], "DIFFUSION") != -1) && (index($str1, "POLYCIDE") != -1)) {
      if ($ext == 0) {
         return;
       }
      elsif ($ext == 1) {
         $nbor[1] -= 2;
       }
      else {
        $nbor[1] -= 1;
      }
    }
    $model_name .= add_name($nbor[0],$Fld[0]);
    $model_name .= add_name($nbor[1],$Fld[1]);
    $model_name .= add_name($nbor[2],$Fld[2]);
    $model_name .= add_name($nbor[3],$Fld[3]);
    printf $file "%s ", $model_name;

    push @$m_addr, $model_name;
  }
  if (length($str3) != 0) {
    $model_name = "$ext"."_"."$str1";
    @Fld = split(' ', $str3, 100);
    $model_name .= add_name($nbor[0],$Fld[0]);
    $model_name .= add_name($nbor[1],$Fld[1]);
    $model_name .= add_name($nbor[2],$Fld[2]);
    $model_name .= add_name($nbor[3],$Fld[3]);
    printf $file ": %s\n", $model_name;

    push @$m_addr, $model_name;
  }
  else {
    printf $file "\n";
  }

}
###############################################################################
sub add_name() {

   my($prefix, $str) = @_;
   my($name);

   if (($str eq 'NONE') || ($str eq 'CSUBSTRATE')) {
      $name = "_0_";
   }
   else {
      $name = "_"."$prefix"."_";
   }
   $name .= $str;
   return($name);
}

###############################################################################
sub match_model() {

  my($m1, $beg) = @_;
  my($k);

  for ($k = 0; $k < $beg; ++$k) {
    if ($m1 eq $models[$i][$k]) {
      return($k);
    }
  }
  return(-1);
}
###############################################################################
sub find_model_type() {

  my($m1, $beg) = @_;
  my($k, $base_flag);

  for ($k = 0; $k < $beg; ++$k) {
    if ($m1 eq $models[$i][$k]) {
      $base_flag =  ($model_type[$i][$k] eq "B") ? 1 : 0;
      return($base_flag);
    }
  }
  return(0);
}

1;
