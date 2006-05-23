# Set::Partition.pm
#
# Copyright (c) 2006 David Landgren
# All rights reserved

package Set::Partition;
use strict;

use vars qw/$VERSION/;
$VERSION = '0.01';

=head1 NAME

Set::Partition - Enumerate all arrangements of a set in fixed subsets

=head1 VERSION

This document describes version 0.01 of Set::Partition,
released 2006-05-23.

=head1 SYNOPSIS

  use Set::Partition;

  my $s = Set::Partition->new(
    list      => [qw('a' .. 'e')],
    partition => [2, 3],
  );
  while (my $p = $s->next) {
    print join( ' ', map { "(@$_)" } @$p ), $/;
  }
  # produces
  (a b) (c d e)
  (a c) (b d e)
  (a d) (b c e)
  (a e) (b c d)
  (b c) (a d e)
  (b d) (a c e)
  (b e) (a c d)
  (c d) (a b e)
  (c e) (a b d)
  (d e) (a b c)

=head1 DESCRIPTION

C<Set::Partition> takes a list of elements (scalars or references
or whatever) and a list numbers that represent the sizes of the
partitions into which the list of elements should be arranged.

The resulting object can then be used as an iterator which returns
a reference to an array of lists, that represents the original list
arranged according to the given partitioning information. All
possible arrangements are returned, and the object returns C<undef>
when the entire combination space has been exhausted.

=head1 METHODS

=over 8

=item new

Creates a new C<Set::Partition> object. A set of key/value parameters
can be supplied to control the finer details of the object's
behaviour.

B<list>, the list of elements in the set.

B<partition>, the list of integers representing the size of the
partitions used to arrange the set. The sum should be equal to the
number of elements given by B<list>. If it less than the number of
elements, a dummy partition will be added to equalise the count.
This partition will be returned during iteration. If the sum is
greater than the number of elements, C<new()> will C<croak> with a
fatal error.

=cut

sub new {
    my $class = shift;
    my %args = @_;
    my $part = $args{partition} || [];
    my $list = $args{list}      || [];
    my $sum  = 0;
    $sum += $_ for @$part;
    if ($sum > @$list) {
        my $list_nr = @$list;
        require Carp;
        Carp::croak("sum of partitions ($sum) exceeds available elements ($list_nr)\n");
    }
    elsif ($sum < @$list) {
        push @$part, @$list - $sum;
    }

    bless {
        list => $args{list},
        part => $args{partition},
    },
    $class;
}

=item next

Returns the next arrangement of subsets, or C<undef> when all arrangements
have been enumerated.

=cut

sub next {
    my $self  = shift;
    my $list  = $self->{list};
    my $state = $self->{state};
    if ($state) {
        return unless $self->_bump();
    }
    else {
        my $s = 0;
        push @$state, ($s++) x $_ for @{$self->{part}};
        $state ||= [(0) x (@$list)] if $list; # if no partition was given
        $self->{state} = $state;
    }
    my $out;
    push @{$out->[$state->[$_]]}, $list->[$_] for 0..$#$list;
	return $out;
}

sub _bump {
    my $self = shift;
    my $in = $self->{state};
    my $off = $#$in-1;
    while ($off >= 0) {
        if ($in->[$off] < $in->[$off+1]) {
            if ($in->[1+$off] > 1+$in->[$off]) {
                # find smallest in [$off+1..$#$in] > $in->[$off];
                my $next = @$in;
                while (--$next) {
                    last if $in->[$next] > $in->[$off];
                }
                (@{$in}[$off, $next]) = (@{$in}[$next, $off]);
                @{$in}[$off+1..$#$in] = reverse @{$in}[$off+1..$#$in]
                    if $off+1 < $#$in;
            }
            else {
                # just have to flip the current and next
                (@{$in}[$off, $off+1]) = (@{$in}[$off+1, $off]);
                # but we have to sort, seems inescapable
                @{$in}[$off+1..$#$in] = sort {$a <=> $b} @{$in}[$off+1..$#$in]
                    if $off+1 < $#$in;
            }
            return 1;
        }
        --$off;
    }
    return 0;
}

=item reset

Resets the object, which causes it to enumerate the arrangements from the
beginning.

  $p->reset; # begin again

=cut

sub reset {
    my $self  = shift;
    delete $self->{state};
    return $self;
}

=back

=head1 DIAGNOSTICS

None.

=head1 NOTES

The order within a set is unimportant, thus, if

  (a b) (c d)

is produced, then the following arrangement will never be encountered:

  (a b) (d c)

On the other hand, the order of the sets is important, which means
that the following arrangement I<will> be encountered:

  (c d) (a b)

=head1 SEE ALSO

=over 8

=item L<perl>

General information about Perl.

=back

=head1 BUGS

Using a partition of length 0 is valid, although you get back an C<undef>,
rather than an empty array. This could be construed as a bug.

Please report all bugs at
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Set-Partition|rt.cpan.org>

Make sure you include the output from the following two commands:

  perl -MSet::Partition -le 'print Set::Partition::VERSION'
  perl -V

=head1 ACKNOWLEDGEMENTS

None.

=head1 AUTHOR

David Landgren, copyright (C) 2006. All rights reserved.

http://www.landgren.net/perl/

If you (find a) use this module, I'd love to hear about it. If you
want to be informed of updates, send me a note. You know my first
name, you know my domain. Can you guess my e-mail address?

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

'The Lusty Decadent Delights of Imperial Pompeii';
__END__
