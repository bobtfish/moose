#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 16;
use Test::Exception;
use Test::Moose;

BEGIN {
    use_ok('Moose');
}

{
    package My::Attribute::Trait;
    use Moose::Role;

    has 'alias_to' => (is => 'ro', isa => 'Str');

    has foo => ( is => "ro", default => "blah" );

    after 'install_accessors' => sub {
        my $self = shift;
        $self->associated_class->add_method(
            $self->alias_to,
            $self->get_read_method_ref
        );
    };

    package Moose::Meta::Attribute::Custom::Trait::Aliased;
    sub register_implementation { 'My::Attribute::Trait' }
}

{
    package My::Other::Attribute::Trait;
    use Moose::Role;

    my $method = sub {
        42;
    };

    has bar => ( isa => "Str", default => "oink" );

    after 'install_accessors' => sub {
        my $self = shift;
        $self->associated_class->add_method(
            'additional_method',
            $method
        );
    };

    package Moose::Meta::Attribute::Custom::Trait::Other;
    sub register_implementation { 'My::Other::Attribute::Trait' }
}

{
    package My::Class;
    use Moose;

    has 'bar' => (
        traits   => [qw/Aliased/],
        is       => 'ro',
        isa      => 'Int',
        alias_to => 'baz',
    );
}

{
    package My::Derived::Class;
    use Moose;

    extends 'My::Class';

    has '+bar' => (
        traits   => [qw/Other/],
    );
}

my $c = My::Class->new(bar => 100);
isa_ok($c, 'My::Class');

is($c->bar, 100, '... got the right value for bar');

can_ok($c, 'baz') and
is($c->baz, 100, '... got the right value for baz');

my $bar_attr = $c->meta->get_attribute('bar');
does_ok($bar_attr, 'My::Attribute::Trait');
is($bar_attr->foo, "blah", "attr initialized");

my $quux = My::Derived::Class->new(bar => 1000);

is($quux->bar, 1000, '... got the right value for bar');

can_ok($quux, 'baz');
is($quux->baz, 1000, '... got the right value for baz');

my $derived_bar_attr = $quux->meta->get_attribute("bar");
does_ok($derived_bar_attr, 'My::Attribute::Trait' );

is( $derived_bar_attr->foo, "blah", "attr initialized" );

TODO: {
    local $TODO = 'traits in clone_and_inherit dont work yet';
    does_ok($derived_bar_attr, 'My::Other::Attribute::Trait' );

    is( eval { $derived_bar_attr->bar }, "oink", "attr initialized" );

    can_ok($quux, 'additional_method');
    is(eval { $quux->additional_method }, 42, '... got the right value for additional_method');
}
