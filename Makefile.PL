use ExtUtils::MakeMaker;
use EV::MakeMaker;

print <<EOF;

***
*** This is an interface to the asynchronous dns resolver library, libadns
*** You need to have it installed before using this module.
***
*** For debian/ubuntu, this would get you there: apt-get install libadns1-dev
***

EOF

my $mm = MM->new({EV::MakeMaker::ev_args (
    dist         => {
       PREOP	=> 'pod2text ADNS.pm | tee README >$(DISTVNAME)/README; chmod -R u=rwX,go=rX . ;',
       COMPRESS	=> 'gzip -9v',
       SUFFIX	=> '.gz',
	            },
    NAME         => "EV::ADNS",
    VERSION_FROM => "ADNS.pm",
    LIBS         => ["-ladns"],
    PREREQ_FATAL => 1,
    PREREQ_PM    => {
       EV                  => 1.72,
    },
    EXTRA_META => q{
configure_requires:
  EV: 1.72
    },

)});

$mm->flush;

