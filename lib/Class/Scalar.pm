package Class::Scalar;
use 5.008001;
use warnings;
use strict;
our $VERSION = sprintf "%d.%02d", q$Revision: 0.1 $ =~ /(\d+)/g;

use Encode ();
use Scalar::Util ();

use overload (
    bool     => sub { !! ${ $_[0] } },
    '""'     => sub { ${ $_[0] } . '' },
    '0+'     => sub { ${ $_[0] } + 0  },
    '@{}'    => sub { $_[0]->split(qr//) },
    # unary ops
    (map { $_ => eval qq{sub {
       __PACKAGE__->new($_ \${\$_[0]});
      }
    } } qw{ ~ }),
    # binary numeric ops
    (map { $_ => eval qq{sub {
       my \$l = ref \$_[0] ? \${\$_[0]} : \$_[0];
       my \$r = ref \$_[1] ? \${\$_[1]} : \$_[1];
       # warn "\$l $_ \$r";
       __PACKAGE__->new(\$l $_ \$r);
      }
    } } qw{+ - * / % ** << >> & | ^ . x }),
    # comparison ops -- bools are not objects
    (map { $_ => eval qq{sub {
         my \$l = ref \$_[0] ? \${\$_[0]} : \$_[0];
         my \$r = ref \$_[1] ? \${\$_[1]} : \$_[1];
         \$l $_ \$r;
      }
    } } qw{ <=> cmp }),
    fallback => 1,
);

sub new {
    my ( $class, $scalar ) = @_;
    return $scalar if ref $scalar;
    bless \$scalar, $class;
}

sub clone{
    __PACKAGE__->new( ${$_[0]} );
}

my @unary = qw(
  print length defined ref
  chomp chop chr lc lcfirst ord reverse uc ucfirst
  cos sin exp log sqrt int
  hex oct
);

for my $meth (@unary) {
    eval qq{
    sub Class::Scalar::$meth
    {
	my \$self = shift;
	my \$ret  = CORE::$meth(\$\$self);
	__PACKAGE__->new(\$ret);
    }
    };
    die $@ if $@;
}

sub substr{
    my $self = shift;
    die unless @_ > 0;
    my $ret =
        @_ == 1 ? CORE::substr $$self, $_[0]
      : @_ == 2 ? CORE::substr $$self, $_[0], $_[1]
      : CORE::substr @$self, $_[0], $_[1], $_[2];
    return @_ > 2 ? $self : __PACKAGE__->new($ret);
}

sub split {
    my $self = shift;
    my $pat  = shift || qr//;
    my @ret  = CORE::split $pat, $$self;
    Class::Array->new( [@ret] );
}

sub methods{
    Class::Array->new( [sort grep { defined &{$_} }keys %Class::Scalar:: ] );
}


# Encode-related
for my $meth (qw/decode encode decode_utf8/){
    eval qq{
    sub Class::Scalar::$meth
    {
	my \$self = shift;
	my \$ret  = Encode::$meth(\$\$self,\@_);
	__PACKAGE__->new(\$ret);
    }
    };
    die $@ if $@;
}
for my $meth (qw/encode_utf8/){
    eval qq{
    sub Class::Scalar::$meth
    {
	my \$self = shift;
	my \$ret  = Encode::$meth(\$\$self);
	__PACKAGE__->new(\$ret);
    }
    };
    die $@ if $@;
}


# Scalar::Util
# dualvar() and  set_prototype() not included
our @scalar_util = qw(
  blessed isweak readonly refaddr reftype tainted
  weaken isvstring looks_like_number
);

for my $meth (qw/blessed isweak refaddr reftype weaken/){
    eval qq{
    sub Class::Scalar::$meth
    {
	my \$self = shift;
	my \$ret  = Scalar::Util::$meth(\$self);
	__PACKAGE__->new(\$ret);
    }
    };
    die $@ if $@;
}

for my $meth (qw/readonly tainted isvstring looks_like_number/){
    eval qq{
    sub Class::Scalar::$meth
    {
	my \$self = shift;
	my \$ret  = Scalar::Util::$meth(\$\$self);
	__PACKAGE__->new(\$ret);
    }
    };
    die $@ if $@;
}

1; # End of Class::Scalar

=head1 NAME

Class::Scalar - Scalar as an object

=head1 VERSION

$Id: Scalar.pm,v 0.1 2009/06/21 09:09:26 dankogai Exp dankogai $

=head1 SYNOPSIS

  use Class::Scalar;                    # use Class::Builtin;
  my $foo = Class::Scalar->new('perl'); # OO('perl');
  print $foo->length; # 4

=head1 EXPORT

None.  But see L<Class::Builtin>

=head1 METHODS

This section is under construction. For the time being, try

  print Class::Scalar->new(0)->methods->join("\n")

=head1 TODO

This section itself is to do :)

=over 2

=item * what should C<< $s->m(qr/.../) >> return ? SCALAR ? ARRAY ?

=item * more methods

=back

=head1 SEE ALSO

L<Class::Builtin>, L<Class::Array>, L<Class::Hash>

=head1 AUTHOR

Dan Kogai, C<< <dankogai at dan.co.jp> >>

=head1 ACKNOWLEDGEMENTS

L<autobox>, L<overload>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Dan Kogai, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
