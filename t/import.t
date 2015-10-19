use Mojo::Base -strict;

use Test::More;

plan skip_all => 'set TEST_ONLINE to enable this test' unless $ENV{TEST_ONLINE};

use Mojo::PgX::Cursor 'monkey_patch';

my $pg = Mojo::Pg->new($ENV{TEST_ONLINE});
my $db = $pg->db;
$db->query('drop table if exists import_test');
$db->query(
  'create table if not exists import_test (
     id   serial primary key,
     name text
  )'
);
$db->query('insert into import_test (name) values (?)', $_) for qw(foo bar);

ok !!Mojo::Pg->can('cursor'), 'Mojo::Pg can cursor';

{
  my $results = $pg->cursor('select name from import_test');
  my @names;
  while (my $row = $results->hash) {
    ok $results->rows, 'got rows';
    push @names, $row->{name};
  }
  is_deeply [sort @names], [sort qw(foo bar)], 'got both names';
}

done_testing();

