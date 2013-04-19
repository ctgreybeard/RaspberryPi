#!/usr/bin/perl -w

# Turnout2 initializes to Normal routing then waits for a button
# push on Pin 22 (GPIO25)

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
    BUTTON_PIN => RPI_V2_GPIO_P1_22,
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

sub set_button($) {    # Prepare the button for input
    my $btn_pin = shift @_;
    Device::BCM2835::gpio_fsel( $btn_pin, BCM2835_GPIO_FSEL_INPT );
    Device::BCM2835::gpio_set_pud( $btn_pin, BCM2835_GPIO_PUD_UP )
      ;                                         # Set pull-up
    Device::BCM2835::gpio_set_eds($btn_pin);    # Clear the EDS flag
    Device::BCM2835::gpio_fen($btn_pin);       # Falling Edge Detect
}

sub get_button($) {    # Get FED status, return TRUE if detected
    my $btn_pin = shift @_;
  return ( Device::BCM2835::gpio_eds($btn_pin) == HIGH );
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
set_button(BUTTON_PIN);

while (1) {
    Device::BCM2835::delay(10);    # Rapid polling - 10ms
    if ( get_button(BUTTON_PIN) ) {
        print STDERR "P";
        set_button(BUTTON_PIN);
        my $newdir = do_throw(THROW_PIN);
        printf STDERR "Set %d to %s\n", THROW_PIN, dir_name($newdir);
    } else {
#        my $lev = ( Device::BCM2835::gpio_lev(BUTTON_PIN) == HIGH ) ? "H" : "L";
#        print STDERR $lev;
    }
}

print STDERR "Done...\n"
