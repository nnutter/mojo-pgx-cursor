package Mojo::PgX::Cursor::Cursor;

use UUID::Tiny ':std';
use namespace::clean;

use Mojo::Base -base;

has [qw(bind db name query)];

sub DESTROY {
  my $self = shift;
  if ($self->{close} && $self->db->dbh) { $self->close }
}

sub close {
  my $self = shift;
  my $query = sprintf('close "%s"', $self->name);
  $self->db->query($query) if delete $self->{close};
}

sub fetch {
  my ($self, $fetch) = (shift, (shift || 1));
  my $query = sprintf('fetch %s from "%s"', $fetch, $self->name);
  return $self->db->query($query);
}

sub new {
  my $self = shift->SUPER::new(
      bind => [],
      name => create_uuid_as_string(UUID_V4),
      @_,
  );
  return unless defined $self->db
            and defined $self->query and length $self->query;
  my $query = sprintf('declare "%s" cursor with hold for %s', $self->name, $self->query);
  $self->db->query($query, @{$self->bind});
  $self->{close} = 1;
  return $self;
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojo::PgX::Cursor::Cursor - ...

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

L<Mojo::PgX::Cursor>, L<Mojo::PgX::Cursor::Results>

=cut

