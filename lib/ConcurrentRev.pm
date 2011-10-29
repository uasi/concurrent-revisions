package ConcurrentRev;
our $VERSION = '0.01';
use 5.008;
use strict;
use warnings;
use parent 'Exporter';
use ConcurrentRev::Versioned;
use ConcurrentRev::Versioned::Scalar;
use ConcurrentRev::Segment;
use ConcurrentRev::Revision;

INIT {
    my $seg = ConcurrentRev::Segment->new(parent => undef);
    my $rev = ConcurrentRev::Revision->new(
        root_seg    => $seg,
        current_seg => $seg,
    );
    $ConcurrentRev::Revision::current = $rev;
}

our @EXPORT = qw(rfork rjoin);
our @EXPORT_OK = qw(versioned);
our %EXPORT_TAGS = (
    all => [@EXPORT, @EXPORT_OK]
);

sub rfork (&;@) {
    $ConcurrentRev::Revision::current->fork(@_);
}

sub rjoin ($) {
    $ConcurrentRev::Revision::current->join(@_);
}

sub versioned {
    tie $_[0], 'ConcurrentRev::Versioned::Scalar', ($_[1] || ());
}

1;

__END__

=head1 NAME

ConcurrentRev - an implementation of Concurrent Revisions

=begin readme

=head1 INSTALLATION

To install this module, run the following commands:

    perl Makefile.PL
    make
    make test
    make install

=end readme

=head1 SYNOPSIS

    use ConcurrentRev;

    my $var = ConcurrentRev::Versioned->new;
    $var->value('main');

    # Here $var->value eq 'main'

    my $fork = rfork {
        $var->value('fork');
    };

    # Still $var->value eq 'main'

    rjoin $fork;

    # Now $var->value eq 'fork'

or

    use ConcurrentRev qw(rfork rjoin versioned);

    versioned my $var;
    $var = 'main';

    my $fork = rfork {
        $var = 'fork';
    };

    rjoin $fork;

    say $var;

C<Coro::*> functions such as C<Coro::cede> can be used in the C<rfork> block.

=head1 DESCRIPTION

=head1 FUNCTIONS

=head2 rfork

=head2 rjoin

=head2 versioned

=head1 AUTHOR

Tomoki Aonuma E<lt>uasi@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

Revisions - A programming model for parallelizing conflicting tasks,
L<http://research.microsoft.com/en-us/projects/revisions/>
