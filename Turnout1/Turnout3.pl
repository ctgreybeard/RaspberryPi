#!/usr/bin/perl -w

# Turnout2 initializes to Normal routing then waits for a button
# push on Pin 22 (GPIO25)

use strict;
use warnings;
use v5.10;

use HiPi::Device::GPIO;
use HiPi::Constant qw/ :raspberry /;
use HiPi::Device::GPIO::Pin;
#use HiPi::Pin;
use Time::HiRes qw/ sleep /;

use constant {
    NORMAL     => RPI_HIGH,
    DIVERT     => RPI_LOW,
    THROW_PIN  => RPI_PAD1_PIN_18,
    PULSE_PIN  => RPI_PAD1_PIN_16,
    PULSE_ON   => RPI_LOW,                 # Inverter
    PULSE_OFF  => RPI_HIGH,                # Inverter
    PULSE_TIME => 100,                 # 100ms pulse
    BUTTON_PIN => RPI_PAD1_PIN_22,
};

my $gpio = HiPi::Device::GPIO->new();	# OO device
my ($throw_pin, $pulse_pin, $button_pin);	# Pin objects

sub dir_name($) {
    my $dir     = shift @_;
    my $dirname = 'undef';
    $dirname = $dir == NORMAL ? 'NORMAL' : 'DIVERT' if ( defined $dir );
  return $dirname;
}

sub do_pulse() {
    sleep(0.001);         # 1 Millisecond
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

sub set_button($) {    # Prepare the button for input
    my $btn_pin = shift @_;
    $btn_pin->mode( RPI_PINMODE_INPT );
    Device::BCM2835::gpio_set_pud( $btn_pin, BCM2835_GPIO_PUD_UP )
      ;                                         # Set pull-up
    Device::BCM2835::gpio_set_eds($btn_pin);    # Clear the EDS flag
    Device::BCM2835::gpio_fen($btn_pin);       # Falling Edge Detect
}

sub get_button($) {    # Get FED status, return TRUE if detected
    my $btn_pin = shift @_;
  return ( $btn_pin->value() == RPI_HIGH );
}

sub init() {
	printf STDERR "Using Throw pin: %d, Pulse pin: %d, Button pin: %d\n", THROW_PIN, PULSE_PIN, BUTTON_PIN;

# Export the pins
	$gpio->export_pin( THROW_PIN );
	$throw_pin = $gpio->get_pin( THROW_PIN );
	$gpio->export_pin( PULSE_PIN );
	$pulse_pin = $gpio->get_pin( PULSE_PIN );
	$gpio->export_pin( BUTTON_PIN );
	$button_pin = $gpio->get_pin( BUTTON_PIN );

# Set THROW and PULSE pins to be output
	$throw_pin->mode( RPI_PINMODE_OUTP );
	$pulse_pin->mode( RPI_PINMODE_OUTP );

# Turn off the pulse right away
	$pulse_pin->value( PULSE_OFF );

# Set to normal
	do_throw( $throw_pin, NORMAL );
	set_button($button_pin);
}

while (1) {
    sleep(10 * 0.001);    # Rapid polling - 10ms
    if ( get_button($button_pin) ) {
        print STDERR "P";
        set_button($button_pin);
        my $newdir = do_throw($throw_pin);
        printf STDERR "Set %d to %s\n", THROW_PIN, dir_name($newdir);
    } else {
#        my $lev = ( Device::BCM2835::gpio_lev(BUTTON_PIN) == HIGH ) ? "H" : "L";
#        print STDERR $lev;
    }
}

print STDERR "Done...\n"
