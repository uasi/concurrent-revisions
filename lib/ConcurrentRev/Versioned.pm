package ConcurrentRev::Versioned;
use strict;
use warnings;
use ConcurrentRev::Revision;
use Mo qw(build);

has merger => ();
has versions => ();

sub BUILD {
    my ($self) = @_;
    $self->versions({});
    $self->merger(\&_default_merger);
}

sub prune {
    my ($self, $seg) = @_;
    delete $self->versions->{$seg->version};
}

sub collapse {
    my ($self, $main_rev, $parent_seg) = @_;

    unless (exists $self->versions->{$main_rev->current_seg->version}) {
        $self->_set($main_rev, $self->versions->{$parent_seg->version});
    }
    delete $self->versions->{$parent_seg->version};
}

sub merge {
    my ($self, $main_rev, $join_rev, $join_seg) = @_;

    my $seg = $join_rev->current_seg;
    until (exists $self->versions->{$seg->version}) {
        $seg = $seg->parent;
    }

    if ($seg == $join_seg) {
        my $merged = $self->merger->(
            $self->_get($main_rev),
            $self->_get($join_rev),
            $self->_get($join_rev->root_seg),
        );
        $self->_set($main_rev, $merged);
    }
}

sub value {
    my $self = shift;
    my $rev = $ConcurrentRev::Revision::current;
    @_ ? $self->_set($rev, @_) : $self->_get($rev);
}

sub _get {
    my ($self, $rev_or_seg) = @_;

    my $seg = $rev_or_seg->isa('ConcurrentRev::Revision')
            ? $rev_or_seg->current_seg
            : $rev_or_seg;
    until (exists $self->versions->{$seg->version}) {
        $seg = $seg->parent;
    }
    $self->versions->{$seg->version};
}

sub _set {
    my ($self, $rev_or_seg, $value) = @_;

    my $seg = $rev_or_seg->isa('ConcurrentRev::Revision')
            ? $rev_or_seg->current_seg
            : $rev_or_seg;
    unless (exists $self->versions->{$seg->version}) {
        push @{$seg->written}, $self;
    }
    $self->versions->{$seg->version} = $value;
}

sub _default_merger {
    my ($main, $fork, $root) = @_;
    $fork;
}

1;

__END__
