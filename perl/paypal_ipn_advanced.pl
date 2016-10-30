#!/usr/bin/perl
BEGIN {
$| = 1; # Flush
use strict;
use warnings;
# Catch fatal errors and die with 200 OK plain/text header
# This is done because IPN will keep sending up to 16 requests
# till the right header is posted.
$SIG{__DIE__} = \&print_header;
}
#my $Just_Exit = 0; # if you need it

# Lots of servers will not resolve the IP to a host name
# So variable $ENV{'REMOTE_HOST'} will not have a value.
# If you want any security check if it is a PayPal IP.
#die('Does not match PayPal at IP:'.$ENV{'REMOTE_ADDR'})
# if ($ENV{'REMOTE_ADDR'} ne '173.0.82.66');

# comment the one your not using
my $PP_server = 'ipnpb.sandbox.paypal.com'; # sandbox IP:173.0.82.66
#my $PP_server = 'ipnpb.paypal.com'; # production IP:173.0.88.40

# It is highly recommended that you use version 6 upwards of
# the UserAgent module since it provides for tighter server
# certificate validation
use LWP::UserAgent 6;

# read post from PayPal system and add 'cmd'
use CGI qw(:standard);
my $cgi = CGI->new();
my $query = 'cmd=_notify-validate&';
$query .= join('&', map { $_.'='.$cgi->param($_) } $cgi->param());

# post back to PayPal system to validate
my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 1,SSL_version => 'SSLv23:!TLSv12' });
my $req = HTTP::Request->new('POST', 'https://'.$PP_server.'/cgi-bin/webscr');
$req->content_type('application/x-www-form-urlencoded');
$req->header(Host => $PP_server);
$req->content($query);
my $res = $ua->request($req);

# make the variable hash
my %variable =
 map { split(m'='x, $_, 2) }
 grep { m'='x }
 split(m'&'x, $query);

if ($res->is_error) {
 # HTTP error
}
elsif ($res->content eq 'VERIFIED') {
 # check the $variable{'payment_status'}=Completed
 # check that $variable{'txn_id'} has not been previously processed
 # check that $variable{'receiver_email'} is your Primary PayPal email
 # check that payment_amount $variable{'mc_gross'}/payment_currency $variable{'mc_currency'} are correct
 # process payment
}
elsif ($res->content eq 'INVALID') {
 # log for manual investigation
}
else {
 # error
}
# end with header or will die with header
print_header('Good');

sub print_header {
my $error = shift || '';
# what you do here can die like logging. That can be detected with $Just_Exit
# so we know we have been here before and not to run the thing that died
# if ( $error ne 'Good' && ! $Just_Exit ) {
# $Just_Exit = 1;
# log($error);
# }
# error will be the die info with \n

# Static Header. Do not use CGI.pm for header, it can die.
print <<'HEADER';
Content-Type: text/plain

HEADER
exit(0);
}