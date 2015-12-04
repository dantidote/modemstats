#!/usr/bin/perl

use LWP::UserAgent;
use Data::Dumper;
use JSON;

$modem = "http://192.168.100.1:8080";
$nonce = int(rand(99999));
$login = "$modem/login?arg=YWRtaW46cGFzc3dvcmQ=&_n=$nonce&_=" . time;
$channel_info = "$modem/walk?oid=1.3.6.1.2.1.10.127.1.1;&_n=$nonce&_=" . time;
$data_usage = "$modem/walk?oid=1.3.6.1.2.1.2.2.1;&_n=$nonce&_=" . time;

#$date = `date +"%D %T"`;
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$mon += 1;
$year += 1900;
$date = "$mon/$mday/$year $hour:$min:$sec";

chomp $date;

my $ua = LWP::UserAgent->new;
my $res = $ua->get($login);
$cookie_jar = $ua->cookie_jar( {} );
my $token = "credential=" . $res->{_content};

$ua->default_header('Cookie' => $token);

$res = $ua->get($channel_info);
$content = $res->{_content};
$objs = from_json($content);

$res = $ua->get($data_usage);
$content = $res->{_content};
$data = from_json($content);



@channels = (3,4,48..70,82,83);

foreach $channel (@channels){
  $dcid = "1.3.6.1.2.1.10.127.1.1.1.1.1.$channel";
  $power = "1.3.6.1.2.1.10.127.1.1.1.1.6.$channel";
  $snr = "1.3.6.1.2.1.10.127.1.1.4.1.5.$channel";
  $corrected = "1.3.6.1.2.1.10.127.1.1.4.1.9.$channel";
  $uncorrectable = "1.3.6.1.2.1.10.127.1.1.4.1.10.$channel";
  $downstream = "1.3.6.1.2.1.2.2.1.10.$channel";
  $upstream = "1.3.6.1.2.1.2.2.1.16.$channel";

  $$objs{$power} /= 10;
  $$objs{$snr} /= 10 ; 
  $$objs{$corrected} =~ /:(\d+)/;
  $$objs{$corrected} = $1;
  $$objs{$uncorrectable} =~ /:(\d+)/;
  $$objs{$uncorrectable} = $1;
  $ds = $$data{$downstream};
  $us = $$data{$upstream};
   

  print "$date,$channel,$$objs{$power},$$objs{$snr},$$objs{$corrected},$$objs{$uncorrectable},$ds,$us\n";
}
