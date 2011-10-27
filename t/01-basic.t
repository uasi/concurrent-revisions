use strict;
use warnings;
use ConcurrentRev;
use Test::More tests => 21;
use Test::Fatal qw(dies_ok lives_ok);

{
    ok my $v = ConcurrentRev::Versioned->new, 'create a new versioned object';
    ok $v->value('main'), 'set value';
    is $v->value('main'), 'main', 'get value';
}

{
    my $r;
    lives_ok { $r = rfork {}; } 'rfork with empty body';
    isa_ok $r, 'ConcurrentRev::Revision', 'return value of rfork';
    lives_ok { rjoin $r; } 'rjoin a revision';
}

{
    my $v = ConcurrentRev::Versioned->new;
    $v->value('main');

    is $v->value, 'main', 'precondition';

    my $r = rfork {
        is $v->value, 'main', 'precondition in a fork';
        $v->value('fork');
        is $v->value, 'fork', 'postcondition in a fork';
    };

    is $v->value, 'main', 'postcondition';

    $v->value('new-main');
    is $v->value, 'new-main', 'modify value';

    rjoin $r;
    is $v->value, 'fork', 'modification is overwritten by the fork';
}

# Fork in a fork
{
    my $v = ConcurrentRev::Versioned->new;
    $v->value('main');

    my ($outer, $inner);
    $outer = rfork {
        $v->value('outer-fork');
        $inner = rfork {
            $v->value('inner-fork');
        };

        is $v->value, 'outer-fork', '';

        rjoin $inner;
        is $v->value, 'inner-fork', '';
    };

    is $v->value, 'main', '';

    rjoin $outer;
    is $v->value, 'inner-fork', '';
}

# Join inner fork afer joining outer fork
{
    my $v = ConcurrentRev::Versioned->new;
    $v->value('main');

    my ($outer, $inner);
    $outer = rfork {
        $v->value('outer-fork');
        $inner = rfork {
            $v->value('inner-fork');
        };
    };

    is $v->value, 'main', '';

    rjoin $outer;
    is $v->value, 'outer-fork', '';

    rjoin $inner;
    is $v->value, 'inner-fork', '';
}

# Join inner fork before joining outer fork
{
    my $v = ConcurrentRev::Versioned->new;
    $v->value('main');

    my ($outer, $inner);
    $outer = rfork {
        $v->value('outer-fork');
        $inner = rfork {
            $v->value('inner-fork');
        };
    };

    is $v->value, 'main', '';

    TODO: {
        todo_skip 'wrong rjoin does not die immediately but cause a nasty error later', 1;
        dies_ok { rjoin $inner; } 'cannot join inner fork before joining outer fork';
    }
}
