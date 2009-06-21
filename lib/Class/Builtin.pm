package Class::Builtin;
use 5.008001;
use warnings;
use strict;
our $VERSION = sprintf "%d.%02d", q$Revision: 0.1 $ =~ /(\d+)/g;

use Class::Scalar ();
use Class::Array ();
use Class::Hash ();

require Exporter;
use base qw/Exporter/;

our @EXPORT = qw(OBJ);

our %new = (
    '' => 'Class::Scalar',
    map { $_ => 'Class::' . ucfirst( lc($_) ) } qw/ARRAY HASH/
  );

sub new {
    my $class = shift;
    my $obj   = shift;
    my $new   = $new{ ref $obj } or return $obj;
    $new->new($obj);
}

{
    # to make $a->sort happy
    if (my $pkg = caller){
	no strict 'refs';
	no warnings 'once';
	${$pkg . '::a'} = undef;
	${$pkg . '::b'} = undef;
	${$pkg . '::_'} = undef;
    }
}

sub OBJ { __PACKAGE__->new(@_) }

1; # End of Class::Builtin

=head1 NAME

Class::Builtin - Scalar/Array/Hash as objects

=head1 VERSION

$Id$

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Class::Builtin;
    my $scalar = OBJ('perl');
    my $array  = OBJ([0..9]);
    my $hash   = OBJ({key=>'value'});

    print $scalar->length; # 4;
    print $array->length;  # 10;
    print $hash->keys->[0] # 'key'

=head1 EXPORT

C<OBJ>

=head1 FUNCTIONS

See L<Class::Scalar>, L<Class::Array>, and L<Class::Hash> for details.

To check what methods the object has, simply try

  print $o->methods->join("\n");

=head1 AUTHOR

Dan Kogai, C<< <dankogai at dan.co.jp> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-class-builtin at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Class-Builtin>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Class::Builtin

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Class-Builtin>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Class-Builtin>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Class-Builtin>

=item * Search CPAN

L<http://search.cpan.org/dist/Class-Builtin/>

=back

=head1 ACKNOWLEDGEMENTS

L<autobox>, L<overload>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Dan Kogai, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
