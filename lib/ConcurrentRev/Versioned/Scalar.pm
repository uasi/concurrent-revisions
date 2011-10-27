package ConcurrentRev::Versioned::Scalar;
use strict;
use warnings;
use parent qw(ConcurrentRev::Versioned Tie::Scalar);

sub TIESCALAR { shift->new }
sub FETCH     { shift->value }
sub STORE     { shift->value(@_) }

1;

__END__
