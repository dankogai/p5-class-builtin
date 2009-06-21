#!perl -T
use strict;
use warnings;
use Class::Builtin;
use Test::More qw/no_plan/; #tests => 1;
use Encode;

my $o = OBJ('小飼弾');
is(ref $o, 'Class::Scalar', ref $o);

is($o->length, 9, sprintf qq('%s'->length), $o);
is($o->decode_utf8->length, 3, sprintf qq('%s'->decode_utf8->length), $o);
is($o->decode_utf8->[2], decode_utf8('弾'), sprintf qq('%s'->decode_utf8->[2]), $o);

$o = OBJ(0.00);
is (!$o, !!1, 'bool');
is ("$o", "0", '""');
is ($o+0, 0, '0+');

my $a  = 42;
my $b  = atan2(1,1)*4;
my $oa = OBJ $a;
my $ob = OBJ $b;

for my $op (qw{+ - * / % ** << >> & | ^ . x }){
    my $code = eval qq{ sub { \$_[0] $op \$_[1] } };
    my $c  = $code->($a,  $b);
    my $oc = $code->($oa, $b);
    ok (ref $oc, "ref (OBJ($a) $op $b)");
    is ($c, $oc, "OBJ($a) $op $b");
    $oc = $code->($oa, $ob);
    ok (ref $oc, "ref (OBJ($a) $op OBJ($b)");
    is ($c, $oc, "OBJ($a) $op OBJ($b)");
}

__END__
