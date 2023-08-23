($techfile, $model_dir, $profile_dir, $version) = @ARGV;

#
# Model writer section
#
my $qts_dir = '/share/instsww/cadence/QUANTUS.22.11.000/bin';
my $script_dir = '/home/aa/users/cs199-ais/Desktop/aureoProject/aureo-pdk/debugTech/LIScaledAug13/.tech_scripts';
`perl $script_dir/mw_limits.pl 2 $model_dir $profile_dir $version -exe $qts_dir`;

#
# Model pruner section
#
use Cwd;
$cur_dir = cwd;

chdir($model_dir);
$model_pruner = "$qts_dir/modelgen prune ";


#
#Store everything in the tech file
#
`cat 2*.mdl > $techfile`;

`rm -f 2*.mdl`;

chdir($cur_dir);

