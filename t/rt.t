#!/usr/bin/perl -w
use strict;

use Test::More qw/no_plan/;
use lib qw(/opt/rt3/local/lib /opt/rt3/lib);
use RT::Test;
my ($baseurl, $m) = RT::Test->started_ok;

diag "Create a ticket" if $ENV{'TEST_VERBOSE'};
{
    $m->form_number(3);
    $m->field('Subject', 'test ticket ' . rand);
    $m->content =~ qr{<select name="Queue">\s*<option.*?value="(\d+)">\s*General\s*</option>}ms;
    my $general = $1;
    diag("General queue: $general");
    $m->field('Queue', '$general') if $general;
    $m->click_button(value => 'Create');
    $m->content =~ qr{<li>Ticket (\d+) created in queue .+</li>};
    my $id = $1;
    diag("ID: $id");
    SKIP: {
        skip 'No ticket created', 2 unless $id;
        
        $url .= "/Ticket/Display.html?id=$id";
        $m->get_ok($url, "Went to ticket display page for ticket $id");
        open OF, ">/home/toth/test_html/result_content.html" or die;
        print OF $m->content;
        $m->follow_link_ok({text => 'Lock', n => '1'}, "Followed Lock link");    
    }
}
