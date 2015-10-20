package Mojo::PgX::Cursor::Results;

require Mojo::PgX::Cursor::Cursor;

use Mojo::Base -base;

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
    delete $self->{remaining};
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

sub new { shift->SUPER::new(@_)->_fetch }

sub rows { shift->{results}->rows }

sub _fetch {
  my $self = shift;
  unless ($self->{remaining}) {
    my $fetch_rows = 1;
    $self->{results} = $self->cursor->fetch($fetch_rows);
    $self->{results}->expand if ($self->{expand});
    $self->{remaining} = $self->{results}->rows;
  }
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

