use strict;
use warnings;

BEGIN {
    package My::Trait;
    use Moose::Role;

    sub _application_hook {
        my ($self, $application) = @_;
        warn("FOO");
        return $application;
    }

    our $VERSION = eval '0.1';
}
BEGIN {
    package Custom::Role;
    use Moose::Role -traits => 'My::Trait';
}
BEGIN {
    package Standard::Role;
    use Moose::Role;
}
BEGIN {
    package My::Class;
    use Moose;

    with qw/
        Custom::Role
        Standard::Role
    /;
}

use Test::More tests => 1;

my $i = My::Class->new;
ok $i;

