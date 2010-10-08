package Protocol::Notifo;

# ABSTRACT: utilities to build the requests for the notifo.com service

use strict;
use warnings;
use Carp 'confess';
use JSON 'decode_json';
use MIME::Base64 'encode_base64';
use File::HomeDir;
use File::Spec::Functions qw( catfile );
use namespace::clean;

sub new {
  my ($class, %args) = @_;
  my $self = bless $class->_read_config_file, $class;

  for my $f (qw( user api_key )) {
    $self->{$f} = $args{$f} if exists $args{$f};
    confess("Missing required parameter '$f' to new(), ") unless $self->{$f};
  }

  $self->{base_url} = 'https://api.notifo.com/v1';
  $self->{auth_hdr} = encode_base64(join(':', @$self{qw(user api_key)}), '');

  return $self;
}

sub parse_response {
  my ($self, $http_code, $content) = @_;

  my $res = decode_json($content);
  $res->{http_code} = $http_code;

  return $res;
}

sub send_notification {
  my ($self, %args) = @_;

  my %call = (
    url     => "$self->{base_url}/send_notification",
    method  => 'POST',
    headers => {Authorization => $self->{auth_hdr}},
    args    => {},
  );

  for my $f (qw( to msg label title uri )) {
    my $v = $args{$f};
    next unless defined $v;

    $call{args}{$f} = $v;
  }

  confess("Missing required argument 'msg', ") unless $call{args}{msg};

  return \%call;
}

sub _read_config_file {
  my ($self) = @_;
  my %opts;

  my $fn = $ENV{NOTIFO_CFG} || catfile(File::HomeDir->my_home, '.notifo.rc');
  return \%opts unless -r $fn;

  open(my $fh, '<', $fn) || confess("Could not open file '$fn': $!, ");

  while (my $l = <$fh>) {
    chomp($l);
    $l =~ s/^\s*(#.*)?|\s*$//g;
    next unless $l;

    my ($k, $v) = $l =~ m/(\S+)\s*[=:]\s*(.*)/;
    confess("Could not parse line $. of $fn ('$l'), ") unless $k;

    $opts{$k} = $v;
  }

  return \%opts;
}

1;
