package scalar::object;
# use 5.010; -- works ok on 5.8
use strict;
use warnings;
use overload ();
use Class::Scalar;

my $class = __PACKAGE__;

sub import {
    $^H{$class} = 1;
    overload::constant(
        map {
            $_ => sub { Class::Scalar->new(shift) }
          } qw/integer float binary q/
    );
}

sub unimport {
    $^H{$class} = 0;
    overload::remove_constant( '', qw/integer float binary q qr/ );
}

sub in_effect {
    my $level = shift || 0;
    my $hinthash = ( caller($level) )[10];
    return $hinthash->{$class};
}

1;


=head1 NAME

scalar::object - automagically turns scalar constants into objects

=head1 VERSION

$Id: object.pm,v 0.1 2009/06/21 09:09:26 dankogai Exp dankogai $

=head1 SYNOPSIS

  use Class::Scalar;
  {
     use scalar::objects;
     my $o = 42;      # $o is a Class::Scalar object
     print 42->length # 2;
  }
  my $n = 1;       # $n is an ordinary scalar
  print $n->length # dies

=head1 EXPORT

None.  But see L<Class::Builtin>

=head1 TODO

This section itself is to do :)

=head1 SEE ALSO

L<Class::Builtin>, L<Class::Scalar>

=head1 AUTHOR

Dan Kogai, C<< <dankogai at dan.co.jp> >>

=head1 ACKNOWLEDGEMENTS

L<autobox>, L<overload>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Dan Kogai, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
