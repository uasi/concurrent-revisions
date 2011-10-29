use strict;
use warnings;
use ConcurrentRev qw(:all);
use Test::More tests => 8;
use Test::Fatal qw(dies_ok lives_ok);

{
    versioned my $v;
    isa_ok tied($v), 'ConcurrentRev::Versioned::Scalar';
}

{
    versioned my $v;
    $v = 'root';
    is $v, 'root', '';

    my $r = rfork {
        is $v, 'root', '';

        $v = 'fork';
        is $v, 'fork', '';
    };

    is $v, 'root', '';

    $v = 'main';
    is $v, 'main', '';

    rjoin $r;
    is $v, 'fork', '';
}

{
    versioned my $v, sub { $_[2] };
    $v = 'root';
    my $r = rfork { $v = 'fork' };
    $v = 'main';

    rjoin $r;
    is $v, 'root', '';
}
