package Mojo::PgX::Cursor;

require Mojo::PgX::Cursor::Database;

use Mojo::Base 'Mojo::Pg';
use Mojo::Util 'monkey_patch';

our $VERSION = "0.01";

sub import {
  my $class = shift;
  if (defined $_[0] and $_[0] eq 'monkey_patch') {
    monkey_patch 'Mojo::Pg::Database', 'cursor', \&Mojo::PgX::Cursor::Database::cursor;
  }
}

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

    # using subclass
    require Mojo::PgX::Cursor;
    my $pg = Mojo::PgX::Cursor->new(...);
    my $results = $pg->db->cursor('select * from some_table');
    while (my $row = $results->hash) {
      ...
    }

    # using monkey patch
    use Mojo::PgX::Cursor 'monkey_patch';
    my $pg = Mojo::Pg->new(...);
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

=head1 DISCUSSION

This whole thing would be irrelevant if L<DBD::Pg> did not fetch all rows
during C<execute> and since C<libpq> supports that it would be much better to
implement that than to implement this.  However, I don't really know C and I'm
not really sure I want to spend time learning it over another language.

I'm not yet sure how to implement non-blocking.  I have to investigate whether
declaring a cursor is non-instant.  Also, using the
L<Mojo::PgX::Cursor::Results> iterator abstracts away the database calls so I
am not sure how non-blocking fits in there.  One idea I have had was to add
C<map> function, a la L<Mojo::Collection>.  I've never used the non-blocking
features of L<Mojo::Pg> yet so I don't have a good feel for it.

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

