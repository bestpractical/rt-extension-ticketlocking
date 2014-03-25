#!/usr/bin/perl

use strict;
use warnings;

use HTTP::Cookies;
require RT::IR::Test::Web;

### after: use lib qw(@RT_LIB_PATH@);
use lib qw(/opt/rt4/local/lib /opt/rt4/lib);

my $RTIR_TEST_USER = "rtir_test_user";
my $RTIR_TEST_PASS = "rtir_test_pass";

sub default_agent {
    my $agent = new RT::Test::Web;
    $agent->cookie_jar( HTTP::Cookies->new );
    my $u = rtir_user();
    $agent->login($RTIR_TEST_USER, $RTIR_TEST_PASS);
    $agent->get_ok("/index.html", "loaded home page");
    return $agent;
}

sub default_rtir_agent {
    my $agent = new RT::IR::Test::Web;
    $agent->cookie_jar( HTTP::Cookies->new );
    my $u = rtir_user(MemberOf => 'DutyTeam');
    $agent->login($RTIR_TEST_USER, $RTIR_TEST_PASS);
    $agent->get_ok("/index.html", "loaded home page");
    return $agent;
}

sub rtir_user {
    my $u = RT::Test->load_or_create_user(
        Name         => $RTIR_TEST_USER,
        Password     => $RTIR_TEST_PASS,
        EmailAddress => "$RTIR_TEST_USER\@example.com",
        RealName     => "$RTIR_TEST_USER Smith",
        Privileged   => 1,
        @_,
    );
    return $u;
}


sub create_ticket {
    my $agent = shift;
    my $queue = shift || 'General';

    my $fields = shift || {};
    my $cfs = shift || {};

    my $q = RT::Test->load_or_create_queue(Name => $queue);

    $agent->goto_create_ticket($q);

    #Enable test scripts to pass in the name of the owner rather than the ID
    if ( $fields->{'Owner'} && $fields->{'Owner'} !~ /^\d+$/ ) {
        my $u = RT::User->new( $RT::SystemUser );
        $u->Load( $fields->{'Owner'} );
        die "Couldn't load user '". $fields->{'Owner'} ."'"
            unless $u->id;
        $fields->{'Owner'} = $u->id;
    }
    
    $agent->form_number(3);
    while (my ($f, $v) = each %$fields) {
        $agent->field($f, $v);
    }

    while (my ($f, $v) = each %$cfs) {
        set_custom_field($agent, $f, $v);
    }
    
    
    # Create it!
    $agent->click_button(value => 'Create');
    
    is ($agent->status, 200, "Attempted to create the ticket");

    return get_ticket_id($agent);
}

1;
