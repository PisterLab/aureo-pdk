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
#use miscutils;

GetOptions("ict=s", "old_tech:s", "out=s", "v=s", "profile:s", "model:s", "h", "test", "sensitivity=s");

$| = 1;

if ($opt_h || !$opt_ict || !$opt_out || !$opt_v) {
  die "Usage1: perl <Script_name> \nRequired arguments:  -ict <Ict_filename> -v <version> -out <New_techfile>\nOptional arguments:       -profile <Profiles directory> (default: profiles)\n -old_tech <Fire/Icecaps techfilename>\n -model <Models directory> (default: models)\nUsage2: perl <Script_name> -h \n"
} 
use Cwd;
$cur_dir = cwd;
$pos = rindex($0, "/");
if ($pos == -1) {
  $script_dir = $cur_dir;
}
else {
  $script_dir = substr($0, 0, $pos);
}

require "$script_dir"."/miscutils.pm";
$ict_file = GetFullPath($opt_ict);
if (!$opt_old_tech) {
  $icecaps_techfile = "";
}
else {
  $icecaps_techfile = GetFullPath($opt_old_tech);
}
$techfile = GetFullPath($opt_out);
if (!$opt_profile) {
  $profiles_dir = $cur_dir . "/profiles";
}
else {
  $profiles_dir = GetFullPath($opt_profile);
}
(-d $profiles_dir) || die "Profile data directory does not exist\n";

if (!$opt_model) {
  $models_dir =  $cur_dir . "/models";
}
else {
  $models_dir = GetFullPath($opt_model);
}
(-d $models_dir) || die "Model data directory does not exist\n";

if ($opt_sensitivity) { 
  $sens_file = "RCgenSenseFile";
  $sens_dir  = "$cur_dir"."/sensitivity_models/";
  $sens_models_dir   =  $sens_dir."/models";
  $sens_profiles_dir =  $sens_dir."/profiles";
}

#$hdr_file = $ict_file . "_hdr";
#(-e $hdr_file) || die "Header file non-existent\n";
my $ext_sens_ext = "sens";
my $int_sens_ext = "sen";

$beg = rindex($ict_file, "/");
$end = rindex($ict_file, ".");
if ($end < $beg) {
  $nxtechfile = substr($ict_file, $beg + 1);
}
else {
  $nxtechfile = substr($ict_file, $beg + 1, $end - $beg - 1);
}
$timestamp = `date +%m%d%y`;
chomp($timestamp);
$nxtechfile .= "__". $timestamp;
$nxtechfile .= ".tech";

if (-e $icecaps_techfile) {
  ;
}
else {
  if ($opt_test) {
    warn "Icecaps techfile non-existent; Icecaps models will be excluded\n";
    build_techfile_header($techfile, $timestamp);
  }
}

#
#   NX techfile name
#
#  Put the area models away if they exist
#

chdir($models_dir);
@files = glob("3_*.mdl");
if ($#files >= 0) {
  mkdir("___tmp", 0744);
  `cat 3_*.mdl > area.tech`;
  foreach $area_model (@files) {
    `mv $area_model ___tmp`;
  }
} else {
  @files = glob("___tmp/3_*.mdl");
  if ($#files >= 0) {
    `cat ___tmp/3_*.mdl > area.tech`;
  }
}
chdir($cur_dir);

#
#  Generate zero-ended source models
#
chdir($models_dir);
$valid_models = 0;
for ($i = 0; $i <= 6; ++$i) {
  if ($i == 3) {
    next;
  }
  @files = glob("$i_*.net_ascii");
  if ($#files == -1) {
    warn "Models of type $i not generated\n";
    $valid_models = 1;
  }
}
chdir($cur_dir);
if ($valid_models == 1) {
  die "Correct warnings above and re-invoke -concat options\n";
}
(-e "zero_ended_models_wp.pl") || die "Zero_ended_models_wp.pl non-existent\n";
printf "Generating models of type 0\n";
`perl ./zero_ended_models_wp.pl lamid.tech $models_dir $profiles_dir $opt_v`;

#
#  Generate one-ended source models
#
(-e "one_ended_models_wp.pl") || die "One_ended_models_wp.pl non-existent\n";
printf "Generating models of type 1\n";
`perl ./one_ended_models_wp.pl laedge.tech $models_dir $profiles_dir $opt_v`;

#
#  Generate two-ended source models
#
(-e "two_ended_models_wp.pl") || die "Two_ended_models_wp.pl non-existent\n";
printf "Generating models of type 2\n";
`perl ./two_ended_models_wp.pl sa.tech $models_dir $profiles_dir $opt_v`;

if (-e "two_ended_4lat_models_wp.pl") {
  printf "Generating models of type 4\n";
  `perl ./two_ended_4lat_models_wp.pl sa_4lat.tech $models_dir $profiles_dir $opt_v`;
}

# Get corner models
if (-e "corner_models_wp.pl") {
  printf "Generating models of type 5\n";
  `perl ./corner_models_wp.pl corner.tech $models_dir $profiles_dir $opt_v`;
}
else {
  warn "Corner_models_wp.pl non-existent\n";
}

# Get crossover models
# anton: used if RCGEN_SKIP_OLD_XOVER env var is not defined only
# YU: nov 2014: old xover should be done only for non-65 nm tech, or if required explicitly
#if (not defined $ENV{'RCGEN_SKIP_OLD_XOVER'}) { 
if (((not defined $ENV{'RCGEN_MODEL6'}) && (not defined $ENV{'_65NM_TECHNOLOGY_FLAG'})) || 
  ((defined $ENV{'RCGEN_MODEL6'}) && ($ENV{'RCGEN_MODEL6'} eq "on"))) {
if (-e "xover_models_wp.pl") {
  printf "Generating models of type 6\n";
  `perl ./xover_models_wp.pl xover.tech $models_dir $profiles_dir $opt_v`;
}
else {
  warn "Xover_models_wp.pl non-existent\n";
}
}

# Get crossover models
if (-e "ziglat_models_wp.pl") {
  printf "Generating models of type 7\n";
  `perl ./ziglat_models_wp.pl ziglat.tech $models_dir $profiles_dir $opt_v`;
}

# Get fill models
if (-e "fill2D_models_wp.pl") {
  printf "Generating models of type 8\n";
  `perl ./fill2D_models_wp.pl fill2D.tech $models_dir $profiles_dir $opt_v`;
}

if (-e "fill3D_models_wp.pl") {
  printf "Generating models of type 9\n";
  `perl ./fill3D_models_wp.pl fill3D.tech $models_dir $profiles_dir $opt_v`;
}

#
#  Catenate all models together and convert into techfile format
#

printf "Catenating models into techfile\n";
$cat_string = "cat Mbb_data lamid.tech laedge.tech sa.tech area.tech ";
chdir($models_dir);
if (-s "sa_4lat.tech") {
  $cat_string .= "sa_4lat.tech ";
}
if (-s "corner.tech") {
  $cat_string .= "corner.tech ";
}
else {
  warn "Type 5 models missing\n";
}

#anton: use if RCGEN_SKIP_OLD_XOVER undefined
# YU: nov 2014: old xover should be done only for non-65 nm tech, or if required explicitly
#if (not defined $ENV{'RCGEN_SKIP_OLD_XOVER'}) { 
if (((not defined $ENV{'RCGEN_MODEL6'}) && (not defined $ENV{'_65NM_TECHNOLOGY_FLAG'})) ||
  ((defined $ENV{'RCGEN_MODEL6'}) && ($ENV{'RCGEN_MODEL6'} eq 'on'))) {
if (-s "xover.tech") {
  $cat_string .= "xover.tech ";
}
else {
  warn "Type 6 models missing\n";
}
}

if (-s "ziglat.tech") {
  $cat_string .= "ziglat.tech ";
}

if (-s "fill2D.tech") {
  $cat_string .= "fill2D.tech ";
}
else {
  if (-e "fill2D_models_wp.pl") {
    warn "Type 8 models missing \n";
  }
}

if (-s "fill3D.tech") {
  $cat_string .= "fill3D.tech ";
}
else {
  if (-e "fill3D_models_wp.pl") {
    warn "Type 9 models missing \n";
  }
}

`$cat_string > tmp.tech`;
`perl $script_dir/convert_techfile_format.pl tmp.tech $nxtechfile`;
unlink("tmp.tech");

#
#  Catenate Icecaps techfile, Process description, Nx models together
#
if (-e $icecaps_techfile) {
#  `cat $icecaps_techfile $hdr_file $nxtechfile > $techfile`;
  `cat $icecaps_techfile $nxtechfile > $techfile`;
}
else {
  if ($opt_test) {
    `cat $nxtechfile >> $techfile`;
  } else {
    `cat $nxtechfile > $techfile`;   
  } 
}


#printf "Compressing intermediate model files\n";
`rm -rRf *.tech`;
chdir($cur_dir);
`perl $script_dir/calc_time.pl -p $profiles_dir -m $models_dir  -o Time > __tmp`;
open(tmpfile, "__tmp");
while (<tmpfile>) {
  @Fld = split(' ', $_, 1000);
  if ($Fld[0] eq "Total" && $Fld[3] eq "models") {
    printf "CPU Time to generate technology file = %.2f hours\n", $Fld[5];
    last;
  }
}
close(tmpfile);
unlink("__tmp");

#
# Catenate sensisitvity tech file
#

#
#  Catenate all models together and convert into techfile format
#
if ($opt_sensitivity) { 
  (-d $sens_models_dir) || die "Sensitivity Model data directory does not exist\n";

  printf "Catenating models into sensitivity techfile\n";


  #  Put the area models away if they exist
  chdir($sens_models_dir);
  @files = glob("*_3_*.mdl");
  if ($#files >= 0) {
    `cat @files > area.tech.$int_sens_ext`;
    mkdir("___tmp", 0744);
    foreach $area_model (@files) {
      `mv $area_model ___tmp`;
    }
  } else {
    @files = glob("___tmp/*_3_*.mdl");
    if ($#files > 0) {
     `cat @files > area.tech.$int_sens_ext`;
    }

  }
  chdir($cur_dir);

  my $cat_string = "cat .InputSensFile $sens_file lamid.tech.$int_sens_ext laedge.tech.$int_sens_ext sa.tech.$int_sens_ext area.tech.$int_sens_ext ";

  chdir($sens_models_dir);
  if (-s "sa_4lat.tech.sen") {
    $cat_string .= "sa_4lat.tech.$int_sens_ext ";
  }
  if (-s "corner.tech.sen") {
    $cat_string .= "corner.tech.$int_sens_ext ";
  }
  else {
    warn "Type 5 sensitivity models missing\n";
  }

  if (-s "xover.tech.sen") {
    $cat_string .= "xover.tech.$int_sens_ext ";
  }
  else {
    warn "Type 6 sensitivity models missing\n";
  }

  if (-s "ziglat.tech.sen") {
    $cat_string .= "ziglat.tech.$int_sens_ext ";
  }

  if (-s "fill2D.tech.sen") {
    $cat_string .= "fill2D.tech.$int_sens_ext ";
  }
  else {
    if (-e "fill2D_models_wp.pl") {
      warn "Type 8 sensitivity models missing \n";
    }
  }

  if (-s "fill3D.tech.sen") {
    $cat_string .= "fill3D.tech.$int_sens_ext ";
  }
  else {
    if (-e "fill3D_models_wp.pl") {
      warn "Type 9 sensitivity models missing \n";
    }
  }


  require "$script_dir"."/get_permutations.pl";
  remove_empty_lines_from_file(".InputSensFile", ".InputSensFile_tmp");
  `mv .InputSensFile_tmp .InputSensFile`;
  `echo >> $sens_file`; #add \n  to the end of the file

  `$cat_string > tmp.tech.$ext_sens_ext`;
  $sens_nxtechfile = $nxtechfile.".".$ext_sens_ext;
  `perl $script_dir/convert_techfile_format.pl tmp.tech.$ext_sens_ext $sens_nxtechfile`;
  unlink("tmp.tech.$ext_sens_ext");

  `cat $sens_nxtechfile > $techfile.$ext_sens_ext`;   
  unlink($sens_nxtechfile);  #remove temporary file
  
#  printf "Time for generate sensitivity techfile\n";
  `rm -rRf *.tech.$int_sens_ext`;
  chdir($cur_dir);
  `perl $script_dir/calc_time.pl -p $sens_profiles_dir -m $sens_models_dir -o SensTime > __tmp`;
  open(tmpfile, "__tmp");
  while (<tmpfile>) {
    @Fld = split(' ', $_, 1000);
    if ($Fld[0] eq "Total" && $Fld[3] eq "models") {
    printf "CPU Time to generate sensitivity technology file = %.2f hours\n", $Fld[5];
    last;
   }
  }
  close(tmpfile);
  unlink("__tmp");
}

################################################################################
sub build_techfile_header() {

  my($nxtechfile, $time) = @_;

  open(out, ">$nxtechfile");
  printf out "SIMPLEX_TECHFILE_FORMAT 3000 RC BASE 320213 3.2.0 320213 3.2.0";
  printf out "%s\n", $time;
  printf out "ICT_STARTS\n";
  open(in, $ict_file);
  while (<in>) {
    printf out "ICT %s", $_;
  }
  close(in);
  printf out "ICT_ENDS\n\n";
  close(out);
}
