package Mojo::PgX::Cursor::Results;

require Mojo::PgX::Cursor::Cursor;

use Mojo::Base -base;

has 'cursor';

sub array {
    my $self = shift->_fetch;
    $self->{remaining}--;
    return $self->{results}->array;
}

sub columns { shift->{results}->columns }

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

Mojo::PgX::Cursor::Results - ...

=head1 SYNOPSIS

=head1 DESCRIPTION

...

=head1 LICENSE

Copyright (C) Nathaniel Nutter.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Nathaniel Nutter C<nnutter@cpan.org>

=head1 SEE ALSO

L<Mojo::PgX::Cursor>, L<Mojo::PgX::Cursor::Cursor>

=cut

