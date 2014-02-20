use inc::Module::Install;

RTx('RT-Extension-TicketLocking');
license('GPL2');
all_from('lib/RT/Extension/TicketLocking.pm');
readme_from;

build_requires('Test::More');

requires_rt('3.7.0');

my ($lib_path) = $INC{'RT.pm'} =~ /^(.*)[\\\/]/;
my $local_lib_path = "$RT::LocalPath/lib";
unshift @INC, $local_lib_path, $lib_path;

substitute( {
        RT_LIB_PATH => join( ' ', $local_lib_path, $lib_path ),
    },
    't/test_suite.pl',
);


WriteAll();
