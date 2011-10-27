package ConcurrentRev::Attribute;
use strict;
use warnings;
use Attribute::Handlers autotie => {
    '__CALLER__::Versioned' => 'ConcurrentRev::Versioned::Scalar'
};

1;

__END__
