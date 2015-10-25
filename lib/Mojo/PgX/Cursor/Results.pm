package Mojo::PgX::Cursor::Results;

require Mojo::IOLoop;
require Mojo::PgX::Cursor::Cursor;

use Time::HiRes qw(time);

use Mojo::Base -base;

has [qw(seconds_blocked fetch_count)];

sub array {
  my $self = shift->_fetch;
  $self->{remaining}--;
  return $self->{results}->array;
}

sub columns { shift->_results->columns }

sub cursor {
  my $self = shift;
  if (@_) {
    if ($self->{delay}) {
        $self->{delay}->wait;
    }
    $self->{cursor} = shift;
    $self->{remaining} = 0;
    delete $self->{delay};
    delete $self->{next};
    delete $self->{results};
    return $self->_load_next;
  }
  return $self->{cursor};
}

sub hash {
  my $self = shift->_fetch;
  $self->{remaining}--;
  return $self->{results}->hash;
}

sub expand {
  my $self = shift;
  $self->{expand}++;
  if ($self->{results}) {
      $self->{results}->expand;
  }
  return $self;
}

sub new {
  my $self = shift->SUPER::new(@_);
  return $self->_load_next;
}

sub rows { shift->_results->rows }

sub _fetch {
  my $self = shift;
  return $self if $self->{remaining};
  unless ($self->{next}) {
    my $start = time;
    $self->{delay}->wait;
    $self->{seconds_blocked} += time - $start;
    delete $self->{delay};
  }
  $self->{results} = delete $self->{next};
  $self->{remaining} = $self->{results}->rows;
  return $self->_load_next;
}

sub _load_next {
  my $self = shift;
  $self->{delay} = Mojo::IOLoop->delay(
    sub {
      $self->cursor->fetch($self->{fetch_count}, shift->begin);
    },
    sub {
      $self->{next} = $_[2];
      $self->{next}->expand if ($self->{expand});
    },
  );
  return $self;
}

sub _results {
    my $self = shift;
    return $self->{results} if $self->{results};
    return $self->_fetch->{results};
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojo::PgX::Cursor::Results

=head1 DESCRIPTION

L<Mojo::PgX::Cursor::Results> is a container for a L<Mojo::PgX::Cursor::Cursor>
like L<Mojo::Pg::Results> is for a statement handle.  Therefore it tries to
mimic the API of L<Mojo::Pg::Results> whereever it makes sense to do do.

This container should behave like L<Mojo::Pg::Results> for C<array>,
C<columns>, C<hash>, and C<expand>.  It intentionally does not support
C<hashes> or C<arrays> since if you wish to use those you should just use
C<query> instead.  One difference in behavior is C<rows> returns the number of
rows in the current iteration not the total rows for the query.

=head1 ATTRIBUTES

=head2 cursor

    my $cursor = $results->cursor;
    $results = $results->cursor($cursor);

The L<Mojo::PgX::Cursor::Cursor> rows are fetched from.

=head2 fetch_count

    $results->fetch_count(10);

The quantity of rows to fetch in each iteration.  Since the next iteration is
always pre-fetched up to twice this many rows will be in memory at any given
time.  Set this to optimize for time or memory in your
specific use case.

Defaults to 100.

=head2 seconds_blocked

    my $time_wasted = $results->seconds_blocked;

The cumulative time the cursor has spent waiting for rows.

=head1 METHODS

=head2 array

    my $row = $results->array;

Return next row from L</"cursor"> as an array reference.

=head2 columns

    my $columns = $results->columns;

Return column names as an array reference.

=head2 expand

    $results = $results->expand;

Decode C<json> and C<jsonb> fields automatically for all rows.

=head2 hash

    my $row = $results->hash;

Return next row from L</"cursor"> as a hash reference.

=head2 new

    my $results = Mojo::PgX::Cursor::Results->new(cursor => $cursor);

Construct a new L<Mojo::PgX::Cursor::Results> object.

=head2 rows

    my $num = $results->rows;

Number of rows in current iteration; not the total for the original query.

=head1 LICENSE

Copyright (C) Nathaniel Nutter.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Nathaniel Nutter C<nnutter@cpan.org>

=head1 SEE ALSO

L<Mojo::PgX::Cursor>, L<Mojo::PgX::Cursor::Cursor>, L<Mojo::PgX::Cursor::Database>

=cut

