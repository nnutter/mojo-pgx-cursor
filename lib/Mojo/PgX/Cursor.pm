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
    my ($pg, $query) = (shift, shift);
    my $cursor = Mojo::PgX::Cursor::Cursor->new(
        query => $query,
        db => $pg->db,
    );
    return Mojo::PgX::Cursor::Results->new(cursor => $cursor);
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojo::PgX::Cursor - Cursor Extension for Mojo::Pg

=head1 SYNOPSIS

    use Mojo::PgX::Cursor;

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

