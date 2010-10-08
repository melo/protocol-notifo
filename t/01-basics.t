#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Protocol::Notifo;
use MIME::Base64 'decode_base64';

my $n;
lives_ok
  sub { $n = Protocol::Notifo->new(user => 'me', api_key => 'my_key') },
  'new() survived with a prodigal object';
ok(defined($n), '... which, by the way, looks defined');
isa_ok($n, 'Protocol::Notifo', '... and even of the proper type');

is($n->{user},    'me',     '... good user in there');
is($n->{api_key}, 'my_key', '... and a nice little API key');

is($n->{base_url}, 'https://api.notifo.com/v1',
  'The API endpoint is alright');
is(decode_base64($n->{auth_hdr}),
  'me:my_key', '... and the authorization header is perfect');


### Bad boys
throws_ok sub { Protocol::Notifo->new },
  qr/Missing required parameter 'user' to new[(][)], /,
  'new() with missing user, expected exception';
throws_ok sub { Protocol::Notifo->new(user => 'me') },
  qr/Missing required parameter 'api_key' to new[(][)], /,
  'new() with missing api_key, expected exception';

done_testing();
