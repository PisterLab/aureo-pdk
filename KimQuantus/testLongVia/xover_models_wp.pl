($techfile, $model_dir, $profile_dir, $version) = @ARGV;

#
# Model writer section
#
my $qts_dir = '/share/instsww/cadence/QUANTUS.22.11.000/bin';
my $script_dir = '/home/aa/users/cs199-ais/Desktop/aureoProject/aureo-pdk/debugTech/LIScaledAug13/.tech_scripts';
`perl $script_dir/mw_3d.pl 6 $profile_dir $model_dir $techfile $version -exe $qts_dir`;

