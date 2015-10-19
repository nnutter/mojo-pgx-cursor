use Mojo::Base -strict;

use Test::More;

plan skip_all => 'set TEST_ONLINE to enable this test' unless $ENV{TEST_ONLINE};

require Mojo::Pg;
require Mojo::PgX::Cursor::Cursor;

my $pg = Mojo::Pg->new($ENV{TEST_ONLINE});
my $db = $pg->db;
$db->query('drop table if exists cursor_test');
$db->query(
  'create table if not exists cursor_test (
     id   serial primary key,
     name text
  )'
);
$db->query('insert into cursor_test (name) values (?)', $_) for qw(foo bar);

{
  my $cursor = Mojo::PgX::Cursor::Cursor->new(
    query => 'select name from cursor_test',
    db => $db,
  );
  my $results = $cursor->fetch(3);
  is $results->rows, 2, 'got 2 rows even though we tried to fetch 3';
  is_deeply $results->arrays->flatten->sort->to_array, [sort qw(foo bar)], 'got both names';
  $cursor->close;
  my $name = $cursor->name;
  eval { $db->query(qq(fetch all from "$name")) };
  like $@, qr/$name/, 'fetch from closed cursor failed';
}

{
  my $name;
  {
    my $cursor = Mojo::PgX::Cursor::Cursor->new(
      query => 'select name from cursor_test',
      db => $db,
    );
    $name = $cursor->name;
  }
  eval { $db->query(qq(fetch all from "$name")) };
  like $@, qr/$name/, 'fetch from destroyed cursor failed';
}

$db->query('drop table cursor_test');

done_testing();
