[![Build Status](https://travis-ci.org/nnutter/mojo-pgx-cursor.svg?branch=master)](https://travis-ci.org/nnutter/mojo-pgx-cursor)
# NAME

Mojo::PgX::Cursor - Cursor Extension for Mojo::Pg

# SYNOPSIS

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

# DESCRIPTION

Mojo::PgX::Cursor is an extension for Mojo::Pg that abstract away the (modest)
complications of using a PostgreSQL cursor so that you can use a familiar
iterable interface.

PostgreSQL cursors are useful because the DBD::Pg driver has a long-standing
limitation that it fetches all results to the client as soon as the statement
is executed.  This makes, for example, iterating over a whole table very
memory-expensive.  To work around the issue DBD::Pg
[recommends](https://metacpan.org/pod/DBD::Pg#Cursors) using a
[cursor](http://www.postgresql.org/docs/current/static/plpgsql-cursors.html) but
with that comes a few complications:

- Cursors must be named.
- Cursors are a resource that should be managed.
- Cursors require a double loop to iterate through all rows.

# METHODS

## db

Overrides [Mojo::Pg](https://metacpan.org/pod/Mojo::Pg)'s implementation in order to subclass the resulting
[Mojo::Pg::Database](https://metacpan.org/pod/Mojo::Pg::Database) object into a [Mojo::PgX::Cursor::Database](https://metacpan.org/pod/Mojo::PgX::Cursor::Database).

# DISCUSSION

This whole thing would be irrelevant if [DBD::Pg](https://metacpan.org/pod/DBD::Pg) did not fetch all rows
during `execute` and since `libpq` supports that it would be much better to
implement that than to implement this.  However, I don't really know C and I'm
not really sure I want to spend time learning it over another language.

I'm not yet sure how to implement non-blocking.  I have to investigate whether
declaring a cursor is non-instant.  Also, using the
[Mojo::PgX::Cursor::Results](https://metacpan.org/pod/Mojo::PgX::Cursor::Results) iterator abstracts away the database calls so I
am not sure how non-blocking fits in there.  One idea I have had was to add
`map` function, a la [Mojo::Collection](https://metacpan.org/pod/Mojo::Collection).  I've never used the non-blocking
features of [Mojo::Pg](https://metacpan.org/pod/Mojo::Pg) yet so I don't have a good feel for it.

# CONTRIBUTING

If you would like to submit bug reports, feature requests, questions, etc. you
should create an issue on the <GitHub Issue
Tracker|https://github.com/nnutter/mojo-pgx-cursor/issues> for this module.

# REFERENCES

- [#93266 for DBD-Pg: DBD::Pg to set the fetch size](https://rt.cpan.org/Public/Bug/Display.html?id=93266)
- [#19488 for DBD-Pg: Support of cursor concept](https://rt.cpan.org/Public/Bug/Display.html?id=19488)

# LICENSE

Copyright (C) Nathaniel Nutter.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Nathaniel Nutter `nnutter@cpan.org`

# SEE ALSO

[DBD::Pg](https://metacpan.org/pod/DBD::Pg), [Mojo::Pg](https://metacpan.org/pod/Mojo::Pg)
