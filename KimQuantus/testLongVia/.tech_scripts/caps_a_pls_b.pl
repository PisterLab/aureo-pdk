######################################################################
#
#  CdnLglNtc    [ Copyright (c) 2002-2004
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
#  Synopsis     [ capacitances of FILE3 = alpha*FILE1 + beta*FILE2 ]
#  Description  [ Has meta knowledge of historical stuff at Simplex,
#                 such as the old CPP_EMBED_NOTICES convention.
#
#                 Requires the code was reasonably compliant with the
#                 old standard.
#               ]
########################################################################

 open(FILE0, "< $ARGV[0]") || die("Cannot open $ARGV[0]:\n$!\n");
 open(FILE1, "< $ARGV[1]") || die("Cannot open $ARGV[1]:\n$!\n");
 open(FILE3, "> $ARGV[2]") || die("Cannot open $ARGV[2]:\n$!\n");
 
 $alpha = $ARGV[3];
 $beta  = $ARGV[4];
 $num_inputs = $ARGV[5];

 $debug = 1; 
 if ($debug) {
	print "f1 = ", $ARGV[0], " f2 =  " , $ARGV[1], " f3= " , $ARGV[2]."\n";
	print "alpha = ", $alpha, " beta " , $beta, " num_inputs  =", $num_inputs;
 }

 #most of code is stolen from check fields
 $linecnt = 0;
 $line0 = <FILE0>;
 $line1 = <FILE1>;
 while ($line0 && $line1) {
   ++($linecnt);
   $failure = &linear_op_lines();
   $line0 = <FILE0>;
   $line1 = <FILE1>;
 }
  
# EOF but only for one of the two files, so failure
 if ($line0 || $line1) {
    $failure = 1;    
 }
 

exit($failure);


sub linear_op_lines
{
  my($failure0, $failure1);
  my($i, @Fld1, @Fld2, @Fld3);

  @Fld1 = split(' ', $line0, 10000);
  @Fld2 = split(' ', $line1, 10000);

  if ($#Fld1 != $#Fld2) {
     if ($debug) {
	     printf "Number of columns are different in the following strings:\n%s\n%s\n i = %d",$line0, $line1, $i; 
     }
     return(1);
  }
  else {
      for ($i = 0; $i <= $#Fld1-1; ++$i) {
#     	  print "\n $Fld1[$i]  $Fld2[$i] $i \n"; 
        if ( $i >= $num_inputs ) {
            $Fld3[$i] = $alpha * $Fld1[$i] + $beta* $Fld2[$i];
			printf(FILE3 "%g ", $Fld3[$i]);
	    }
		else {
		    if ($debug) {
 				if ( $Fld2[$i] ne $Fld1[$i] ) {
  		    	  printf "Different inputs in the following strings:\n%s\n%s\n",$line0, $line1; 
				}
		    }		
	        $Fld3[$i] = $Fld1[$i];
        	printf(FILE3 "%.5f ", $Fld3[$i]);
		}
	}
	printf(FILE3 "\n", $Fld3[$i]);
  }
}

