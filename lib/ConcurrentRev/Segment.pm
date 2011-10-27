package ConcurrentRev::Segment;
use strict;
use warnings;
use Devel::GlobalDestruction;
use Devel::Refcount qw(refcount);
use Mo qw(build);

our $latest_version = 0;
has parent => ();
has written => ();
has version => ();

sub BUILD {
    my ($self) = @_;
    $self->written([]);
    $self->version($latest_version++);
}

sub DESTROY {
    my ($self) = @_;
    return if in_global_destruction();
    $_->prune($self) for @{$self->written};
}

sub collapse {
    my ($self, $main_rev) = @_;
    while ($self->parent != $main_rev->root_seg && refcount($self->parent) == 1) {
        $_->collapse($main_rev, $self->parent) for @{$self->written};
    }
    $self->parent($self->parent->parent);
}

1;

__END__
