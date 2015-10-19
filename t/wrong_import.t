use Mojo::Base -strict;

use Test::More;

plan skip_all => 'set TEST_ONLINE to enable this test' unless $ENV{TEST_ONLINE};

use Mojo::PgX::Cursor 'something';

ok !Mojo::Pg->can('cursor'), 'Mojo::Pg can cursor';

done_testing();

