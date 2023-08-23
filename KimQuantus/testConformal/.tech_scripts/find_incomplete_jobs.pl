######################################################################
#
#  CdnLglNtc    [ Copyright (c) 2002-2006
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
GetOptions("q:s", "partial:i", "mbb:s", "ext=s", "h","mode=s");

($models, $profiles, $output_file) = @ARGV;


if ($opt_h || $#ARGV < 2) 
{
  die "Usage1: perl <Script_name> \nRequired arguments: -ext (two, one, zero, corner, crossover, fill2D,  all) <models_dir> <profiles_dir> <output_file>\nOptional arguments:\n -q (1 for Linux queue)\n -partial (1 for YES) \n -mbb <path of Mbb_file_name> (default:Mbb_data)\n -mode (corners, variation) \nUsage2: perl <Script_name> -h";
}

$mbb_file = "Mbb_data";
if ($opt_mbb) 
{
  $mbb_file = $opt_mbb;
}

(-e $mbb_file) || die "Minimum bounding box file not found\n";

use Cwd;
$cur_dir = cwd;
$pos = rindex($0, "/");
if ($pos == -1) 
{
  $script_dir = $cur_dir;
}
else 
{
  $script_dir = substr($0, 0, $pos);
}

require "$script_dir"."/get_layers.pl";

if ($opt_corners) 
{
  require $script_dir."/get_permutations.pl";
}

($layer_cnt, $layer_addr, $mbb_addr, $vhcnt_addr, $vh_addr) = get_layer_info($mbb_file);
$none_layer = $layer_cnt - 2;
$gnd_layer = $layer_cnt - 1;
@layer_stack = @$layer_addr;

if (!$opt_ext) 
{
  die "Model type needed for checking existence of models; Please enter extension type\n";
}
else {
  if ($opt_ext ne "corner" && $opt_ext ne "crossover" && $opt_ext ne "fill2D" && $opt_ext ne "all") 
  {
    $opt_ext .= "_ended";
  }
}


my($func) ;

if($opt_mode eq "corners")
{
	$func = sub { get_unfinished_jobs_fast_corners(@_) };
}
elsif($opt_mode eq "variation")
{
	$func = sub { get_unfinished_jobs_variation(@_) };
}
elsif(!$opt_mode)
{
	$func = sub { get_unfinished_jobs(@_) };
}

if ($opt_ext eq "all") 
{
   $func->("all_jobs", 0);
}
else 
{
  if ($opt_ext eq "crossover") 
  {
    $func->("xover1", 0);
    $func->("xover3", 1);
  }
  else 
  {
    $func->($opt_ext, 0);
  }
}


#####################################################################################################
sub check_rpt_file {
  use strict;
  
  my($profile) = @_;
  my($rpt_file) = $profile.".rpt";

  if(-e $rpt_file && -s $rpt_file) {
    my($summary_exists) = 0;
    my($fflag) = 0;
    open(rpt, $rpt_file);
    while(<rpt>) {
      if(/------   ------   ------   ------   ------   ------   ------   ------/) {
        $fflag = 1;
      }
      if(/Samples/ && $fflag == 1) {
        my(@Fld) = split(' ', $_, 1000);
        if ($Fld[2] == 0 && $Fld[1] == 0.) {
          $summary_exists = -1;
        }
        $fflag = 0;
        last;
      }
    }
    close(rpt);
    if($summary_exists == -1) {
	   printf "Job %s may not have finished model generation\n", $profile;
      return -1;
    }

    my($rejection_rate_count) = 0;
    my($time_count) = 0;
    my($pe_count) = 0;
    my($fflag) = 0;
    open(rpt, $rpt_file);
    while (<rpt>) {
      if (/Rejection rate/) {
        $fflag = 1;
      }
      if (/Time/) {
        $fflag = 2;
      }
      if (/PE/) {
        $fflag = 3;
      }
      if (/\s*\d*.\d*e[+-]?\d./) {
        if($fflag == 1) {
          $rejection_rate_count = $rejection_rate_count + 1;
        }
        if($fflag == 2) {
          $time_count = $time_count + 1;
        }
        if($fflag == 3) {
          $pe_count = $pe_count + 1;
        }
      }
    }
    close(rpt);
    if($rejection_rate_count == 0 || $time_count == 0 || $pe_count == 0) {
#      printf "%s RR = %d, Time = %d, PE = %d\n", $rpt_file, $rejection_rate_count, $time_count, $pe_count;
      printf "Job %s may not have finished model generation\n", $profile;
        return -1;
    }
  }
  
  return 0;
}


#####################################################################################################
sub get_unfinished_jobs() {

  my($opt_ext, $fileopen_flag) = @_;
  my($i);
# 
#  All of the variables below this line should have local scope but I'm letting it be since
#  the calling routine is meant to be a wrapper. The calling routine should have no other
#  functionality, all the functionality needs to be here
#
    $linux_q = 0;
    if ($opt_ext eq "all_jobs") {
      printf("ALL_JOBS\n");
      $jobs_file = $opt_ext.".pl";
    } else {
      $jobs_file = $opt_ext."_models_base.pl";
    }
  
#    (-e $jobs_file) || warn "$jobs_file not found in path\n";
    
    open(jf, $jobs_file);
    $num_jobs = 0;
    while (<jf>) {
      @Fld = split(' ', $_, 9999);
      
      if (index($Fld[0], "#") != -1) {
	next;
      }

#      ($reference_number) = find_layername_match(\@Fld);
      ($reference_number) = find_pattern_name_match(\@Fld);

      if ($reference_number == -1) {
	next;
      }

#      ($endl) = find_string_match(\@Fld, "\"cd", -1);
      ($endl) = find_string_match(\@Fld, "echo", -2);
#     Offset 4 is not always valid. In some cases it leads to error in job size definition.
      ($job_size) = find_string_match(\@Fld, "generate", 4);
      ($mg_job_beg) = find_string_match(\@Fld, "generate_model_adaptive", 0);
      
      if (index($Fld[$reference_number], ";") != -1) {
	$profile[$num_jobs] = substr($Fld[$reference_number], 0, index($Fld[$reference_number], ";"));
      }
      else {
        $profile[$num_jobs] = $Fld[$reference_number];
      }
      if ($endl == 0) {
	$mg_job_string[$num_jobs] = join(" ", "perl", @Fld[$mg_job_beg...$#Fld]);
      }
      else {
	$mg_job_string[$num_jobs] = join(" ", @Fld[0...$endl], "\"perl", @Fld[$mg_job_beg...$#Fld]);
      }
      $lines[$num_jobs] = $Fld[$job_size];
      $job_string[$num_jobs++] = $_;
    }
    close(jf);
  printf("Total number of jobs = %d\n", $num_jobs);
  
  use Cwd;
  $cur_dir = cwd;
  $num_incomplete_jobs = 0;
  $num_exception_jobs = 0;
  
  $pos = rindex($0, "/");
  if ($pos == -1) {
    $script_dir = ".";
  }
  else {
    $script_dir = substr($0, 0, $pos);
  }
  require "$script_dir"."/miscutils.pm";
  $models_dir = GetFullPath($models);
  $profiles_dir = GetFullPath($profiles);
  
  chdir($models_dir);
  $#incomplete_jobs = $num_jobs;
  $#incomplete_jobs_type = $num_jobs;
  for ($i = 0; $i < $num_jobs; ++$i) {
    
    $zipped_flag = -1;
    $incomplete_job_found_flag = -1;
    
		
    $rpt_file = $profile[$i].".rpt";
    $net_file = $profile[$i].".net_ascii";
    $tmp_file = $profile[$i].".tmp";
    $data_file = $profiles_dir . "/".$profile[$i]."/".$profile[$i].".dat";
    $time_file = $profiles_dir . "/".$profile[$i]."/".$profile[$i].".dat.time";
    $datagz_file = $profiles_dir . "/".$profile[$i]."/".$profile[$i].".dat.gz";
    $log_file = $profiles_dir . "/".$profile[$i]."/".$profile[$i].".log";
    if (-e $data_file) {
      $zipped_flag = 0;
    }
    elsif (-e $datagz_file) {
      `gunzip -f $datagz_file`;
      $zipped_flag = 0;
    }
	
    if (-z $log_file) {
      #
      # Checks size of log file; if zero, it may indicate that the field solver run
      # terminated prematurely
      #
      printf "Job %s not completed\n", $profile[$i];
      printf "Data file incomplete\n";
      $incomplete_jobs_type[$num_incomplete_jobs] = -2;
      $incomplete_jobs[$num_incomplete_jobs++] = $i;
      $incomplete_job_found_flag = 0;
    }
    elsif (-s $log_file) {
      open(logfile, $log_file);
      while (<logfile>) {
        if (/Cpp_Exception/ || /cytflexceptionhandler/) {
	  $exception_jobs[$num_exception_jobs++] = $i;
          last;
	}
      }
      close(logfile);
    }
    if (-e $tmp_file && 
        $incomplete_job_found_flag == -1) {
      #
      # Checks for existence of temporary files; if they exist, it may indicate that
      # the job terminated prematurely
      #
      printf "Job %s not completed\n", $profile[$i];
      if (-s $data_file) {
	($size) = count_lines($data_file);
      }
      if ($size >= $lines[$i]) {
#       Eliminating the error in job size definition - let the job string be always complete
#	$incomplete_jobs_type[$num_incomplete_jobs] = -1;
	$incomplete_jobs_type[$num_incomplete_jobs] = -2;
      }
      else {
	printf "Data file is incomplete: Required lines : %d Actual lines : %d\n", $lines[$i], $size;
	$incomplete_jobs_type[$num_incomplete_jobs] = -2;
      }
      $incomplete_jobs[$num_incomplete_jobs++] = $i;
      $incomplete_job_found_flag = 0;
    }
    if (-e $rpt_file && -s $rpt_file && -s $net_file && -s $data_file &&
      $incomplete_job_found_flag == -1) {
      #
      # Checks for existence of the proper files; if everything is ok, this means that
      # the job was fine
      #
      use File::stat;
      use Time::localtime;
      $date1 = stat($net_file)->mtime;
      if(-e $time_file) { $date2 = stat($time_file)->mtime; }
      else              { $date2 = stat($data_file)->mtime; }
      if ($date1 < $date2) {
	printf "Job %s times skewed\n", $profile[$i];
	($size) = count_lines($data_file);
        if ($size >= $lines[$i]) {
	  $incomplete_jobs_type[$num_incomplete_jobs] = -1;
	}
        else {
	  printf "Data file is incomplete: Required lines : %d Actual lines : %d\n", $lines[$i], $size;
	  $incomplete_jobs_type[$num_incomplete_jobs] = -2;
	}
	$incomplete_jobs[$num_incomplete_jobs++] = $i;
	$incomplete_job_found_flag = 0;
	next;
      }
      $nan_exists = 0;
      open(netascii, $net_file);
      while (<netascii>) {
        $line = lc($_);
        if (index($line, "nan") != -1 ||
            index($line, "inf") != -1) {
          $nan_exists = 1;
          last;
        }
      }
      close(netascii);
      if ($nan_exists == 1) {
        printf "Job %s had NaN or Inf numbers in data\n", $profile[$i];
        $incomplete_jobs_type[$num_incomplete_jobs] = -2;
        $incomplete_jobs[$num_incomplete_jobs++] = $i;
        $incomplete_job_found_flag = 0;
        next;
      }

      my($res) = check_rpt_file($profile[$i]);
      if ($res < 0) {
        $incomplete_jobs_type[$num_incomplete_jobs] = $res;
        $incomplete_jobs[$num_incomplete_jobs++] = $i;  
        $incomplete_job_found_flag = 0;
      }
    }
    else {
      if ($incomplete_job_found_flag == -1) {
        printf "Job %s not completed\n", $profile[$i];
        $size = 0;
        if (-s $data_file) {
	  ($size) = count_lines($data_file);
        }
        if ($size >= $lines[$i]) {
#         Eliminating the error in job size definition - let the job string be always complete
#	  $incomplete_jobs_type[$num_incomplete_jobs] = -1;
	  $incomplete_jobs_type[$num_incomplete_jobs] = -2;
        }
        else {
	  printf "Data file is incomplete: Required lines : %d Actual lines : %d\n", $lines[$i], $size;
	  $incomplete_jobs_type[$num_incomplete_jobs] = -2;
        }
        $incomplete_jobs[$num_incomplete_jobs++] = $i;
      }
    }
    
    if ($zipped_flag == 0) {
      if (-e $data_file) {
	;
      }
      else {
	`gzip -f -9 $data_file`;
      }
    }
  }
  
  chdir($cur_dir);
  printf "Number of incomplete jobs for %s profiles = %d\n", $opt_ext, $num_incomplete_jobs;
  printf "Number of crashed jobs for %s profiles = %d\n", $opt_ext, $num_exception_jobs;
  if ($num_incomplete_jobs == 0 && $num_exception_jobs == 0) {
    ;
  }
  else {
    if ($fileopen_flag == 0) {
      open(outf, ">$output_file");
    }
    else {
      open(outf, ">>$output_file");
    }
    for ($i = 0; $i < $num_incomplete_jobs; ++$i) {
      if ($incomplete_jobs_type[$i] == -1) {
        printf outf "%s\n\n", $mg_job_string[$incomplete_jobs[$i]];
      }
      elsif ($incomplete_jobs_type[$i] == -2) {
        printf outf "%s\n", $job_string[$incomplete_jobs[$i]];
      }
    }
    if ($num_exception_jobs > 0) {
      printf outf "# Crashed jobs list\n#\n";
      for ($i = 0; $i < $num_exception_jobs; ++$i) {
        printf outf "#%s\n", $job_string[$exception_jobs[$i]];
      }
    }
    close(outf);
    `chmod 0755 $output_file`;
  }
}  


#############################################################################
#
# A word is pattern name if it constains 5 entries of NUMBER_METAL_LAYER 
# None and CSUBSTRATE are also considered as layer names
#
#############################################################################
sub find_pattern_name_match {

  my($addr) = @_;
  my($i, $j, $str, @Fldsub);

  my @popats = map{ qr/[\dFDP]_($_)_/ } @layer_stack;
  my @popats2 = map{ qr/[\dFDP]_$_\b/ } @layer_stack;
  
  @Fldsub = @$addr;
  for ($i = 0; $i <= $#Fldsub; ++$i) {  
    my $count = 0;
    for my $pat (@popats) {
      while ($Fldsub[$i] =~ /$pat/g) {
        $count++;
      }
	 if ($count >= 5) {  
        return($i + $offset);
      }
  }
	  for my $pat (@popats2) {
      while ($Fldsub[$i] =~ /$pat/g) {
        $count++;
      }
      
	  if ($count >= 5) {  
        return($i + $offset);
      }
    }
  }  
  
  return(-1);
}

#============================================================================
sub check_profile
{
  my($cdir, $profile_name, $job_num) = @_;	
#  chdir($cur_dir);
	use Cwd;
  $cur_dir = cwd;
   
  require "$script_dir"."/miscutils.pm";
  my $models_dir   = GetFullPath($cur_dir."/".$cdir."/models/");
  my $profiles_dir = GetFullPath($cur_dir."/".$cdir."/profiles/");

  ##chdir($models_dir);
  ##use Cwd;     
  $rpt_file = $models_dir."/".$profile_name.".rpt";
  $net_file = $models_dir."/".$profile_name.".net_ascii";
  $tmp_file = $models_dir."/".$profile_name.".tmp";	
	
  $data_file = $profiles_dir . "/".$profile_name."/".$profile_name.".dat";    
  $time_file = $profiles_dir . "/".$profile_name."/".$profile_name.".dat.time";    
  $datagz_file = $profiles_dir . "/".$profile_name."/".$profile_name.".dat.gz";
  $log_file = $profiles_dir . "/".$profile_name."/".$profile_name.".log";

  #print "Data file : $data_file \n";	
	
  if (-e $data_file) 
  {
		$zipped_flag = 0;
  }
  elsif (-e $datagz_file) 
  {	  
		`gunzip -f $datagz_file`;
		$zipped_flag = 0;
  }
  else
  {
  	print "Missing data file $profile_name.dat or $profile_name.dat.gz\n";
		return -1; # file not found
  }
	
  $inc_jobs_type = -2;
   
  if(-z $log_file) 
  {
    #
    # Checks size of log file; if zero, it may indicate that the field solver run
    # terminated prematurely
    #
		printf "Job %s not completed\n", $profile_name;
		printf "Data file incomplete\n";
		return -1;
  }  
  elsif (-s $log_file) 
  {
		open(logfile, $log_file);
		while (<logfile>) 
	{
	  if (/Cpp_Exception/ || /cytflexceptionhandler/) 
	  {
		#print "\nEXCEPTION!\n line 341";  
		return -2; # job throw exception
	  }
	}
	close(logfile);
  }
  
  my $size = 0;
  if (-e $tmp_file ) 
  {
	  #
	  # Checks for existence of temporary files; if they exist, it may indicate that
	  # the job terminated prematurely
	  #
	  printf( "Job %s not completed\n", $profile_name);

	  if (-s $data_file) 
	  {
	    ($size) = count_lines($data_file);
	  }
	  if ($size >= $job_num) 
	  {
	    $inc_jobs_type  = -1;
	  }
	  else 
	  {
	    printf "Data file is incomplete: Required lines : %d Actual lines : %d\n", $lines[$i], $size;
	    $inc_jobs_type = -2;
	  }
	  return -1; # bad finished
  }
  
  
  if (-e $rpt_file && -s $rpt_file && -s $net_file && -s $data_file ) 
  {
	#
	# Checks for existence of the proper files; if everything is ok, this means that
	# the job was fine
	#
	  use File::stat;
	  use Time::localtime;
    $date1 = stat($net_file)->mtime;
    if(-e $time_file) { $date2 = stat($time_file)->mtime; }
    else              { $date2 = stat($data_file)->mtime; }
    
    if ($date1 < $date2) 
	  {
	    printf "Job %s times skewed\n", $profile_name;
	    ($size) = count_lines($data_file);
	    if ($size >= $job_num) 
	    {
	      $inc_jobs_type = -1;
	    }
	    else 
	    {
	      printf "Data file is incomplete: Required lines : %d Actual lines : %d\n", $lines[$i], $size;
	      $inc_jobs_type = -2;
	    }
	    return -1;

	  }
  
	  $nan_exists = 0;
	   open(netascii, $net_file);
	   while (<netascii>) 
	   {
	    $line = lc($_);
	    if (index($line, "nan") != -1 || index($line, "inf") != -1) 
	    {
	      $nan_exists = 1;
	      last;
	    }
	   }
	   close(netascii);
      if ($nan_exists == 1) 
      {
        printf "Job %s had NaN or Inf numbers in data\n", $profile[$i];
        $inc_jobs_type = -2;
        return -3; #nan exist 
      }

      my($res) = check_rpt_file($profile[$i]);
      if ($res == -2) {
        $inc_jobs_type = -2;
        return -3; #nan exist 
      }
      if($res == -1) {
		  $inc_jobs_type = -1;
		  $incomplete_job_found_flag = 0;
      }
  }
  else 
  {
    printf "Job %s not completed\n", $profile_name;
		$size = 0;
		if (-s $data_file) 
		{
	  	($size) = count_lines($data_file);
		}
		if ($size >= $job_num) 
		{
	  	; #return -1;
		}
		else 
		{
	  	printf "Data file is incomplete: Required lines : %d Actual lines : %d\n", $lines[$i], $size;
	  	return -1;
		}
  }

  if ($zipped_flag == 0) 
  {
		if (-e $data_file) 
		{
	  	;
		}
		else {
	  	`gzip -f -9 $data_file`;
		}
  }
  
  return 0; #OK
}

#####################################################################################################
sub get_unfinished_jobs_variation() {

  my($opt_ext, $fileopen_flag, $corner_file_opt) = @_;
  my($i);

if ($corner_file_opt) {
  require $script_dir."/get_permutations.pl";
}
  
# 
#  All of the variables below this line should have local scope but I'm letting it be since
#  the calling routine is meant to be a wrapper. The calling routine should have no other
#  functionality, all the functionality needs to be here
#
    $linux_q = 0;
    if ($opt_ext eq "all_jobs") {
      printf("ALL_JOBS\n");
      $jobs_file = $opt_ext.".pl";
    } else {
      $jobs_file = $opt_ext."_models_base.pl";
    }
  
#    (-e $jobs_file) || warn "$jobs_file not found in path\n";
    
  open(jf, $jobs_file);
  $num_jobs = 0; $num = 0;
	$num_incomplete_jobs = 0;
	$num_exception_jobs = 0;
  
  if ($fileopen_flag == 0) 
  {
    open(outf, ">$output_file");
  }
  else 
  {
    open(outf, ">>$output_file");
  }

  my(@crased_jobs);
  while (<jf>) 
	{
	 
		$comm = $_;   
	  @Fld = split(/[' ',;]/, $_, 9999);
	  if(($#Fld == 0) || (index($Fld[0], "#") != -1))
	  {
			next;
	  } 
	  	  
    ($pr, $num) = get_profile_name(\@Fld);
	  @pref = get_permutation_prefixes(\@Fld); 
        
	  $num_jobs++;
	  $is_good = 0;
    $res = check_profile("",$pr, $num);
	  if($res < 0)
    {
			$is_good = 1;
      if($res == -3)
      {
        $crashed_jobs[$num_exception_jobs++]=$comm; 
      }
	  }
	  else
	  {
		  for($k=0; $k <= $#pref; $k++)
		  {
				#$res = check_profile("sensitivity_models",$pref[$k]."_".$pr, $num) ;    
		    if((is_variation_sufficient($pref[$k], $pr) != 0) && (($res = check_profile("sensitivity_models",$pref[$k]."_".$pr, $num)) < 0))
	  	  {
					$is_good = 1;
          if($res == -3)
          {
            $crashed_jobs[$num_exception_jobs++]=$comm; 
          }
					last;
	  	  }
		  }
		}
    if($is_good == 1)
    {
   	  printf outf "%s\n", $comm;
      $num_incomplete_jobs++;
    }
  }
  close(jf);
  chdir($cur_dir);  
  
  if ($num_exception_jobs > 0) 
  {
    printf outf "# Crashed jobs list\n#\n";
    for ($i = 0; $i < $num_exception_jobs; $i++) 
    {
      printf outf "#%s\n", $crashed_jobs[$i];
    }
  }
  close(outf);
  `chmod 0755 $output_file`;
  
  printf("Total number of jobs = %d\n", $num_jobs);
  printf "Number of incomplete jobs for %s profiles = %d\n", $opt_ext, $num_incomplete_jobs;
 
}  

#####################################################################################################

sub get_unfinished_jobs_fast_corners() {

  my($opt_ext, $fileopen_flag, $corner_file_opt) = @_;
  my($i);

if ($corner_file_opt) {
  require $script_dir."/get_permutations.pl";
}
  
# 
#  All of the variables below this line should have local scope but I'm letting it be since
#  the calling routine is meant to be a wrapper. The calling routine should have no other
#  functionality, all the functionality needs to be here
#
    $linux_q = 0;
    if ($opt_ext eq "all_jobs") {
      printf("ALL_JOBS\n");
      $jobs_file = $opt_ext.".pl";
    } else {
      $jobs_file = $opt_ext."_models_base.pl";
    }
  
#    (-e $jobs_file) || warn "$jobs_file not found in path\n";
    
    open(jf, $jobs_file);
    $num_jobs = 0;
    while (<jf>) {
      @Fld = split(' ', $_, 9999);
      
      if (index($Fld[0], "#") != -1) {
        next;
      }

      ($reference_number) = find_layername_match(\@Fld);

      if ($reference_number == -1) {
        next;
      }

#      ($endl) = find_string_match(\@Fld, "\"cd", -1); 
      ($endl) = find_string_match(\@Fld, "echo", -2);

      $corner_job[$num_jobs]  = find_string_match(\@Fld, "generate_corner_model.pl",0);
      my ($corner_file);

      if ($corner_job[$num_jobs]) {
        $corner_file[$num_jobs] = $Fld[$corner_job[$num_jobs]+1];
        $profile[$num_jobs]     = $Fld[$corner_job[$num_jobs]+5];
        $lines[$num_jobs]       = 0;
      }
      else {
        ($job_size)   = find_string_match(\@Fld, "generate", 4);
        ($mg_job_beg) = find_string_match(\@Fld, "generate_model_adaptive", 0);
      
        if (index($Fld[$reference_number], ";") != -1) {
          $profile[$num_jobs] = substr($Fld[$reference_number], 0, index($Fld[$reference_number], ";"));
        }
        else {
          $profile[$num_jobs] = $Fld[$reference_number];
        }
        if ($endl == 0) {
          $mg_job_string[$num_jobs] = join(" ", "perl", @Fld[$mg_job_beg...$#Fld]);
        }
        else {
          $mg_job_string[$num_jobs] = join(" ", @Fld[0...$endl], "\"perl", @Fld[$mg_job_beg...$#Fld]);
        }
        $lines[$num_jobs] = $Fld[$job_size];
      }
      $mg_job_string[$num_jobs] = $_;
      $job_string[$num_jobs++] = $_;
    }
  close(jf);
  printf("Total number of jobs = %d\n", $num_jobs);
  
  use Cwd;
  $cur_dir = cwd;
  $num_incomplete_jobs = 0;
  $num_exception_jobs = 0;
  
  $pos = rindex($0, "/");
  if ($pos == -1) {
    $script_dir = ".";
  }
  else {
    $script_dir = substr($0, 0, $pos);
  }
  require "$script_dir"."/miscutils.pm";
  
  $#incomplete_jobs = $num_jobs;
  $#incomplete_jobs_type = $num_jobs;
  for ($i = 0; $i < $num_jobs; ++$i) {

    $zipped_flag = -1;
    $incomplete_job_found_flag = -1;
    
    $rpt_file = $profile[$i].".rpt";
    $net_file = $profile[$i].".net_ascii";
    $tmp_file = $profile[$i].".tmp";

    
    my @corner_dirs;
    if ($corner_file[$i]) {
      my $num_corners = get_number_of_corners($corner_file[$i]);
      for (my $ncorner = 0; $ncorner < $num_corners; $ncorner++) {
        my $corname = get_corner_name($corner_file[$i], $ncorner);       
        push(@corner_dirs,$corname);
      }
    }
    else {
       push(@corner_dirs,".");
    }
        
    for (my $num_corner = 0; $num_corner < @corner_dirs; $num_corner++) {
      chdir($cur_dir);

      my $models_dir   = GetFullPath($corner_dirs[$num_corner]."/".$models);
      my $profiles_dir = GetFullPath($corner_dirs[$num_corner]."/".$profiles);
      chdir($models_dir);

      use Cwd;     
      
      $data_file = $profiles_dir . "/".$profile[$i]."/".$profile[$i].".dat";    
      $time_file = $profiles_dir . "/".$profile[$i]."/".$profile[$i].".dat.time";    
      $datagz_file = $profiles_dir . "/".$profile[$i]."/".$profile[$i].".dat.gz";
      $log_file = $profiles_dir . "/".$profile[$i]."/".$profile[$i].".log";
      if (-e $data_file) {
        $zipped_flag = 0;
      }
      elsif (-e $datagz_file) {
        `gunzip -f $datagz_file`;
        $zipped_flag = 0;
      }
    
      if (-z $log_file) {
        #
        # Checks size of log file; if zero, it may indicate that the field solver run
        # terminated prematurely
        #
        printf "Job %s not completed\n", $profile[$i];
        printf "Data file incomplete\n";
        $incomplete_jobs_type[$num_incomplete_jobs] = -2;
        $incomplete_jobs[$num_incomplete_jobs++] = $i;
        $incomplete_job_found_flag = 0;
      }
      elsif (-s $log_file) {
        open(logfile, $log_file);
        while (<logfile>) {
          if (/Cpp_Exception/ || /cytflexceptionhandler/) {
	        $exception_jobs[$num_exception_jobs++] = $i;
            last;
	      }
        }
        close(logfile);
      }
      if (-e $tmp_file && 
          $incomplete_job_found_flag == -1) {
        #
        # Checks for existence of temporary files; if they exist, it may indicate that
        # the job terminated prematurely
        #
        printf "Job %s not completed\n", $profile[$i];
        if (-s $data_file) {
          ($size) = count_lines($data_file);
        }
        if ($size >= $lines[$i]) {
	      $incomplete_jobs_type[$num_incomplete_jobs] = -1;
        }
        else {
	      printf "Data file is incomplete: Required lines : %d Actual lines : %d\n", $lines[$i], $size;
          $incomplete_jobs_type[$num_incomplete_jobs] = -2;
        }
        $incomplete_jobs[$num_incomplete_jobs++] = $i;
        $incomplete_job_found_flag = 0;
      }
      if (-e $rpt_file && -s $rpt_file && -s $net_file && -s $data_file &&
        $incomplete_job_found_flag == -1) {
        #
        # Checks for existence of the proper files; if everything is ok, this means that
        # the job was fine
        #
        use File::stat;
        use Time::localtime;
        $date1 = stat($net_file)->mtime;
        if(-e $time_file) { $date2 = stat($time_file)->mtime; }
        else              { $date2 = stat($data_file)->mtime; }
        if ($date1 < $date2) {
          printf "Job %s times skewed\n", $profile[$i];
         ($size) = count_lines($data_file);
         if ($size >= $lines[$i]) {
           $incomplete_jobs_type[$num_incomplete_jobs] = -1;
         }
         else {
           printf "Data file is incomplete: Required lines : %d Actual lines : %d\n", $lines[$i], $size;
           $incomplete_jobs_type[$num_incomplete_jobs] = -2;
         }
        $incomplete_jobs[$num_incomplete_jobs++] = $i;
        $incomplete_job_found_flag = 0;
        next;
        }
        $nan_exists = 0;
          open(netascii, $net_file);
          while (<netascii>) {
            $line = lc($_);
            if (index($line, "nan") != -1 ||
                index($line, "inf") != -1) {
              $nan_exists = 1;
              last;
            }
          }
          close(netascii);
        if ($nan_exists == 1) {
          printf "Job %s had NaN or Inf numbers in data\n", $profile[$i];
          $incomplete_jobs_type[$num_incomplete_jobs] = -2;
          $incomplete_jobs[$num_incomplete_jobs++] = $i;
          $incomplete_job_found_flag = 0;
          next;
        }

        my($res) = check_rpt_file($profile[$i]);
        if ($res < 0) {
            $incomplete_jobs_type[$num_incomplete_jobs] = $res;
            $incomplete_jobs[$num_incomplete_jobs++] = $i;
            $incomplete_job_found_flag = 0;
        }
      }
      else {
        if ($incomplete_job_found_flag == -1) {
          printf "Job %s not completed\n", $profile[$i];
          $size = 0;
          if (-s $data_file) {
           ($size) = count_lines($data_file);
          }
          if ($size >= $lines[$i]) {
            $incomplete_jobs_type[$num_incomplete_jobs] = -1;
          }
          else {
            printf "Data file is incomplete: Required lines : %d Actual lines : %d\n", $lines[$i], $size;
            $incomplete_jobs_type[$num_incomplete_jobs] = -2;
          }
          $incomplete_jobs[$num_incomplete_jobs++] = $i;
        }
      }
    
      if ($zipped_flag == 0) {
        if (-e $data_file) {
          ;
        }
        else {
          `gzip -f  -9 $data_file`;
        }
      }
    }
 
  }
 
  chdir($cur_dir);  
  printf "Number of incomplete jobs for %s profiles = %d\n", $opt_ext, $num_incomplete_jobs;
  printf "Number of crashed jobs for %s profiles = %d\n", $opt_ext, $num_exception_jobs;
  if ($num_incomplete_jobs == 0 && $num_exception_jobs == 0) {
    ;
  }
  else {
    if ($fileopen_flag == 0) {
      open(outf, ">$output_file");
    }
    else {
      open(outf, ">>$output_file");
    }
    
    my %seen = ();
    for ($i = 0; $i < $num_incomplete_jobs; ++$i) {
      if ($incomplete_jobs_type[$i] == -1) {
        printf outf "%s\n\n", $mg_job_string[$incomplete_jobs[$i]] unless $seen{$mg_job_string[$incomplete_jobs[$i]]}++ ;
      }
      elsif ($incomplete_jobs_type[$i] == -2) {
        printf outf "%s\n", $job_string[$incomplete_jobs[$i]] unless $seen{$job_string[$incomplete_jobs[$i]] }++;
      }
    }
    if ($num_exception_jobs > 0) {
      printf outf "# Crashed jobs list\n#\n";
      for ($i = 0; $i < $num_exception_jobs; ++$i) {
        printf outf "#%s\n", $job_string[$exception_jobs[$i]] unless $seen{$job_string[$exception_jobs[$i]]}++;
      }
    }
    close(outf);
    `chmod 0755 $output_file`;
  }
}  



#############################################################################
sub get_permutation_prefixes()
{
 # my($str) = @_;
  my($i, $j);
  @prefixes=();
  $j = 0;
  my($Fldsub) = @_;#split(' ', $str, 9999);	
  for($i = 0; $i < @$Fldsub; $i++)
  {
	if (index($Fldsub->[$i], "--permutation", 0) != -1) 
	{
	  $prefixes[$j] = $Fldsub->[$i + 1];
	  $j++;
	}		
  }
  return @prefixes;
}

#############################################################################

sub get_profile_name()
{
  my($addr) = @_;
  my($i, $profile_name, @Fldsub);

  @Fldsub = @$addr;
  
  $i = find_pattern_name_match(\@Fldsub);
  if($i >= 0)
  {
  	$profile_name = $Fldsub[$i];
	  for($i = 0; $i <= $#Fldsub; $i++)
	  {
	   if(index($Fldsub[$i], "-generate", 0) != -1)
	   {
	     return ($profile_name, $Fldsub[$i+4]); 
	   }		 
	  }
	  return "--wrong_number--";
  }
  else
  {
  	return "--no_profile--";	
  }
}

#############################################################################
sub count_lines() {

  my($data_file) = @_;
  my($size, $buffer);

  $size = 0;
  open(FILE, $data_file);
  while (sysread FILE, $buffer, 4096) {
    $size += ($buffer =~ tr/\n//);
  }
  close(FILE);

  return($size);
}
#############################################################################
sub find_layername_match() {

  my($addr) = @_;
  my($i, $j, $str, @Fldsub);
  
  @Fldsub = @$addr;
  for ($i = 0; $i <= $#Fldsub; ++$i) {
    for ($j = 0; $j < $layer_cnt - 2; ++$j) {
      $str = "_".$layer_stack[$j]."_";
      if (index($Fldsub[$i], $str) != -1) {
	return($i);
      }
    }
  }  
  return(-1);
}
#############################################################################
sub find_string_match() {

  my($addr, $string, $offset) = @_;
  my($i, @Fldsub);
  
  @Fldsub = @$addr;
  for ($i = 0; $i <= $#Fldsub; ++$i) {
    if (index($Fldsub[$i], $string) != -1) {
      return($i + $offset);
    }
  }
  return(0);
}

############################################################################

sub is_variation_sufficient()
{
  my($loc_prefix, $loc_profile) = @_;
  
  require "$script_dir"."/miscutils.pm";
  my $loc_profiles_dir = GetFullPath($cur_dir."/profiles/");
  my $loc_sens_profiles_dir = GetFullPath($cur_dir."/sensitivity_models"."/profiles/");
	my $name_with_prefix =  $loc_prefix."_".$loc_profile; 
    	
  my $loc_data_file = $loc_profiles_dir . "/".$loc_profile."/".$loc_profile.".dat";    
  my $loc_datagz_file = $loc_profiles_dir . "/".$loc_profile."/".$loc_profile.".dat.gz";
  my $loc_sens_data_file = $loc_sens_profiles_dir . "/".$name_with_prefix."/".$name_with_prefix.".dat";    
  my $loc_sens_datagz_file = $loc_sens_profiles_dir . "/".$name_with_prefix."/".$name_with_prefix.".dat.gz";
  
  #print "file name : $loc_data_file \n"; print "gz file name : $loc_datagz_file \n";
  #print "sense file name : $loc_sens_data_file \n"; print "sense gz file name : $loc_sens_datagz_file \n";
  
  if (-e $loc_datagz_file) 
  {
    `gunzip -f $loc_datagz_file`;
  }
  if (-e $loc_sens_datagz_file) 
  {
    `gunzip -f $loc_sens_datagz_file`;
  }
  if((-e $loc_data_file) && (-e $loc_sens_data_file))
  { 
  	return need_model_generated($loc_data_file, $loc_sens_data_file, 0, 0);
  }
  else
  {
    return -1;
  }
}


####################################################################################################################################################
sub need_model_generated()
{
	my $generate_var_model = 0;
  my ($model_fn_nominal_loc, $model_fn_var_loc, $num_inputs_loc, $num_outputs_loc)  = @_;
  my (@norm_nominal,  @norm_difference);
  @norm_nominal    = calc_norm_of_dat_file($model_fn_nominal_loc, $num_inputs_loc, $num_outputs_loc);
  @norm_difference = calc_norm_of_dat_file($model_fn_var_loc, $num_inputs_loc, $num_outputs_loc);
  my $norm_out_sz = @norm_nominal;
  for (my $i = 0; $i < $norm_out_sz; ++$i) {
    if( abs( percent($norm_difference[$i], $norm_nominal[$i]) ) > 0.01 ) {
      return 1;
    }
  }
  return 0;
}  


##############################################################################
sub calc_norm_of_dat_file() {
use strict;
 my ($fname, $num_inputs, $number_of_outputs) = @_;
 open(filein, "< $fname") || die("Cannot open $ARGV[0]:\n$!\n");

 my @norm_out;
 my $linecnt = 0;
 my $line0 = <filein>;
 while ($line0) {
   ++($linecnt);
   my @Fld = split(' ', $line0, 10000);

   my $n_output = 0;

   for (my $i = $num_inputs; $i <= $#Fld-1; ++$i) {         
     $norm_out[$n_output] += $Fld[$i];
     $n_output++; 
   }

   $line0 = <filein>;
 }

 if ($linecnt) {
   for (my $i = 0; $i < @norm_out; ++$i) {
     $norm_out[$i] = $norm_out[$i] / $linecnt;
   }
 }

 return (@norm_out);
}

###########################################################################
sub percent {
    my ($result);

    if ($_[0] == 0.) {
	$result = 0.;
    }
    else {
	$result = 100. * ($_[1] - $_[0]) / $_[0];
    }

    return $result;
}

#########################################################################



