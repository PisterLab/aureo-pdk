($techfile, $model_dir, $profile_dir, $version) = @ARGV;

#
# Model writer section
#
my $qts_dir = '/share/instsww/cadence/QUANTUS.22.11.000/bin';
my $script_dir = '/home/aa/users/cs199-cwg/aureoProject/aureo-pdk/debugTech/shield/.tech_scripts';
`perl $script_dir/mw_3d.pl 5 $profile_dir $model_dir $techfile $version -exe $qts_dir`;

