package Mojo::PgX::Cursor::Results;

require Mojo::IOLoop;
require Mojo::PgX::Cursor::Cursor;

use Time::HiRes qw(time);

use Mojo::Base -base;

has [qw(seconds_blocked fetch)];

sub array {
  my $self = shift->_fetch;
  $self->{remaining}--;
  return $self->{results}->array;
}

sub columns { shift->{results}->columns }

sub cursor {
  my $self = shift;
  if (@_) {
    $self->{cursor} = shift;
    $self->{remaining} = 0;
    delete $self->{results};
    return $self;
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
  $self->{results}->expand;
  return $self;
}

sub new {
  my $self = shift->SUPER::new(
    fetch => 100,
    remaining => 0,
    @_
  );
  return $self->_fetch
}

sub _reload {
  my $self = shift;
  $self->{delay} = Mojo::IOLoop->delay(
    sub {
      my $delay = shift;
      $self->cursor->fetch($self->{fetch}, $delay->begin);
    },
    sub {
      my ($delay, $err, $results) = @_;
      $self->{next} = $results;
      $self->{next}->expand if ($self->{expand});
    },
  );
  return $self;
}

sub rows { shift->{results}->rows }

sub _fetch {
  my $self = shift;
  if (not $self->{delay} and not $self->{next}) {
    $self->_reload;
  }
  return $self if $self->{remaining};
  unless ($self->{next}) {
    my $start = time;
    $self->{delay}->wait;
    $self->{seconds_blocked} += time - $start;
    delete $self->{delay};
  }
  $self->{results} = delete $self->{next};
  $self->{remaining} = $self->{results}->rows;
  return $self;
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojo::PgX::Cursor::Results

=head1 SYNOPSIS

=head1 DESCRIPTION

L<Mojo::PgX::Cursor::Results> is a container for L<Mojo::PgX::Cursor> cursor
like L<Mojo::Pg::Results> is for statement handles.

=head1 ATTRIBUTES

=head2 cursor

    my $cursor = $results->cursor;
    $results = $results->cursor($cursor);

L<Mojo::PgX::Cursor::Cursor> results are fetched from.

=head2 fetch

    $results->fetch(10);

The quantity of rows to fetch in each batch of rows.  Smaller uses less memory.
Since the next batch is always pre-fetched up to twice this many rows will be
in memory at any given time.  Defaults to 100.

=head2 seconds_blocked

    my $time_wasted = $results->seconds_blocked;

The cumulative time the cursor has spent blocking upon running out of rows.

=head1 METHODS

=head2 array

    my $row = $results->array;

Return next row from L</"cursor"> as an array reference.  If necessary, the
next row will be fetched first.

=head2 columns

    my $columns = $results->columns;

Return column names as an array reference.

=head2 expand

    $results = $results->expand;

Decode C<json> and C<jsonb> fields automatically for all rows.

=head2 hash

    my $row = $results->hash;

Return next row from L</"cursor"> as a hash reference.  If necessary, the next
row will be fetched first.

=head2 new

    my $results = Mojo::PgX::Cursor::Results->new(cursor => $cursor);

Construct a new L<Mojo::PgX::Cursor::Results> object.

=head2 rows

    my $num = $results->rows;

Number of rows in current batch; not total.

=head1 LICENSE

Copyright (C) Nathaniel Nutter.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Nathaniel Nutter C<nnutter@cpan.org>

=head1 SEE ALSO

L<Mojo::PgX::Cursor>, L<Mojo::PgX::Cursor::Cursor>

=cut

