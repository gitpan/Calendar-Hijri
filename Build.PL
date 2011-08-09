use strict;use warnings;
use Module::Build;

my $builder = Module::Build->new(
    sign              => 1,
    module_name       => 'Calendar::Hijri',
    license           => 'perl',
    dist_author       => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    dist_version_from => 'lib/Calendar/Hijri.pm',
    add_to_cleanup    => [ 'Calendar-Hijri-*' ],
    build_requires    => {
        'Readonly'        => '1.03',
        'Test::More'      => 0,
        'Time::Local'     => '1.11',
        'Time::localtime' => '1.02',
        'List::Util'      => '1.21',
        'Date::Calc'      => '5.7',
        'Module::Build'   => '0.36',
    },
);

$builder->create_build_script();