use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'Calendar::Hijri',
    AUTHOR             => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM       => 'lib/Calendar/Hijri.pm',
    ABSTRACT_FROM      => 'lib/Calendar/Hijri.pm',
    LICENSE            => 'artistic_2',
    PL_FILES           => {},
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM     => {
        'Time::Local'     => '1.11',
        'Time::localtime' => '1.02',
        'List::Util'      => '1.21',
        'Date::Calc'      => '5.7',
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Calendar-Hijri-*' },
    (eval { ExtUtils::MakeMaker->VERSION(6.46) } ? (META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/Manwar/Calendar-Hijri.git',
                web  => 'https://github.com/Manwar/Calendar-Hijri',
            },
        }})
     : ()
    ),
);
