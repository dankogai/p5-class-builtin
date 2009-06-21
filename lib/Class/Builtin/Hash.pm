package Class::Builtin::Hash;
use 5.008001;
use warnings;
use strict;
our $VERSION = sprintf "%d.%02d", q$Revision: 0.2 $ =~ /(\d+)/g;

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
    Class::Builtin::Array->new([@deleted]);
}

sub exists {
    my $self = shift;
    my $key  = shift;
    CORE::exists $self->{$key}
}

for my $meth (qw/keys values/){
    eval qq{
     sub Class::Builtin::Hash::$meth
     {
       Class::Builtin::Array->new([CORE::$meth \%{\$_[0]}])
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

sub methods {
    Class::Builtin::Array->new(
        [ sort grep { defined &{$_} } keys %Class::Builtin::Hash:: ] );
}

1; # End of Class::Builtin::Hash

=head1 NAME

Class::Builtin::Hash - Hash as an object

=head1 VERSION

$Id: Hash.pm,v 0.2 2009/06/21 15:44:41 dankogai Exp dankogai $

=head1 SYNOPSIS

  use Class::Builtin::Hash;                             # use Class::Builtin;
  my $oo = Class::Builtin::Hash->new({key => 'value'}); # OO({key =>'value'});
  print $oo->keys->[0]; # 'key'

=head1 EXPORT

None.  But see L<Class::Builtin>

=head1 METHODS

This section is under construction. For the time being, try

  print Class::Builtin::Hash->new({})->methods->join("\n")

=head1 TODO

This section itself is to do :)

=over 2

=item * more methods

=back

=head1 SEE ALSO

L<Class::Builtin>, L<Class::Builtin::Scalar>, L<Class::Builtin::Array>

=head1 AUTHOR

Dan Kogai, C<< <dankogai at dan.co.jp> >>

=head1 ACKNOWLEDGEMENTS

L<autobox>, L<overload>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Dan Kogai, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
