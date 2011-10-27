use strict;
use warnings;
use ConcurrentRev;
use ConcurrentRev::Attribute;
use Test::More tests => 8;
use Test::Fatal qw(dies_ok lives_ok);

{
    lives_ok { my $v : Versioned = 'value'; } '';

    my $v : Versioned = 'value';
    isa_ok tied($v), 'ConcurrentRev::Versioned::Scalar';
}

{
    my $v : Versioned = 'root';
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
