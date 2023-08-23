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

#testmyself();
#testmyself_corner();
#testmyself_interpolate();
#testmyself_remove_empty_lines();

########################################################################
sub testmyself () {
  $perm_file = "RCgenSenseFile";
  ($perm_strings, $perm_active_layers, $perm_values, $num_permutations, $perm_values_nm) = get_permutations("RCgenSenseFile");
#  print "active @$perm_active_layers \n";
  $varied = check_model_varied($perm_active_layers, "METAL_AA");
  print "varied $varied \n";
  $varied = check_model_varied($perm_active_layers, "METAL_1");
  print "varied $varied \n";
 
  @layer_arr = permutes_for_layer($perm_strings, $perm_active_layers, "METAL_1");
  print "layer_arr @layer_arr \n";

  print "vals in nanometeres".$perm_values_nm->[0]." \n ";

}
###########################################################################################
sub testmyself_corner () {
  $cor_file = "RCgenCornerFile";
  $num_corners = get_number_of_corners($cor_file);
  print "num_corners $num_corners \n";
  ($alpha, $beta) = get_interpol_coeffs("H_METAL_1_IN_1_0_0", "H_METAL_1_IN_0_0_-15");
  print " alpha $alpha beta $beta  \n";

  print "name 0 : ".get_corner_name($cor_file, 0)."\n";
  print "name 1 : ".get_corner_name($cor_file, 1)."\n";

  ($perm_strings, $perm_active_layers, $perm_values, $num_permutations) =
            get_permutations_for_corner($cor_file, 0);
  print "string for corner 1 @$perm_strings \n";

  ($perm_strings, $perm_active_layers, $perm_values, $num_permutations) =
            get_permutations_for_corner($cor_file, 1);
  print "string for corner 2 @$perm_strings \n";
  $test_dir = "/home/rusakov/sandbox_nxcaps/nxcaps/src/SIMPLE_VAR_2/sensitivity_models/profiles";
  find_all_permutation_model("2_METAL_1_0_NONE_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE", $test_dir, "W");
}
###########################################################################################
sub testmyself_interpolate () {
use strict;
  interpolate("2_METAL_1_P_METAL_2_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE/2_METAL_1_P_METAL_2_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE.dat",  
              "W_METAL_1_15_0_0_2_METAL_1_P_METAL_2_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE/W_METAL_1_15_0_0_2_METAL_1_P_METAL_2_0_CSUBSTRATE_0_NONE_0_CSUBSTRATE.dat",
              "W_METAL_1_15_0_0", 
              "W_METAL_1_15_0_0", 
               5);

}
###########################################################################################
sub testmyself_remove_empty_lines () {
use strict;
  remove_empty_lines_from_file("varfile", "varfile_out");
}

###########################################################################################
sub get_permutations() {
  use strict;
  my($perm_file) = @_;

  my(@perm_strings, @perm_active_layers, @perm_values, $num_permutations, $pname, @perm_actual_vals_nm);
  my($value1, $value2, $value3, $pname, $type);
  my ($permutation, @Fld);

  open(in, "$perm_file") || die "GetPermutations:Can not open $perm_file \n";

  $num_permutations = 0;
  while (<in>) {
     $permutation = $_;
     chomp($permutation);
     $permutation = trim($permutation);

#     print "permutation $permutation \n";
     ($perm_strings [$num_permutations], $perm_active_layers[$num_permutations], $perm_actual_vals_nm[$num_permutations])
          = parse_input_string($permutation);

#     print $perm_strings [$num_permutations]."\n"; 
#     print "$perm_active_layers[$num_permutations] \n";

     ($value1, $value2, $value3, $pname, $type) =  parse_permutation_string($perm_strings [$num_permutations]);

#     print $value1, $value2, $value3." name $pname type $type \n";
     $perm_values[$num_permutations] = [ $value1, $value2, $value3 ];
#     print $perm_values[$num_permutations][0]. "\n";
     $num_permutations++;
  }

  return(\@perm_strings, \@perm_active_layers, \@perm_values, $num_permutations, \@perm_actual_vals_nm);
}

###########################################################################################
sub get_permutations_for_corner() {
  use strict;
  my($cor_file, $num_corner) = @_;

  my(@perm_strings, @perm_active_layers, @perm_values, $num_permutations, $pname);
  my($value1, $value2, $value3, $pname, $type);
  my ($permutation, @Fld, $line);

  open(infile, $cor_file) || die "GetPermutations:Can not open $cor_file \n";

  $num_permutations = 0;

  while (<infile>) {
     $line = $_;
     chomp($line);
     @Fld = split(' ', $line, 9999);           
#     print "Fld[0] $Fld[0] Fld[1] $Fld[2]\n" ;
     if ($Fld[0] eq "corner" && $Fld[1] eq $num_corner)  {
	last
     }
  }

  while (<infile>) {
     $permutation = $_;
     chomp($permutation);
     @Fld = split(' ', $permutation, 9999);           

     if ($Fld[0] eq "endcorner")  {
       last;
     }

     ($perm_strings [$num_permutations], $perm_active_layers[$num_permutations]) = parse_input_string($permutation);

#     print $perm_strings [$num_permutations]."\n"; 
#     print $perm_active_layers[$num_permutations]."\n";

     ($value1, $value2, $value3, $pname, $type) =  parse_permutation_string($perm_strings [$num_permutations]);

#     print $value1, $value2, $value3." name $pname type $type \n";
     $perm_values[$num_permutations] = [ $value1, $value2, $value3 ];
#     print $perm_values[$num_permutations][0]. "\n";
     $num_permutations++;
  }

  return(\@perm_strings, \@perm_active_layers, \@perm_values, $num_permutations);
}

###########################################################################################
#
# return an array of permutation string for every model
#
###########################################################################################
sub check_modelname_varied {
  use strict;    
  my ($perm_strings, $perm_active_layers, $model_name, $raw_layer_addr, $layer_addr, $script_dir, $gnd_layer, $no_layer, $halo) = @_;
  my @layers = @{$raw_layer_addr};

  my $strategy = "intelligent0"; #could be also "total" and "intelegent0"

  require "$script_dir"."/parse_profile.pl";
  my ($same_layer_nbors, $up1_layer_nbors, $dn1_layer_nbors, $up2_layer_nbors, $dn2_layer_nbors,
      $src_layer_no, $up1_layer_no, $dn1_layer_no, $up2_layer_no, $dn2_layer_no) =
      parse_profile($model_name, $layer_addr);

 # print " layer addr $layer_addr->[0] \n"; 

  my $varied = 0;
  my @sens_layer_perm_string;
  
#  print " model_name $model_name  \n src_layer_no $src_layer_no up1_layer_no $up1_layer_no, dn1_layer_no $dn1_layer_no \n";
 
  if ($strategy eq "total") {
    #
    #every permutation affects every model
    #
    $varied = 1;
    @sens_layer_perm_string = @{$perm_strings};
  }
  elsif ($strategy eq "aggressor_only") {
    #
    #every permutation affects models which src eq any of permutation active_metal
    #
    $varied = check_model_varied ($perm_active_layers, $layers[$src_layer_no]);
    my $layer_i_name = $layers[$src_layer_no];
    @sens_layer_perm_string = permutes_for_layer($perm_strings, $perm_active_layers, $layer_i_name);
  }
  elsif ($strategy eq "intelligent0") {
    #
    # if any of layers between dn1 and up1 are in active_metal list then model is affected
    #    
    my %seen = ();
    
    my ($start, $finish); #analyse layers between start and finish 

    #find start position
    if ($dn1_layer_no eq $gnd_layer || $dn1_layer_no eq $no_layer) {
      $start = 0;
    }
    else {
      $start = $dn1_layer_no;
    }
    #find end position
    if ($up1_layer_no eq $gnd_layer || $up1_layer_no eq $no_layer) {
      $finish = $src_layer_no;
    }
    else {
      $finish = $up1_layer_no;
    }

    print "start    $start finish $finish \n";
    if ( $finish - $src_layer_no > $halo) {
      $finish = $src_layer_no + $halo;
    }
    if ( $src_layer_no - $start > $halo) {
      $start = $src_layer_no - $halo;
    }
    
    for(my $i = $start; $i <= $finish; $i++) {
      $varied = 0;
      my $layer_i_name = $layers[$i];
      $varied = check_model_varied ($perm_active_layers, $layer_i_name);
      #ok we see here that something is changing here. So we have to analyze it more precisely
      if ($varied) {
        my @local_sens_layer_perm_string = permutes_for_layer($perm_strings, $perm_active_layers, $layer_i_name);
      
        foreach my $p (@local_sens_layer_perm_string) {
          my ($value1, $value2, $value3, $pname, $type) =  parse_permutation_string($p);


#          print "p $p type $type i $i src_layer_no $src_layer_no \n"; 
          if ($type eq "H" && $i ne $src_layer_no) {          
            #analysis for ILD layers. Are they between src layer and neighbout           victim? 
            #get number of active layers
            my $not_affects = 0;
            for ( my $j = 0; $j < @{$perm_strings}; $j++ ) {
#              print "perm_strings  $perm_strings->[$j] \n"; 
              if  ($perm_strings->[$j] eq $p) {
                my @active_layers = parse_active_layers($perm_active_layers->[$j]); 
                foreach my $layer_name (@active_layers) {
                  if (!$layer_name) {
                    next;
                  }
                  my $layer_number = get_metal_layer_number($layer_name, @layers[0 .. @layers-2] );
#                  print "layer_name $layer_name layer_number $layer_number \n";
                  if ($layer_number < $start || $layer_number > $finish) {
                    $not_affects = 1;
                  }
                } #foreach
              }
            }

            if (!$not_affects) {
              push (@sens_layer_perm_string, $p) unless $seen{$p}++;
            }
            next;
          }

          if ( $type ne "W" || $i eq $src_layer_no) { 
            #width permutation affects only on agrressor layer"
            #leave only unique elements 
            push (@sens_layer_perm_string, $p) unless $seen{$p}++;
          }
          



        } #foreach
      }  #if ($varied) 
      
    } #for 
  }

  return (@sens_layer_perm_string);
}
########################################################################################### 

sub check_model_varied {
  use strict;
  my($perm_active_layers, $src_name) = @_;
  my ($i, $j); 

#  print "active @$perm_active_layers \n";
  for ($i = 0; $i < @$perm_active_layers; $i++) {
    my @active_layers = parse_active_layers($perm_active_layers->[$i]);
    my $varied = get_metal_layer_number($src_name, @active_layers);
    if ($varied > -1 ) {
      return 1;
    }

  }
  return 0;
}
###########################################################################################
sub permutes_for_layer {
  use strict;
  my($perm_strings, $perm_active_layers, $src_name) = @_;
  my ($i,$n, $j); 
  my (@permutes); 

#  print "active @$perm_active_layers \n";
  $n = 0;
  for ($i = 0; $i < @$perm_active_layers; $i++) {
    my @active_layers = parse_active_layers($perm_active_layers->[$i]);
    foreach $j (@active_layers) {
      if ($j eq $src_name) {
        $permutes[$n] = $perm_strings->[$i];
        $n++;
      }
    }
  }
  return (@permutes);
}
###########################################################################################
sub get_metal_layer_number{
  use strict;
  my ($layer_name, @layers) = @_;
#  print "layer_name $layer_name \n";
  for (my $j = 0; $j < @layers; $j++ ) {
#     print "j $j layers[$j] $layers[$j]\n";
    if ($layers[$j] eq $layer_name) {
      return $j;
    }
  }
  return -1;
};
###########################################################################################
#does not work
sub permutation_files_exists {
  use strict;
  my($ext1, $mdir, $ext2) = @_;
  opendir (DIR, $mdir);
  my @files = grep {/$ext1*$ext2/} readdir (DIR);
  print "{ ($ext1, $mdir, $ext2) }\n";
  print "get_per ".scalar(@files)."\n";
  return ( scalar(@files) );
}

########################################################################
sub interpolate  {
 use strict;
 
 my ($nominal_dat, $sens_dat, $sens_dat_perm_string, $actual_perm_string, $num_inputs, $script_dir) = @_;
 my ($alpha, $beta) = get_interpol_coeffs($sens_dat_perm_string, $actual_perm_string);
 print " alpha $alpha  beta  $beta \n";


 print "$script_dir/caps_a_pls_b.pl $nominal_dat $sens_dat $nominal_dat.tmp $alpha $beta $num_inputs\n";

 `perl $script_dir/caps_a_pls_b.pl $nominal_dat $sens_dat $nominal_dat.tmp $alpha $beta $num_inputs`;
 `mv $nominal_dat.tmp $nominal_dat`;
}
 
###########################################################################################
sub get_interpol_coeffs ($perm_string_sens, $curr_perm_string) {
  use strict;
  my($perm_string_sens, $curr_perm_string) = @_;  
  my($alpha, $beta, $val_sens, $val_curr);
  my (@values); 

  ($values[0], $values[1], $values[2]) = parse_permutation_string($perm_string_sens);
  #find first non zero value to calculate slopes
  for (my $i=0; $i < 3; $i++) {
#    print " values[$i] $values[$i]\n";
    if ($values[$i]) {
      $val_sens = $values[$i];
      last;
    }
  }


  ($values[0], $values[1], $values[2]) = parse_permutation_string($curr_perm_string);
  #find first non zero value to calculate slopes
  for (my $i=0; $i < 3; $i++) {
    if ($values[$i]) {
      $val_curr = $values[$i];
      last;
    }
  }

  #coef before nominal field solver data. 
  $alpha = 1.0;
  $beta  = $val_curr / $val_sens;
  return ($alpha, $beta);
}

###########################################################################################
sub get_corner_name {
  use strict;
  my($cor_file, $num_corner) = @_;
  my($line, @Fld, $number_of_corners, $cor_name);

  $number_of_corners = get_number_of_corners($cor_file); 
  if ($number_of_corners < $num_corner) {
    print "Incorect corner number in get_corners_name";
    exit(1);
  }
  open(infile, $cor_file) || die "GetPermutations:Can not open $cor_file \n"; 
  while (<infile>) {
     $line = $_;
     chomp($line);
     @Fld = split(' ', $line, 9999);           
#     print "Fld[0] $Fld[0] Fld[1] $Fld[2]\n" ;
     if ($Fld[0] eq "corner" && $Fld[1] eq $num_corner)  {
       $cor_name = $Fld[2];
       last;
     }
  }
  return ($cor_name);
}


###########################################################################################
# the same name conventions as in RCgen
###########################################################################################
sub get_corner_ict_name () {
  use strict;

  my($cor_file, $num_corner, $nominal_ict_name) = @_;
  my($line, @Fld, $number_of_corners, $cor_name);
  $number_of_corners = get_number_of_corners($cor_file); 
  if ($number_of_corners < $num_corner) {
    print "Incorect corner number in get_corners_name";
    exit(1);
  }

  open(infile, $cor_file) || die "GetPermutations:Can not open $cor_file \n";
  while (<infile>) {
     $line = $_;
     chomp($line);
     @Fld = split(' ', $line, 9999);           
#     print "Fld[0] $Fld[0] Fld[1] $Fld[2]\n" ;
     if ($Fld[0] eq "corner" && $Fld[1] eq $num_corner)  {
       $cor_name = $Fld[2];
       last;
     }
  }


  #remove extenstion
  $nominal_ict_name  =~ s/.ict$//;
  $nominal_ict_name .= "_".$cor_name.".ict";
  return ($nominal_ict_name);
}


###########################################################################################
sub get_number_of_corners {
  use strict;
  my($cor_file) = @_;
  my($line, @Fld, $number_of_corners);

  open(infile, $cor_file) || die "GetPermutations:Can not open $cor_file \n";
  while (<infile>) {
     $line = $_;
     chomp($line);
     @Fld = split(' ', $line, 9999);           
#     print "Fld[0] $Fld[0] Fld[1] $Fld[1]\n" ;
     if ($Fld[0] eq "number_of_corners")  {
	$number_of_corners = $Fld[1];
        last;
     }
  }
  close (infile);
  return ($number_of_corners);
}

###########################################################################################
sub parse_permutation_string {
  use strict;
  my($permutation_string) = @_;
  my($perm_name, $value1, $value2, $value3, $pname, $type);   
  my($where, $i);
  my (@Fld , $k);

  @Fld = split('_', $permutation_string, 9999);
  $k = 0;
  foreach $i (reverse(@Fld)) {
  
    if ($k == 0) {
      $value3  = $i;
    }
    if ($k == 1) {
      $value2  = $i;
    }
    if ($k == 2) {
      $value1  = $i;
      last;
    }
    $k++;
  }

#get name of permutation
  $where = rindex ($permutation_string, "_") ;
  $where = rindex ($permutation_string, "_", $where-1) ;
  $where = rindex ($permutation_string, "_", $where-1) ;
  $pname = substr ($permutation_string, 0, $where);
#get type of permutation
  $where = index ($permutation_string, "_", 0) ;
  $type  = substr ($permutation_string, 0, $where);

#  print "End: $value1 $value2 $value3 $pname\n" ;
  return($value1, $value2, $value3, $pname, $type);
}

########################################################################
#
#  Input nominal profile name and directory. Output: A set of existing 
#  permuted profiles in sensitive profile directory
#
########################################################################
sub find_all_permutation_model  {
  use strict;
  my ($profile_name, $sens_profile_dir, $extension) = @_; 
  my (@profiles); 
  my (@list, $i);
  my (@list_permutation_strings);

#  print " extension $extension \n";
  @list = glob ("$sens_profile_dir/$extension*$profile_name*");
#  foreach $i (@list) {  print "$i\n;"}

  foreach $i (@list) {
#    print $i = s/$profile_name/
    my $where    = index ($i,$profile_name);
    my $where2   = rindex ($i, "/");
    my $p_string = substr ($i, $where2+1, $where - $where2 - 2  );
#    print "profile_name $profile_name\n";
#    print "i $i\n";
#    print "p_string $p_string \n where $where where2 $where2 \n";
    push(@list_permutation_strings, $p_string);    
  }
#  foreach $i (@list_permutation_strings) {  print "$i\n"}
  return(\@list, \@list_permutation_strings);
}
########################################################################
sub parse_active_layers() {
  use strict;
  my ($active_string) = @_; 
  my @Fld = split(' ', $active_string, 9999);           
  return @Fld;
}
########################################################################
sub trim {
  use strict;
  my @out = @_;
  for (@out) {
    s/^\s+//;
    s/\s+$//;
  }
  return wantarray ? @out : $out[0];
}
########################################################################
sub parse_input_string { 
 use strict; 
 my ($permutation) = @_;
 my ($perm_strings, $perm_active_layers, $perm_actual_vals_nm);

 my @Fld = split(' ', $permutation, 9999);                
 if ($Fld[0] eq "*")  {
   next;
 }
 

 my $sz = @Fld;
# print " sz $sz permutation $permutation \n";
 $perm_strings = $Fld[0];           

 my ($start_vals, $end_vals);
 for ( my $kk = 0; $kk < $sz; $kk++ ){
#   print "kk $kk  Fld $Fld[$kk] start_vals $start_vals end_vals $end_vals \n";
   if ($Fld[$kk] eq "{") { $start_vals = $kk;     }
   if ($Fld[$kk] eq "}") { $end_vals = $kk; last; }            
 }

 $perm_actual_vals_nm = join (" ", @Fld[($start_vals+1 .. $end_vals - 1)]);     
 $perm_active_layers  = join (" ", @Fld[($end_vals+1 .. $sz)]);     

# print "perm_strings $perm_strings perm_active_layers $perm_active_layers, perm_actual_vals_nm $perm_actual_vals_nm \n";
 return ($perm_strings, $perm_active_layers, $perm_actual_vals_nm);
}

########################################################################
#
#   choose from several values some more a less reasonable. 
#
########################################################################
sub permutation_parse_vals_in_nm {
  use strict;
  my ($perm_actual_values_nm) = @_;
  my @Fld = split(' ', $perm_actual_values_nm, 9999);                
  
  my $max_val = 0;
  foreach my $val (@Fld) {
    if (abs($val) > abs($max_val) ) {$max_val = $val;}
  }
  return $max_val;
}

########################################################################
#
#
#
########################################################################
sub get_actual_permutation_vals_in_nm{
  my ($perm_string, $perm_strings, $perm_actual_values_nm) = @_;
  my $sz = @$perm_strings;
  my $val=1;
  for (my $kk = 0; $kk < $sz; $kk++) {
    if ($perm_string eq $perm_strings->[$kk]) {
      $val = permutation_parse_vals_in_nm($perm_actual_values_nm->[$kk]);
      return $val;  
    }
  }
  return $val;   
}
########################################################################
#
#
#
########################################################################
sub remove_empty_lines_from_file{
  use strict;
  my ($input_file, $output_file)= @_;

  open(infile, "< $input_file")  || die("Cannot open $input_file :\n$!\n");
  open(outfile,"> $output_file") || die("Cannot open $output_file:\n$!\n");  
  while (<infile>) {  
    my $line = $_;
    chomp($line);
    $line = trim($line);
    if ($line) {
      print(outfile $line."\n");  
    }
  }
}

1;
