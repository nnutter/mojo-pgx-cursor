[![Build Status](https://travis-ci.org/nnutter/mojo-pgx-cursor.svg?branch=master)](https://travis-ci.org/nnutter/mojo-pgx-cursor)
# NAME

Mojo::PgX::Cursor - Cursor Extension for Mojo::Pg

# SYNOPSIS

    use Mojo::PgX::Cursor;

# DESCRIPTION

Mojo::PgX::Cursor is an extension for Mojo::Pg that abstract away the (modest)
complications of using a PostgreSQL cursor so that you can use a familiar
iterable interface.

PostgreSQL cursors are useful because the DBD::Pg driver has a long-standing
limitation that it fetches all results to the client as soon as the statement
is executed.  This makes, for example, iterating over a whole table very
memory-expensive.  To work around the issue DBD::Pg
&lt;recommends|https://metacpan.org/pod/DBD::Pg#Cursors> using a
&lt;cursor|http://www.postgresql.org/docs/current/static/plpgsql-cursors.html> but
with that comes a few complications:

1\. Cursors must be named.
2\. Cursors are a resource that should be managed.
3\. Cursors require a double loop to iterate through all rows.

# REFERENCES

\* [#93266 for DBD-Pg: DBD::Pg to set the fetch size](https://rt.cpan.org/Public/Bug/Display.html?id=93266)
\* [#19488 for DBD-Pg: Support of cursor concept](https://rt.cpan.org/Public/Bug/Display.html?id=19488)

# LICENSE

Copyright (C) Nathaniel Nutter.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Nathaniel Nutter `nnutter@cpan.org`

# SEE ALSO

[DBD::Pg](https://metacpan.org/pod/DBD::Pg), [Mojo::Pg](https://metacpan.org/pod/Mojo::Pg)
