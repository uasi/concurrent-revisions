package ConcurrentRev::Revision;
use strict;
use warnings;
use Coro;
use Mo;
use Try::Tiny;

our $current;
has root_seg => ();
has current_seg => ();
has coro => ();

sub fork {
    my ($self, $subref, @subref_args) = @_;

    my $current_seg = $self->current_seg;
    my $rev = ConcurrentRev::Revision->new(
        root_seg    => $self->current_seg,
        current_seg => ConcurrentRev::Segment->new(parent => $current_seg),
    );
    $self->current_seg(ConcurrentRev::Segment->new(parent => $current_seg));

    my $coro = async {
        local $ConcurrentRev::Revision::current = $rev;
        $subref->(@subref_args);
    };
    $rev->coro($coro);

    $rev;
}

sub join {
    my ($self, $rev) = @_;

    try {
        $rev->coro->join;
        my $seg = $rev->current_seg;
        while ($seg != $rev->root_seg) {
            for my $versioned (@{$seg->written}) {
                $versioned->merge($self, $rev, $seg);
            }
            $seg = $seg->parent;
        }
    }
    finally {
        $rev->current_seg->collapse($self);
    };
}

1;

__END__
