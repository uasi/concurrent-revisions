package ConcurrentRev::Versioned::Scalar;
use strict;
use warnings;
use parent qw(ConcurrentRev::Versioned Tie::Scalar);

sub TIESCALAR {
    my ($class, $merger) = @_;
    my $self = $class->new;
    $self->merger($merger) if $merger;
    $self;
}

sub FETCH {
    my ($self) = @_;
    $self->value;
}

sub STORE {
    my ($self, $value) = @_;
    $self->value($value);
}

1;

__END__
