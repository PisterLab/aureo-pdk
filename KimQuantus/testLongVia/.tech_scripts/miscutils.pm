#######################################################################
#
#  CdnLglNtc    [ Copyright (c) 2004-2005
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
########################################################################

#####
# Record the searchpath
#####
@Dft_Searchpath = &Dft_GetSearchpath();

#####
# Symbolic return values for attempts to run a test series.
#####
$Dft_SeriesPassed       = 0;
$Dft_SeriesFailed       = 1;
$Dft_SeriesDidNotRun    = 2;
%Dft_SeriesResultNames = (
    $Dft_SeriesPassed,      "pass",
    $Dft_SeriesFailed,      "fail",
    $Dft_SeriesDidNotRun,   "didNotRun",
);

#####
# Symbolic return values for test runs.
#####
$Dft_TestPassed     = 0;
$Dft_TestSkipped    = 1;
$Dft_TestBroke      = 2;
$Dft_TestFailed     = 3;
%Dft_TestResultNames = (
    $Dft_TestPassed,    "pass",
    $Dft_TestSkipped,   "skip",
    $Dft_TestBroke,     "broke",
    $Dft_TestFailed,    "fail",
);


#####
# Return the current operating system, as seen by Perl.
# (Usually used to differentiate windows and unix.)
#####
sub Dft_GetOS
{
    return($^O);
}

#####
# Return the platform as seen by the Simplex build system.
#####
sub Dft_GetPlatform
{
    local($result);
    local($OS) = &Dft_GetOS();

    if ($OS =~ /Win/i) {
        $result = "win32";
    } else {
        $result = `whichArch`;
        chop($result);
    }

    return($result);
}

#####
# This function calculates the path separator for this platform.
#####
sub Dft_PathSeparator
{
    local($pathsep);
    local($OS) = &Dft_GetOS();
    if ($OS =~ /Win/i) {
        $pathsep = "\\";
    } else {
        $pathsep = "/";
    }
    return($pathsep);
}

#####
# On unix, convert \ to /; on windows, convert / to \.
#####
sub Dft_FixPathSeparator
{
    local($arg) = @_;

    local($OS) = &Dft_GetOS();
    if ($OS =~ /Win/i) {
        $arg =~ s=/=\\=g;
    } else {
        $arg =~ s=\\=/=g;
    }

    return($arg);
}

#####
# This function joins filename sections together, typically used as
#    Dft_JoinPathnames($directory, $file);
# It is smart about UNIX vs. Windows issues.
#####
sub Dft_JoinPathnames
{
    local($pathsep) = &Dft_PathSeparator();
    local($result) = "";
    local($frag);
    foreach $frag (@_) {
        if ($result ne "") {
            $result = $result . $pathsep . $frag;
        } else {
            $result = $frag;
        }
    }

    return($result);
}

#####
# Get the directory part from a pathname.
#####
sub Dft_DirName
{
    local($_) = @_;
    local($pathsep) = &Dft_PathSeparator();
    local($result);

    local($pathpat) = $pathsep;
    $pathpat =~ s/\\/\\\\/;

    if (/$pathpat/) {
        s/(.*)$pathpat.*/$1/;
        $result = $_;
        if ($result eq "") {
            $result = $pathsep;
        }
    }

    return($result);
}

#####
# Get the filename part from a pathname.
#####
sub Dft_BaseName
{
    local($result) = @_;
    local($pathsep) = &Dft_PathSeparator();

    local($pathpat) = $pathsep;
    $pathpat =~ s/\\/\\\\/;
    $result =~ s/.*$pathpat//;

    return($result);
}

#####
# First arg is file to locate, remaining args are places to look.
# Always tries the file without a prefix from the list, first.
# Returns the first matching name found.  Returns empty string
# if not found.
#####
sub Dft_FindFile
{
    local($name, @places) = @_;
    local($result) = "";

    if (-e $name) {
        $result = $name;
    } else {
        local($place);
        foreach $place (@places) {
            local($joined) = &Dft_JoinPathnames($place, $name);
            if (-e $joined) {
                $result = $joined;
                last;
            }
        }
    }

    return($result);
}

#####
# Return the searchpath as an array of directory values.
#####
sub Dft_GetSearchpath
{
    local($divider);

    local($OS) = &Dft_GetOS();
    if ($OS =~ /Win/i) {
        $divider = ";";
    } else {
        $divider = ":";
    }

    return(split(/$divider/, $ENV{"PATH"}));
}

#####
# This function produces a string which:
#    a) Begins with a lower-case letter.
#    b) Consists only of lower-case letters, numerals, and underscores.
#    c) Is different each time this function is called, even if you call it
#       from multiple processes at the same time with the same pid.
# 
# This works only so well.
#
# On Unix, the chances of getting the same pid and the same second on the
# same host with the same argv are effectively zero (unless you call it
# multiple times from the same perl script -- in which case the
# random number will save you).
#
# On Windows, it would not be that hard to get all of these at once:
#   same pid, same timestamp, same argv, same amount of freespace on the disks
# (The "freespace" is often 7FFFFFFF on Samba volumes, for example.)
# So we use uuidgen (which comes with VC++) to get a unique value.
# This assumes, of course, that you are using VC++; but if you are running
# the test suite on Windows this seems likely.
#####
sub Dft_GenerateUniqueText
{
    # Initialize if this is the first time this is called.
    if (! $Dft_UniqueText_has_run) {
        $Dft_UniqueText_has_run  = 1;
        $Dft_UniqueText_args     = $0 . "@ARGV"; 
        local($OS) = &Dft_GetOS();
        local($command);
        if ($OS =~ /Win/i) {
            if ("" eq &Dft_FindFile("uuidgen.exe", @Dft_Searchpath)) {
                die("You must set up VC++ before using this program\n");
            }
            $command = "uuidgen";
        } else { 
            if ("" eq &Dft_FindFile("uname", @Dft_Searchpath)) {
                die("Cannot find uname on your PATH\n");
            }
            $command .= "uname -a";
        }
        $Dft_UniqueText_hostspecific = `$command`;
    }

    local($timestr) = time();
    local($random) = int(rand(50000));

    # We hash then 36-ize the final result so it is reasonably short;
    # if we just return the whole string it will be unique but very
    # long for typing.
    return(Dft_Base36(Dft_HashString(
                                    $Dft_UniqueText_hostspecific
                                    . "_" . $timestr
                                    . "_" . $$
                                    . "_" . $Dft_UniqueText_args
                                    . "_" . $random)));
}

#####
# Compute a hash function of the arguments, treated as one giant string.
# Has about 29 bits worth of output value, returned as a positive int.
#####
sub Dft_HashString
{
    local($result) = 0;     # A 32-bit value
    local($magic1) = 1973;
    local($magic2) = 733;
    local($twenty_bits) = hex("fffff");

    foreach $char (split(//, "@_")) {
        $result = $result + (ord($char) * $magic2);
        $result = ($result & $twenty_bits) * $magic1;
    }
    return($result);
}

#####
# Convert an int into base 36.
# Note this only works for 32-bit integer values, but doesn't check
# that the value fits into a 32-bit int.
#####
sub Dft_Base36
{
    local($value) = int($_[0]);
    local($result);
    local($power);
    local($base36chars) = "0123456789abcdefghijklmnopqrstuvwxyz";
    local(@base36powers) = ( 60466176, 1679616, 46656, 1296, 36, 1);

    # Put on a "sign" and make the value positive, remembering that there
    # are more negative numbers than positive (by 1).
    if ($value == -2147483648) {
        return("nzik0zk");
    } elsif ($value < 0) {
        $value = - $value;
        $result = "n";
    } else {
        $result = "p";
    }

    # Convert (with leading 0's)
    foreach $power (@base36powers) {
        local($excess) = $value / $power;
        $value = $value % $power;
        $result .= substr($base36chars, $excess, 1);
    }

    # Strip leading 0's
    $result =~ s/^n0+/n/;
    $result =~ s/^p0+/p/;
    $result =~ s/^p$/0/;

    return($result);
}

#####
# Ensure this is an absolute fullpath, not a relative path.
#####
sub Dft_CheckAbsolute
{
    local($path) = @_;
    local($result);
    local($OS) = &Dft_GetOS();

    if ($OS =~ /Win/i) {
        $result =  (substr($path, 0, 1) eq "\\")
                || ($path =~ /^[a-z]\:\\/i);
    } else {    # On unix, it's easy
        $result = substr($path, 0, 1) eq "/";
    }

    return($result);
}

#####
# Return the name of the directory which is the root of the build area.
#####
sub Dft_BuildRoot
{
    local($br) = $ENV{"DFT_BUILD_ROOT"};

    if ($br eq "") {
        die("Env't variable DFT_BUILD_ROOT must be set.\n");
    }

    if (!&Dft_CheckAbsolute($br)) {
        die("Env't variable DFT_BUILD_ROOT must not be a relative pathname.\n"
           ."It is: '$br'\n");
    }

    return($br);
}

#####
# Define environment variables used within the test harness
# (the ones which don't change on a per-series basis).
#####
sub Dft_SetGlobalEnvVars
{
    local($root) = &Dft_BuildRoot();

    local($output) = $ENV{"DFT_TEST_OUTPUT"};
    if ($output eq "") {
        $output = &Dft_JoinPathnames($root, "lib", &Dft_GetPlatform(), "test");
        $ENV{"DFT_TEST_OUTPUT"} = $output;
    }
    if (!&Dft_CheckAbsolute($output)) {
        die("\$DFT_TEST_OUTPUT must not be a relative pathname.\n"
           ."It is: '$output'\n");
    }
    local($unique) = &Dft_GenerateUniqueText();
    $ENV{"DFT_UNIQUE_NAME"} = $unique;
}

#####
# Return the name of the directory containing DFT scripts.
#####
sub Dft_DftHome
{
    return(&Dft_JoinPathnames(&Dft_BuildRoot(), "libdft", "src"));
}

#####
# Return the name of the directory containing test configuration files.
#####
sub Dft_TestsDir
{
    return(&Dft_JoinPathnames(&Dft_BuildRoot(), "tests"));
}

#####
# Return the root of the output directory
#####
sub Dft_OutputDir
{
    return($ENV{"DFT_TEST_OUTPUT"});
}

#####
# Return the name of the directory containing test series source.
#####
sub Dft_SeriesHome
{
    return($ENV{"DFT_SERIES_HOME"});
}

#####
# Return the name of the current test series
#####
sub Dft_SeriesName
{
    return($ENV{"DFT_SERIES_NAME"});
}

#####
# Return the root of the output directory
#####
sub Dft_UniqueName
{
    return($ENV{"DFT_UNIQUE_NAME"});
}

#####
# Return the entire list of files in a directory
#####
sub Dft_ReadDir
{
    local($dirname) = @_;
    local(*DIR);

    opendir(DIR, $dirname)
        || die("Cannot get content of dir $dirname:\n$!\n");
    local(@allfiles) = readdir(DIR);
    closedir(DIR);

    return(@allfiles);
}

#####
# Change the current dir, and also update PWD along the way
#####
sub Dft_Chdir
{
    local($dirname) = &Dft_FixPathSeparator(@_);

    # This is because we don't know how to figure out the new fullpath
    # to the new working dir unless it's already a fullpath.  (On
    # UNIX we can maybe try system('pwd') but there is no Windows
    # equivalent.)  If we solve this problem, we can eliminate
    # this restriction.
    if (!&Dft_CheckAbsolute($dirname)) {
        die("New working directory must be specified using a full pathname.\n");
    }

    local($result) = chdir($dirname);

    if ($result) {
        $ENV{'PWD'} = $dirname;
    } else {
        die("Can't set working directory to $dirname:\n$!\n");
    }
    return($result);
}

#####
# This function kills files and directories (recursively).
# It works very hard at this, so it is somewhat slow.
#####
sub Dft_RemoveFileOrDirectory
{
    local($pathname);

    foreach $pathname (@_) {
        if (-e $pathname) {
            if (-d _) {
                &Dft_RemoveDirectory($pathname);
            } else {
                &Dft_RemoveFile($pathname);
            }
        }
    }
}

#####
# This function kills a directory, recursively killing its content first.
#####
sub Dft_RemoveDirectory
{
    local($pathname) = @_;

    if (-e $pathname) {
        local(@content) = &Dft_ReadDir($pathname);
        local($entry);

        chmod(0777, $pathname);

        foreach $entry (@content) {
            next if $entry eq ".";
            next if $entry eq "..";

            &Dft_RemoveFileOrDirectory(&Dft_JoinPathnames($pathname, $entry));
        }

        if (!rmdir($pathname)) {
            if (&Dft_GetOS() =~ /Win/i) {
                system("rmdir /S /Q $pathname");
            } else {
                system("rm -rf $pathname");
            }
        }
    }
    if (-e $pathname) {
        printf("Unable to remove directory $pathname.\n");
    }
}

#####
# This function kills a file.  It tries very hard.  Note that on Windows
# I have seen files take a while to kill.  Either unlink() is unreliable
# or the fact of their deletion happens asynchronously.  So this is coded
# to wait and repeat a few times before giving up.
#####
sub Dft_RemoveFile
{
    local($pathname) = @_;
    local($tries) = 0;

    while ((-e $pathname) && ($tries < 5)) {
        &Dft_TryToRemoveFile($pathname);
        $tries++;
    }
    if (-e $pathname) {
        printf("Unable to delete file $pathname.\n");
    }
}

#####
# This file tries to remove a file.
#    1) Unlink it.
#    2) If that fails, change permissions to be writable then unlink it.
#    3) If that fails, ask the system's own file killer to get it.
#####
sub Dft_TryToRemoveFile
{
    local($pathname) = @_;

    if (-e $pathname) {
        if (1 != unlink($pathname)) {
            chmod(0777, $pathname);
            if (1 != unlink($pathname)) {
                if (&Dft_GetOS() =~ /Win/i) {
                    system("del $pathname");
                    if (-e $pathname) {
                        system("del /f $pathname"); # NT only
                    }
                } else {
                    system("rm -f $pathname");
                }
            }
        }
    }
}


#####
# send the content of the file to stdout
#####
sub Dft_CatFile
{
    local($file) = @_;

    local($OS) = &Dft_GetOS();
    if ($OS =~ /Win/i) {
        system("type $file");
    } else {
        system("cat $file");
    }
}

#####
# Execute the string as a perl command, remembering to add the appropriate
# arguments to the string.
#####
sub Dft_Perl
{
    local($command) = "perl";   # Add "-w" to this for debugging
    local($testdir) = &Dft_TestsDir();
    local($seriesdir) = &Dft_SeriesHome();

    if ($testdir ne "") {
        $command .= " -I$testdir";
    }
    if ($seriesdir ne "") {
        $command .= " -I$seriesdir";
    }

    $command .= " @_";
    return(system($command));
}
#####
# Figures out the absolute path from the relative path if necessary
#####
sub GetFullPath {

  local($filename) = @_;
  local($cur_dir);

  use Cwd;
  $cur_dir = cwd;
  if (&Dft_CheckAbsolute($filename)) {
    return($filename);
  }
  else {
    return($cur_dir."/".$filename);
  }
}

sub ProcessOptionalArg() {

  local($arg, $default_val) = @_;

  if (!$arg) {
    return($default_val);
  }
  else {
    return($arg);
  }
}

#################################################################################################
sub read_qc_file() {

    my($input_file, $net, $cnt, $i, $cap, $row, @Fld);

    my($input_file, $net) = @_;

    open(infile, $input_file);
    $row = 0;
    $cnt = 1;
    while (<infile>) {
	@Fld = split(' ', $_, 9999);
	
	if (index($Fld[0], $net) != -1 && index($Fld[0], ':') != -1) {
	    $end = index($Fld[1], 'F') - 1;
	    $cap = substr($Fld[1], 0, $end);
	    if (index($Fld[1], 'aF') != -1) {
		$cap *= .001;
	    }
	    $row++;
	    if ($row == $cnt) {
		return($cap);
	    }
	}
    }
    close(infile);

    return(0.);
}
#########################################################################
sub percent_error {

  if ($_[0] == 0) {
      return(100000.);
  }

  return(100. * (1. - ($_[1] / $_[0])));
}

#########################################################################
sub GetFileName {

  local($longfilename) = @_;
  local($i) = rindex($longfilename, "/");

  if ($i != -1) {
    return(substr($longfilename, $i + 1));
  }

  return($longfilename);
}


1;
