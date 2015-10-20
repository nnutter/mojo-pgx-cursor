package Mojo::PgX::Cursor::Database;

require Mojo::PgX::Cursor::Cursor;
require Mojo::PgX::Cursor::Results;

use Mojo::Base 'Mojo::Pg::Database';

sub cursor {
  my ($self, $query, @bind) = (shift, shift, @_);
  my $cursor = Mojo::PgX::Cursor::Cursor->new(
    query => $query,
    db    => $self,
    bind  => \@bind,
  );
  return Mojo::PgX::Cursor::Results->new(cursor => $cursor);
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojo::PgX::Cursor::Database

=head1 METHODS

=head2 cursor

    my $results = $db->cursor('select * from foo');
    my $results = $db->cursor('select * from foo where id >= (?)', 10);

Execute a blocking statement and return an L<Mojo::PgX::Cursor::Results> object
to iterate over the results.  Unlike L<Mojo::Pg::Results> results are fetched
in batches rather than all at once but this is handled automatically by the
L<Mojo::PgX::Cursor::Results> object.  Be aware that this makes the object
behave somewhat differently.

L<Mojo::PgX::Cursor::Results> does not support C<hashes> or C<arrays> since if
you wish to use those you should just use C<query> instead.  C<rows> returns
the number of rows in the batch not the total rows for the query.

L<Mojo::PgX::Cursor::Results> should behave like L<Mojo::Pg::Results> for
C<array>, C<columns>, C<hash>, and C<expand>.

=cut
