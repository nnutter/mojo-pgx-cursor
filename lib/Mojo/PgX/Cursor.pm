package Mojo::PgX::Cursor;

require Mojo::PgX::Cursor::Database;

use Mojo::Base 'Mojo::Pg';

our $VERSION = "0.01";

sub db {
    my $db = shift->SUPER::db(@_);
    return bless $db, 'Mojo::PgX::Cursor::Database';
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojo::PgX::Cursor - Cursor Extension for Mojo::Pg

=head1 SYNOPSIS

    require Mojo::PgX::Cursor;
    my $pg = Mojo::PgX::Cursor->new(...);
    my $results = $pg->db->cursor('select * from some_table');
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

=head2 db

Overrides L<Mojo::Pg>'s implementation in order to subclass the resulting
L<Mojo::Pg::Database> object into a L<Mojo::PgX::Cursor::Database>.

=head1 MONKEYPATCH

    require Mojo::Pg;
    require Mojo::PgX::Cursor;
    use Mojo::Util 'monkey_patch';
    monkey_patch 'Mojo::Pg::Database', 'cursor', \&Mojo::PgX::Cursor::Database::cursor;

Just because you can doesn't mean you should but if you want you can
C<monkey_patch> L<Mojo::Pg::Database> rather than swapping out your
construction of L<Mojo::Pg> objects with the L<Mojo::PgX::Cursor> subclass.

=head1 DISCUSSION

This whole thing would be irrelevant if L<DBD::Pg> did not fetch all rows
during C<execute> and since C<libpq> supports that it would be much better to
implement that than to implement this.  However, I don't really know C and I'm
not really sure I want to spend time learning it over another language.

=head1 CONTRIBUTING

If you would like to submit bug reports, feature requests, questions, etc. you
should create an issue on the <GitHub Issue
Tracker|https://github.com/nnutter/mojo-pgx-cursor/issues> for this module.

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

