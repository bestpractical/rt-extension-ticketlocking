#!/usr/bin/perl

use strict;
use warnings;


use lib qw(/opt/rt3/local/lib /opt/rt3/lib);

use Test::More qw/no_plan/;

use HTTP::Cookies;

require "t/test_suite.pl";

my $agent = default_agent();

my $root = new RT::Test::Web;
$root->cookie_jar( HTTP::Cookies->new );
$root->login('root', 'password');

my $SUBJECT = "foo " . rand;

my $id = create_ticket($agent, 'General', {Subject => $SUBJECT});
my $ticket = RT::Ticket->new(RT::SystemUser());
$ticket->Load($id);

$agent->follow_link_ok({text => 'Lock', n => '1'}, "Followed Lock link for Ticket #$id");
$agent->content_like(qr{<div class="locked-by-you">\s*You have locked this ticket\.}ims, "Added a hard lock on Ticket $id");
my $lock = $ticket->Locked();
ok(($lock->Content->{'Type'} eq 'Hard'), "Lock is a Hard lock");
