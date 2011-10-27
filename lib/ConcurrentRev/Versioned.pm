package ConcurrentRev::Versioned;
use strict;
use warnings;
use ConcurrentRev::Revision;
use Mo qw(build);

has versions => ();

sub BUILD {
    my ($self) = @_;
    $self->versions({});
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
        $self->_set($main_rev, $self->versions->{$join_seg->version});
    }
}

sub value {
    my $self = shift;
    my $rev = $ConcurrentRev::Revision::current;
    @_ ? $self->_set($rev, @_) : $self->_get($rev);
}

sub _get {
    my ($self, $rev) = @_;

    my $seg = $rev->current_seg;
    until (exists $self->versions->{$seg->version}) {
        $seg = $seg->parent;
    }
    $self->versions->{$seg->version};
}

sub _set {
    my ($self, $rev, $value) = @_;

    my $seg = $rev->current_seg;
    unless (exists $self->versions->{$seg->version}) {
        push @{$seg->written}, $self;
    }
    $self->versions->{$seg->version} = $value;
}

1;

__END__
