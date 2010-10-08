#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Deep;
use Protocol::Notifo;

my $n = Protocol::Notifo->new(user => 'me', api_key => 'mini_me');

my @test_cases = (
  [ [ 401,
      '{ "status": "error", "response_code": 1100, "response_message": "An error occurred" }'
    ],
    { http_code        => 401,
      status           => "error",
      response_code    => 1100,
      response_message => "An error occurred"
    },
  ],
  [ [ 402,
      '{ "status": "error", "response_code": 1101, "response_message": "Invalid Credentials" }'
    ],
    { http_code        => 402,
      status           => "error",
      response_code    => 1101,
      response_message => "Invalid Credentials"
    },
  ],
  [ [ 200,
      '{ "status": "success", "response_code": 2201, "response_message": "OK" }'
    ],
    { http_code        => 200,
      status           => "success",
      response_code    => 2201,
      response_message => "OK"
    },
  ],
);

for my $tc (@test_cases) {
  my ($args, $expected) = @$tc;

  my $result;
  lives_ok sub { $result = $n->parse_response(@$args) },
    'Parsed response lived';
  cmp_deeply($result, $expected, '... data is as expected');
}

done_testing();

