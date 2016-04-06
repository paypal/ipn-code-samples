#!/usr/bin/perl

use warnings;
use strict;

# It is highly recommended that you use version 6 upwards of 
# the UserAgent module since it provides for tighter server 
# certificate validation
use LWP::UserAgent 6;

my $query = "";

# read post from PayPal system and add 'cmd'
read (STDIN, $query, $ENV{'CONTENT_LENGTH'});
$query .= '&cmd=_notify-validate';

# post back to PayPal system to validate
my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 1 });
my $req = HTTP::Request->new('POST', 'https://www.paypal.com/cgi-bin/webscr');
$req->content_type('application/x-www-form-urlencoded');
$req->header(Host => 'www.paypal.com');
$req->content($query);
my $res = $ua->request($req);

my %variable;

# split posted variables into pairs
my @pairs = split(/&/, $query);
my $count = 0;
foreach my $pair (@pairs) {
 my ($name, $value) = split(/=/, $pair);
 $value =~ tr/+/ /;
 $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
 $variable{$name} = $value;
 $count++;
}

# assign posted variables to local variables
my $item_name = $variable{'item_name'};
my $item_number = $variable{'item_number'};
my $payment_status = $variable{'payment_status'};
my $payment_amount = $variable{'mc_gross'};
my $payment_currency = $variable{'mc_currency'};
my $txn_id = $variable{'txn_id'};
my $receiver_email = $variable{'receiver_email'};
my $payer_email = $variable{'payer_email'};


if ($res->is_error) {
 # HTTP error
}
elsif ($res->content eq 'VERIFIED') {
 # check the $payment_status=Completed
 # check that $txn_id has not been previously processed
 # check that $receiver_email is your Primary PayPal email
 # check that $payment_amount/$payment_currency are correct
 # process payment
}
elsif ($res->content eq 'INVALID') {
 # log for manual investigation
}
else {
 # error
}
print "content-type: text/plain\n\n";
