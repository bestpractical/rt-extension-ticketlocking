use inc::Module::Install;

RTx('RT-Extension-TicketLocking');
author ('Turner Hayes <thayes@bestpractical.com>');
version_from ('lib/RT/Extension/TicketLocking.pm');
abstract_from('lib/RT/Extension/TicketLocking.pm');
license('perl');
requires('Test::More');

&WriteAll;
