use Mojo::Base -strict;

use Test::More;

plan skip_all => 'set TEST_ONLINE to enable this test' unless $ENV{TEST_ONLINE};

require Mojo::Pg;
require Mojo::PgX::Cursor::Results;

my $pg = Mojo::Pg->new($ENV{TEST_ONLINE});
my $db = $pg->db;
$db->query('drop table if exists results_test');
$db->query(
  'create table if not exists results_test (
     id   serial primary key,
     name text
  )'
);
$db->query('insert into results_test (name) values (?)', $_) for qw(foo bar);

{
  my $cursor = Mojo::PgX::Cursor::Cursor->new(
    query => 'select name from results_test',
    db => $db,
  );
  my $results = Mojo::PgX::Cursor::Results->new(
    cursor => $cursor,
  );

  my @names;
  while (my $row = $results->array) {
    ok $results->rows, 'got rows';
    push @names, $row->[0];
  }
  is_deeply $results->columns, ['name'], 'got columns';
  is_deeply [sort @names], [sort qw(foo bar)], 'got both names';
}

{
  my $cursor = Mojo::PgX::Cursor::Cursor->new(
    query => 'select name from results_test',
    db => $db,
  );
  my $results = Mojo::PgX::Cursor::Results->new(
    cursor => $cursor,
  );

  my @names;
  while (my $row = $results->hash) {
    ok $results->rows, 'got rows';
    push @names, $row->{name};
  }
  is_deeply [sort @names], [sort qw(foo bar)], 'got both names';
}

done_testing();
