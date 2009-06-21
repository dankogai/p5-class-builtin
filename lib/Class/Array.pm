package Class::Array;
use 5.008001;
use warnings;
use strict;
our $VERSION = sprintf "%d.%02d", q$Revision: 0.1 $ =~ /(\d+)/g;

use List::Util ();

use overload (
    '""' => sub { CORE::sprintf '[%s]', $_[0]->join(',') },
);

sub new{
    my $class = shift;
    my $aref  = shift;
    bless [ map { Class::Builtin->new($_) } @$aref ], $class;
}

sub clone{
    __PACKAGE__->new([ @{$_[0]} ]);
}

for my $unary (qw/shift pop/) {
    eval qq{
     sub Class::Array::$unary
     { CORE::$unary \@{\$_[0]} }
    };
    die $@ if $@;
}

for my $binary (qw/unshift push/) {
    eval qq{
      sub Class::Array::$binary
      {
        my \$self = CORE::shift;
        CORE::$binary \@\$self, map { Class::Builtin->new(\$_) } \@_;
        \$self;
      }
    };
    die $@ if $@;
}

sub reverse{
    __PACKAGE__->new([ reverse @{$_[0]} ]);
}

sub splice {
    my $self = CORE::shift;
    my @ret =
        @_ == 0 ? CORE::splice @$self
      : @_ == 1 ? CORE::splice @$self, $_[0]
      : @_ == 2 ? CORE::splice @$self, $_[0], $_[1]
      : CORE::splice @$self, $_[0], $_[1], 
	  map { Class::Builtin->new($_) } CORE::splice @_, 2;
    __PACKAGE__->new( [@ret] );
}

sub spliced{
    my $clone = CORE::shift->clone;
    $clone->splice(@_);
    $clone;
}

for my $passive (qw/shift pop unshift push/) {
    eval qq{
      sub Class::Array::${passive}ed
      {
        my \$self = CORE::shift;
        \$self->clone->$passive(\@_);
      }
    };
    die $@ if $@;
}

sub delete {
    my $self = shift;
    my @deleted = CORE::delete @{$self}[@_];
    Class::Array->new([@deleted]);
}

sub concat {
    my $self = shift;
    my $ary  = shift;
    push @$self, @$ary;
    $self;
}

sub ref    { Class::Scalar->new(CORE::ref $_[0]) }
sub length { Class::Scalar->new(CORE::scalar @{$_[0]}) }

sub sort {
    my $self   = CORE::shift;
    my $block  = CORE::shift;
    my @sorted = $block
      ? do {
        my $pkg = caller; # ugly but works
	eval qq{ package $pkg; CORE::sort(\$block \@\$self) };
      }
      : CORE::sort(@$self);
    __PACKAGE__->new( [@sorted] );
}

sub grep {
    my $self = CORE::shift;
    my $block = CORE::shift or die;
    my @grepped;
    if ( CORE::ref $block eq 'Regexp' ) {
        for (@$self) {
            $_ =~ $block or next;
            push @grepped, $_;
        }
    }
    else {
        for (@$self) {
            $block->($_) or next;

        }
    }
    __PACKAGE__->new( [@grepped] );
}

sub map {
   my $self   = CORE::shift;
   my $block  = CORE::shift or die;
   my @mapped;
   CORE::push @mapped, $block->($_) for (@$self);
   __PACKAGE__->new([ @mapped ]);
}

*each = \&map;

sub each_with_index{
   my $self   = CORE::shift;
   my $block  = CORE::shift or die;
   my @mapped;
   for my $i (0 .. $self->length - 1){
       CORE::push @mapped, $block->($self->[$i], Class::Scalar->new($i));
   }
   __PACKAGE__->new([ @mapped ]);
}

sub join{
    my $self = CORE::shift;
    my $sep  = CORE::shift || '';
    my $str  = CORE::join($sep, @$self);
    Class::Scalar->new($str);
}


sub methods{
    Class::Array->new([sort grep { defined &{$_} } keys %Class::Array::])
}

# List::Util related

for my $meth (qw(max maxstr min minstr sum)){
    eval qq{
      sub Class::Array::$meth
      {
	my \$ret  = List::Util::$meth(\@{\$_[0]});
	Class::Scalar->new(\$ret);
      }
    };
    die $@ if $@;
}

# They are reinvented. Sigh;

sub first {
    my $self  = CORE::shift;
    my $block = CORE::shift or die;
    for (@$self){
	return $_ if $block->($_);
    }
    return;
}

sub reduce {
    my $self  = CORE::shift;
    my $block = CORE::shift or die;
    my $reduced = $self->[0];
    my $pkg = caller;
    for (@$self[1..$self->length - 1]){
	no strict 'refs';
	${$pkg . '::a'} = $reduced;
	${$pkg . '::b'} = $_;
	$reduced = $block->();
    }
    return Class::Scalar->new($reduced);
}

sub shuffle {
   my $self   = CORE::shift;
   my @shuffled = List::Util::shuffle @$self;
   __PACKAGE__->new([@shuffled]);
}


1; # end of Class::Array

=head1 NAME

Class::Array - Array as an object

=head1 VERSION

$Id: Array.pm,v 0.1 2009/06/21 09:09:26 dankogai Exp dankogai $

=head1 SYNOPSIS

  use Class::Array;                    # use Class::Builtin;
  my $foo = Class::Array->new([0..9]); # OO([0..9]);
  print $foo->length; # 10

=head1 EXPORT

None.  But see L<Class::Builtin>

=head1 METHODS

This section is under construction. For the time being, try

  print Class::Array->new([])->methods->join("\n")

=head1 TODO

This section itself is to do :)

=over 2

=item * more methods

=back

=head1 SEE ALSO

L<Class::Builtin>, L<Class::Scalar>, L<Class::Hash>

=head1 AUTHOR

Dan Kogai, C<< <dankogai at dan.co.jp> >>

=head1 ACKNOWLEDGEMENTS

L<autobox>, L<overload>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Dan Kogai, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
