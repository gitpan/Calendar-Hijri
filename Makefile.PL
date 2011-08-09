use strict;use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Calendar::Hijri',
    AUTHOR        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM  => 'lib/Calendar/Hijri.pm',
    ABSTRACT_FROM => 'lib/Calendar/Hijri.pm',
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'Calendar-Hijri-*' },
    PREREQ_PM     => {
        'Readonly'        => '1.03',
        'Test::More'      => 0,
        'Time::Local'     => '1.11',
        'Time::localtime' => '1.02',
        'List::Util'      => '1.21',
        'Date::Calc'      => '5.7',
    },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
);