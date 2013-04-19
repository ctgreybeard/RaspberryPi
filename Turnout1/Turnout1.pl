#!/usr/bin/perl -w

use strict;
use warnings;

use Device::BCM2835 qw/:all/;

use constant {
    NORMAL     => HIGH,
    DIVERT     => LOW,
    THROW_PIN  => RPI_V2_GPIO_P1_18,
    PULSE_PIN  => RPI_V2_GPIO_P1_16,
    PULSE_ON   => LOW,                 # Inverter
    PULSE_OFF  => HIGH,                # Inverter
    PULSE_TIME => 100,                 # 100ms pulse
};

sub dir_name($) {
    my $dir     = shift @_;
    my $dirname = 'undef';
    $dirname = $dir == NORMAL ? 'NORMAL' : 'DIVERT' if ( defined $dir );
  return $dirname;
}

sub do_pulse() {
    Device::BCM2835::delay(1);         # Milliseconds
    Device::BCM2835::gpio_write( PULSE_PIN, PULSE_ON );
    Device::BCM2835::delay(PULSE_TIME);    # Milliseconds
    Device::BCM2835::gpio_write( PULSE_PIN, PULSE_OFF );
    Device::BCM2835::delay(1);             # Milliseconds
}

sub do_throw($;$) {

    my $pin = shift @_ or die "do_throw invalid pin";
    my $dir = shift @_;    # Throw direction

    printf STDERR "do_throw: pin: %d, dir: %s\n", $pin, dir_name($dir);

    unless ($dir) {    # Determine throw direction
        print STDERR "Getting current direction\n";
        $dir = Device::BCM2835::gpio_lev($pin);
        printf STDERR "Current direction is %s\n", dir_name($dir);
        $dir = $dir == NORMAL ? DIVERT : NORMAL;
        printf STDERR "New direction is %s\n", dir_name($dir);
    }

    Device::BCM2835::gpio_write( $pin, $dir );
    do_pulse();
  return $dir;
}

Device::BCM2835::init()
  or die "Unable to initialize!";

printf STDERR "Using Throw pin: %d, Pulse pin: %d\n", THROW_PIN, PULSE_PIN;

# Set THROW and PULSE pins to be output
Device::BCM2835::gpio_fsel( THROW_PIN, BCM2835_GPIO_FSEL_OUTP );
Device::BCM2835::gpio_fsel( PULSE_PIN, BCM2835_GPIO_FSEL_OUTP );

# Turn off the pulse right away
Device::BCM2835::gpio_write( PULSE_PIN, PULSE_OFF );

# Set to normal
do_throw( THROW_PIN, NORMAL );

while (1) {
    Device::BCM2835::delay(5000);    # Milliseconds
    my $newdir = do_throw(THROW_PIN);
    printf STDERR "Set %d to %s\n", THROW_PIN, dir_name($newdir);
}

print STDERR "Done...\n"
