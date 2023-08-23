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


use strict;
use Getopt::Long;

my $ict_file;

GetOptions("ict=s" => \$ict_file);

my ($run_jobs,$pend_jobs,$suspend_jobs);
my $start;
my $user;
my $multi;
my $count;

my $script_dir = ".";
my $pos = rindex($0, "/");
if ($pos != -1) {
  $script_dir = substr($0, 0, $pos);
}

require $script_dir."/miscutils.pm";
$ict_file = GetFileName($ict_file);

$count = 0;
$start = time();
sleep(3);
do {

  $run_jobs = 0;
  $pend_jobs = 0;
  $suspend_jobs = 0;

  `bjobs -w > bjobs.log`;
  open(bjobs, "bjobs.log");
  while (<bjobs>) {
    my $process = $_;
    chomp($process);

    next unless ($process =~ /\Q echo  $ict_file \E/ ||
                 $process =~ /\Qmg $ict_file\E/);

    if ($process =~ /RUN/) {
      $run_jobs++;
    } else {
      if ($process =~ /PEND/) {
        $pend_jobs++;
      } else {
        if ($process =~ /SSUSP/ || $process =~ /PSUSP/ || $process =~ /USUSP/) {
          $suspend_jobs++;
        }
      }
    }
  }
  close(bjobs);
  if ($suspend_jobs > 0 ) {
    printf "%5d jobs running, %5d jobs pending, %5d jobs suspending\n", $run_jobs, $pend_jobs, $suspend_jobs;
  }
  else {
    printf "%5d jobs running, %5d jobs pending\n", $run_jobs, $pend_jobs;
  }
 
  unlink("bjobs.log");
  $user = time() - $start;
  $multi = int  $user / 300 + 1; 
  if ($multi > 10) {
    $multi = 10;
  }
  if ($run_jobs+$pend_jobs+$suspend_jobs == 0) {
    $count++;
    $multi = 1;
  }
  if ($run_jobs+$pend_jobs+$suspend_jobs > 0 || $count <= 1) {
    sleep($multi * 90);
  }
} until ($run_jobs+$pend_jobs+$suspend_jobs == 0 && $count > 1);
