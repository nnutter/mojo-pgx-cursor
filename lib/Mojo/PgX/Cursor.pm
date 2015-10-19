package Mojo::PgX::Cursor;

require Mojo::PgX::Cursor::Cursor;
require Mojo::PgX::Cursor::Results;

use Mojo::Base 'Mojo::Pg';
use Mojo::Util 'monkey_patch';

our $VERSION = "0.01";

sub import {
    my $class = shift;
    if (defined $_[0] and $_[0] eq 'monkey_patch') {
        monkey_patch 'Mojo::Pg', 'cursor', \&cursor;
    }
}

sub cursor {
    my ($pg, $query, @bind) = (shift, shift, @_);
    my $cursor = Mojo::PgX::Cursor::Cursor->new(
        query => $query,
        db => $pg->db,
        bind => \@bind,
    );
    return Mojo::PgX::Cursor::Results->new(cursor => $cursor);
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojo::PgX::Cursor - Cursor Extension for Mojo::Pg

=head1 SYNOPSIS

    require Mojo::PgX::Cursor;
    my $pg = Mojo::PgX::Cursor->new(...);
    my $results = $pg->cursor('select * from some_table');

    use Mojo::PgX::Cursor 'monkey_patch';
    my $pg = Mojo::Pg->new(...);
    my $results = $pg->cursor('select * from some_table');
    while (my $row = $results->hash) {
      ...
    }

=head1 DESCRIPTION

Mojo::PgX::Cursor is an extension for Mojo::Pg that abstract away the (modest)
complications of using a PostgreSQL cursor so that you can use a familiar
iterable interface.

PostgreSQL cursors are useful because the DBD::Pg driver has a long-standing
limitation that it fetches all results to the client as soon as the statement
is executed.  This makes, for example, iterating over a whole table very
memory-expensive.  To work around the issue DBD::Pg
L<recommends|https://metacpan.org/pod/DBD::Pg#Cursors> using a
L<cursor|http://www.postgresql.org/docs/current/static/plpgsql-cursors.html> but
with that comes a few complications:

=over

=item Cursors must be named.

=item Cursors are a resource that should be managed.

=item Cursors require a double loop to iterate through all rows.

=back

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

=head1 COMING SOON

=over

=item Better documentation.

=item Support for non-blocking statements.

=back

=head1 REFERENCES

=over

=item L<#93266 for DBD-Pg: DBD::Pg to set the fetch size|https://rt.cpan.org/Public/Bug/Display.html?id=93266>

=item L<#19488 for DBD-Pg: Support of cursor concept|https://rt.cpan.org/Public/Bug/Display.html?id=19488>

=back

=head1 LICENSE

Copyright (C) Nathaniel Nutter.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Nathaniel Nutter C<nnutter@cpan.org>

=head1 SEE ALSO

L<DBD::Pg>, L<Mojo::Pg>

=cut

