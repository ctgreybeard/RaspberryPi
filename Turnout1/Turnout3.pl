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
use Carp;

use constant {
    NORMAL     => RPI_LOW,
    DIVERT     => RPI_HIGH,
    THROW_PIN  => RPI_PAD1_PIN_18,
    PULSE_PIN  => RPI_PAD1_PIN_16,
    PULSE_ON   => RPI_HIGH,          # Inverter
    PULSE_OFF  => RPI_LOW,           # Inverter
    PULSE_TIME => 100,               # 100ms pulse
    BUTTON_PIN => RPI_PAD1_PIN_22,
    MS         => .001,
};

my $gpio = HiPi::Device::GPIO->new();    # OO device
my ( $throw_pin, $pulse_pin, $button_pin );    # Pin objects

sub mode_name($) {
    my $mode     = shift @_;
    my $modename = 'undef';
    $modename = $mode == RPI_PINMODE_INPT ? "INPUT" : "OUTPUT"
      if ( defined $mode );
  return $modename;
} ## end sub mode_name($)

sub dir_name($) {
    my $dir     = shift @_;
    my $dirname = 'undef';
    $dirname = $dir == NORMAL ? 'NORMAL' : 'DIVERT' if ( defined $dir );
  return $dirname;
} ## end sub dir_name($)

sub do_pulse($) {
    my $ppin = shift @_;
    sleep( 1 * MS );    # 1 Millisecond
    croak "Pulse pin not set!" unless $ppin;
    $ppin->value( PULSE_ON );
    sleep( PULSE_TIME * MS );    # Milliseconds
    $ppin->value( PULSE_OFF );
    sleep( 1 * MS );             # Milliseconds
} ## end sub do_pulse($)

sub do_throw($;$) {

    my $pin = shift @_ or croak "do_throw invalid pin";
    my $dir = shift @_;    # Throw direction

    printf STDERR "do_throw: pin: %d, dir: %s\n", $pin->pinid, dir_name( $dir );

    unless ( defined $dir ) {    # Determine throw direction
        print STDERR "Getting current direction\n";
        $dir = $pin->value();
        printf STDERR "Current direction is %s\n", dir_name( $dir );
        $dir = $dir == NORMAL ? DIVERT : NORMAL;
        printf STDERR "New direction is %s\n", dir_name( $dir );
    } ## end unless ( defined $dir )

    $pin->value( $dir );
    do_pulse( $pulse_pin );
  return $dir;
} ## end sub do_throw($;$)

sub set_button($) {    # Prepare the button for input
    my $btn_pin = shift @_;
    $btn_pin->mode( RPI_PINMODE_INPT );     # Input for the button
    $btn_pin->set_pud( RPI_PUD_UP );        # Set pull-up
    $btn_pin->interrupt( RPI_INT_FALL );    # Set falling-edge interrupt
} ## end sub set_button($)

sub get_button($) {    # Get FED status, return TRUE if detected
    my $btn_pin = shift @_;
  return ( $btn_pin->value() == RPI_LOW );

    #NOTE: Do we need to reset the interrupt status??
} ## end sub get_button($)

sub init() {
    printf STDERR "Using Throw pin: %d, Pulse pin: %d, Button pin: %d\n",
      THROW_PIN, PULSE_PIN, BUTTON_PIN;

    # Export the pins
    $gpio->unexport_pin( THROW_PIN );
    $gpio->export_pin( THROW_PIN );
    $throw_pin = $gpio->get_pin( THROW_PIN )
      or croak "Unable to capture THROW_PIN: &THROW_PIN";
    $throw_pin->active_low( 1 );
    $gpio->unexport_pin( PULSE_PIN );
    $gpio->export_pin( PULSE_PIN );
    $pulse_pin = $gpio->get_pin( PULSE_PIN )
      or croak "Unable to capture PULSE_PIN: &PULSE_PIN";
    $pulse_pin->active_low( 1 );
    $gpio->unexport_pin( BUTTON_PIN );
    $gpio->export_pin( BUTTON_PIN );
    $button_pin = $gpio->get_pin( BUTTON_PIN )
      or croak "Unable to capture BUTTON_PIN: &BUTTON_PIN";

    # Set THROW and PULSE pins to be output
    printf STDERR "Throw pin old mode=%s\n",
      mode_name( $throw_pin->mode( RPI_PINMODE_OUTP ) );
    printf STDERR "Pulse pin old mode=%s\n",
      mode_name( $pulse_pin->mode( RPI_PINMODE_OUTP ) );

    # Turn off the pulse right away
    printf STDERR "Pulse pin set off, was %d\n", $pulse_pin->value( PULSE_OFF );

    # Set to normal
    do_throw( $throw_pin, NORMAL );
    set_button( $button_pin );

    printf STDERR "Init done ...\n";
} ## end sub init

init();    # Get started ...

while ( 1 ) {
    sleep( 10 * 0.001 );    # Rapid polling - 10ms
    if ( get_button( $button_pin ) ) {
        print STDERR "P";
        set_button( $button_pin );
        my $newdir = do_throw( $throw_pin );
        printf STDERR "Set %d to %s\n", THROW_PIN, dir_name( $newdir );
    } else {

        #        my $lev = ( Device::BCM2835::gpio_lev(BUTTON_PIN) == HIGH ) ? "H" : "L";
        #        print STDERR $lev;
    }
} ## end while ( 1 )

print STDERR "Done...\n"
