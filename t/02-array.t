#!perl -T
use strict;
use warnings;
use Class::Builtin;
use Test::More qw/no_plan/; #tests => 1;

my $o = OBJ([0..7]);
is(ref $o, 'Class::Array', ref $o);
is($o->[1], 1);
is($o->[1]->length, 1);
is($o->join(','), '0,1,2,3,4,5,6,7');
is($o->shift, 0);
is($o->length, 7);
is($o->unshift(0)->length, 8);
is($o->pop, 7);
is($o->length, 7);
is($o->push(7)->length, 8);
my $s = $o->splice(1,2);
is($s->[1], 2);
is($o->join(','), '0,3,4,5,6,7');
$o->splice(1,0,@$s);
is($o->join(','), '0,1,2,3,4,5,6,7');
is($o->concat($s)->join(','), '0,1,2,3,4,5,6,7,1,2');
$o->pop; $o->pop;
$o->push($s);
is_deeply($o->[8], $s);
$o->pop;
