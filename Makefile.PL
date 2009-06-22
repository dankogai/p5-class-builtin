#
# $Id: Makefile.PL,v 0.2 2009/06/22 15:52:18 dankogai Exp dankogai $
#
use 5.008001;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Class::Builtin',
    AUTHOR        => 'Dan Kogai <dankogai@dan.co.jp>',
    VERSION_FROM  => 'lib/Class/Builtin.pm',
    ABSTRACT_FROM => 'lib/Class/Builtin.pm',
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002
        ? ( 'LICENSE' => 'perl' )
        : () ),
    PL_FILES  => {},
    PREREQ_PM => {
        'Test::More'   => 0,
        'Encode'       => 0,
        'Data::Dumper' => 0,
        'Scalar::Util' => 0,
        'List::Util'   => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Class-Builtin-*' },
);
