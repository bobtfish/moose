use strict;
use warnings;

BEGIN {
    package My::Application::Trait;
    use Moose::Role;
}

BEGIN {
    package My::Trait;
    use Moose::Role;

    around '_application_hook' => sub {
        my $orig = shift;
        my $self = shift;
        my $to_apply = $self->$orig(@_);
        My::Application::Trait->meta->apply($to_apply);
        return $to_apply;
    };
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

