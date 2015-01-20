use inc::Module::Install;

RTx('RT-Extension-TicketLocking');

build_requires('Test::More');

requires_rt('4.0.6');

my ($lib_path) = $INC{'RT.pm'} =~ /^(.*)[\\\/]/;
my $local_lib_path = "$RT::LocalPath/lib";
unshift @INC, $local_lib_path, $lib_path;

substitute( {
        RT_LIB_PATH => join( ' ', $local_lib_path, $lib_path ),
    },
    'xt/test_suite.pl',
);


WriteAll();
