package Protocol::Notifo;

# ABSTRACT: utilities to build the requests for the notifo.com service

use strict;
use warnings;
use Carp 'confess';
use JSON 'decode_json';
use MIME::Base64 'encode_base64';
use namespace::clean;

sub new {
  my ($class, %args) = @_;
  my $self = bless {}, $class;

  for my $f (qw( user api_key )) {
    confess("Missing required parameter '$f' to new(), ") unless $args{$f};
    $self->{$f} = $args{$f};
  }

  $self->{base_url} = 'https://api.notifo.com/v1';
  $self->{auth_hdr} = encode_base64(join(':', @$self{qw(user api_key)}));

  return $self;
}


1;
