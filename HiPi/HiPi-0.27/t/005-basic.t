#!perl

# SVN Id $Id: 005-basic.t 1028 2013-03-11 16:04:27Z Mark Dootson $

use Test::More tests => 1;

use HiPi::Wiring;
use HiPi::RaspberryPi;

{
    my $fixedrev = (exists($ENV{HIPI_FORCE_BOARD_REVISION})) ? $ENV{HIPI_FORCE_BOARD_REVISION} : HiPi::Wiring::piBoardRev();
    is( HiPi::RaspberryPi::get_cpuinfo->{'GPIO Revision'}, $fixedrev, 'GPIO Revision');
}

1;
