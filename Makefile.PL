use ExtUtils::MakeMaker;
use strict;

WriteMakefile (
    NAME            => 'Canonical::Roadmap::Generator',
    VERSION_FROM    => 'lib/Canonical/Roadmap/Generator', # finds $VERSION
    dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    EXE_FILES       => ['bin/roadmap-generator'],
    PREREQ_PM       => { 'JSON::Any'    => 1.22,
                         'LWP::Simple'  => 0,
                       },
    AUTHOR          => 'Jos Boumans <jos.boumans[at]canonical.com>',
);
