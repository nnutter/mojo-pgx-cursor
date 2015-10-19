use Mojo::Base -strict;

use Test::More;

plan skip_all => 'set TEST_ONLINE to enable this test' unless $ENV{TEST_ONLINE};

require Mojo::PgX::Cursor;

my $pg = Mojo::PgX::Cursor->new($ENV{TEST_ONLINE});
my $db = $pg->db;
$db->query('drop table if exists subclass_test');
$db->query(
  'create table if not exists subclass_test (
     id   serial primary key,
     name text
  )'
);
$db->query('insert into subclass_test (name) values (?)', $_) for qw(foo bar);

ok !Mojo::Pg->can('cursor'), 'Mojo::Pg cannot cursor';

{
  my $results = $pg->cursor('select name from subclass_test');
  my @names;
  while (my $row = $results->hash) {
    ok $results->rows, 'got rows';
    push @names, $row->{name};
  }
  is_deeply [sort @names], [sort qw(foo bar)], 'got both names';
}

done_testing();