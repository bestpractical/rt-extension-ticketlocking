#!/usr/bin/perl

use strict;
use warnings;

use Test::More qw/no_plan/;

require "t/test_suite.pl";

my $ok = 1;

use File::Find;
find( {
    no_chdir => 1,
    wanted   => sub {
        return if /(?:\.(?:jpe?g|png|gif|rej)|\~)$/i;
        if ( m{/\.svn$} ) {
            $File::Find::prune = 1;
            return;
        }
        return unless -f $_;
        diag "testing $_" if $ENV{'TEST_VERBOSE'};
        check_callback( $_ ) and return;
        $ok = 0;
        diag "error in ${File::Find::name}:\n$@";
    },
}, 'html/Callbacks/');
ok($ok, "all callbacks are ok");


sub check_callback {
    my $path = shift;
    my ($comp, $callback) = ($path =~ m{^html/Callbacks/[^/]+/(.*)/([^/]+)$});

    my $comp_path = "/opt/rt3/share/html/$comp";
    $comp_path = "/opt/rt3/html/$comp" unless -e $comp_path;

    open my $fh, '<', $comp_path or die "couldn't open '$comp_path': $!";
    my $text = do { local $/; <$fh> };
    close $fh;

    if ( $callback eq 'Default' ) {
        return $text =~ /\$m->callback/;
    } else {
        return $text =~ /CallbackName\s*=>\s*'$callback'/;
    }

    return 1;
}

