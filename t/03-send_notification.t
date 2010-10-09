#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Deep;
use Protocol::Notifo;

my $n;
lives_ok
  sub { $n = Protocol::Notifo->new(user => 'me', api_key => 'my_key') },
  'new() survived with a prodigal object';
ok(defined($n), '... which, by the way, looks defined');

my %common = (
  headers => {Authorization => "Basic bWU6bXlfa2V5"},
  method  => "POST",
  url     => "https://api.notifo.com/v1/send_notification",
);


### send_notification
my @test_cases = (
  ['just msg',           [msg => 'hello']],
  ['msg and to',         [msg => 'hello', to => 'to']],
  ['msg, to, and label', [msg => 'hello', to => 'to', label => 'l']],
  [ 'msg, to, label, and title',
    [msg => 'hello', to => 'to', label => 'l', title => 't']
  ],
  [ 'all arguments',
    [msg => 'hello', to => 'to', label => 'l', title => 't', uri => 'u']
  ],
  ['undef arg', [msg => 'hello', to => undef], [msg => 'hello']],
);

my $sn;
for my $tc (@test_cases) {
  my ($name, $in, $out) = @$tc;
  $out = $in unless $out;

  lives_ok sub { $sn = $n->send_notification(@$in) },
    "send_notification() survived ($name)";
  cmp_deeply($sn, {%common, args => {@$out}}, '... with the expected result');
}


### bad boys
throws_ok sub { $n->send_notification() }, qr//, "Missing 'msg' parameter";


### thats all folks
done_testing();
