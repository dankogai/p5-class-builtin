package Class::Hash;
use 5.008001;
use warnings;
use strict;
our $VERSION = sprintf "%d.%02d", q$Revision: 0.1 $ =~ /(\d+)/g;

use overload (
    '""' => sub { 
	my $self  = shift;
	CORE::sprintf '{%s}', $self->keys->sort->map(sub{
	    sprintf "%s => %s", $_, $self->{$_} 
	})->join(", ");
    },
);

sub new{
    my $class = shift;
    my $href  = shift;
    my %self;
    while(my ($k, $v) = each %$href){
	$self{$k} = Class::Builtin->new($v);
    }
    bless \%self, $class;
}

sub clone{
    __PACKAGE__->new({ %{$_[0]} });
}

sub delete {
    my $self = shift;
    my @deleted = CORE::delete @{$self}{@_};
    Class::Array->new([@deleted]);
}

sub exists {
    my $self = shift;
    my $key  = shift;
    CORE::exists $self->{$key}
}

for my $meth (qw/keys values/){
    eval qq{
     sub Class::Hash::$meth
     {
       Class::Array->new([CORE::$meth \%{\$_[0]}])
     }
    };
    die $@ if $@;
}

sub length{
    CORE::length keys %{$_[0]};
}

sub each {
    my $self = shift;
    my $block = shift || die;
    while (my ($k, $v) = each %$self){
	$block->($k, $v);
    }
}

sub methods{
    Class::Array->new( [sort grep { defined &{$_} }keys %Class::Hash:: ] );
}

1; # End of Class::Hash

=head1 NAME

Class::Hash - Hash as an object

=head1 VERSION

$Id: Hash.pm,v 0.1 2009/06/21 09:09:26 dankogai Exp dankogai $

=head1 SYNOPSIS

  use Class::Hash;                               # use Class::Builtin;
  my $foo = Class::Hash->new({ key => 'value'}); # OO({ key => 'value' });
  print $foo->keys->[0]; # 'key'

=head1 EXPORT

None.  But see L<Class::Builtin>

=head1 METHODS

This section is under construction. For the time being, try

  print Class::Hash->new({})->methods->join("\n")

=head1 TODO

This section itself is to do :)

=over 2

=item * more methods

=back

=head1 SEE ALSO

L<Class::Builtin>, L<Class::Scalar>, L<Class::Array>

=head1 AUTHOR

Dan Kogai, C<< <dankogai at dan.co.jp> >>

=head1 ACKNOWLEDGEMENTS

L<autobox>, L<overload>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Dan Kogai, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
