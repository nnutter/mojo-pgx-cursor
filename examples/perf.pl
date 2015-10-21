use Mojo::Base -strict;

use Mojo::JSON qw(encode_json);

unless ($ENV{TEST_ONLINE}) {
  say STDERR 'set TEST_ONLINE to run this';
  exit 1;
}

require Mojo::PgX::Cursor;;

my $pg = Mojo::PgX::Cursor->new($ENV{TEST_ONLINE});
my $db = $pg->db;
my $results = eval { $db->query('select count(*) from perf_test') };
unless ($results) {
  $db->query(
    'create table if not exists perf_test (
    id   serial primary key,
    name text,
    jdoc jsonb
    )'
  );

  my $tx = $db->begin;
  my @rows = (
    ['foo', encode_json { value => $_ }],
    ['bar', encode_json { value => $_ }],
  );
  for (1..500_000) {
    for (@rows) {
      $tx->db->query('insert into perf_test (name, jdoc) values (?, ?)', $_->[0], $_->[1]);
    }
  }
  $tx->commit;
}

use Time::HiRes qw(nanosleep);
for (
  [10000, 5000],
  [100, 100],
  [10, 10],
  [1, 1],
) {
  my ($fetch, $reload_at) = @{$_};
  my $cursor = $db->cursor('select * from perf_test limit 100000');
  $cursor->fetch($fetch)->reload_at($reload_at);
  while (my $row = $cursor->hash) {
    nanosleep 10;
  }
  say sprintf 'Blocked for %f seconds with fetch = %d and reload_at = %d', $cursor->seconds_blocked, $cursor->fetch, $cursor->reload_at;
}
