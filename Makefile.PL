use inc::Module::Install;

RTx('RT-Extension-TicketLocking');
license('GPL2');
all_from('lib/RT/Extension/TicketLocking.pm');
abstract_from('lib/RT/Extension/TicketLocking.pm');

requires('Test::More');

{ # check RT version
    my @v = split /\./, "$RT::VERSION";
    unless (($v[0]>=3 && $v[1]>=7) || $v[0]>3) {
        die "Extension needs RT 3.7.0 at least, you have $RT::VERSION";
    }
}


my ($lib_path) = $INC{'RT.pm'} =~ /^(.*)[\\\/]/;
my $local_lib_path = "$RT::LocalPath/lib";
unshift @INC, $local_lib_path, $lib_path;

substitute( {
        RT_LIB_PATH => join( ' ', $local_lib_path, $lib_path ),
    },
    't/test_suite.pl',
);


WriteAll();
