package Mojo::PgX::Cursor;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";



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
<recommends|https://metacpan.org/pod/DBD::Pg#Cursors> using a
<cursor|http://www.postgresql.org/docs/current/static/plpgsql-cursors.html> but
with that comes a few complications:

1. Cursors must be named.
2. Cursors are a resource that should be managed.
3. Cursors require a double loop to iterate through all rows.

=head1 REFERENCES

* L<#93266 for DBD-Pg: DBD::Pg to set the fetch size|https://rt.cpan.org/Public/Bug/Display.html?id=93266>
* L<#19488 for DBD-Pg: Support of cursor concept|https://rt.cpan.org/Public/Bug/Display.html?id=19488>

=head1 LICENSE

Copyright (C) Nathaniel Nutter.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Nathaniel Nutter C<nnutter@cpan.org>

=head1 SEE ALSO

L<DBD::Pg>, L<Mojo::Pg>

=cut

