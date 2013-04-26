#!/usr/bin/perl -w

# Turnout2 initializes to Normal routing then waits for a button
# push on Pin 22 (GPIO25)

use strict;
use warnings;
use v5.14;

use HiPi::Device::GPIO;
use HiPi::Constant qw/ :raspberry /;
say "Using HiPi version=",          $HiPi::Device::GPIO::VERSION;
say "Using HiPi GPIO Pin version=", $HiPi::Device::GPIO::Pin::VERSION;

use Time::HiRes qw/ sleep /;
use Carp;

use constant {
    DEBUGLVL   => 2,
    NORMAL     => RPI_LOW,
    DIVERT     => RPI_HIGH,
    THROW_PIN  => RPI_PAD1_PIN_18,
    PULSE_PIN  => RPI_PAD1_PIN_16,
    PULSE_ON   => RPI_HIGH,
    PULSE_OFF  => RPI_LOW,
    PULSE_TIME => 40.0,              # 40ms pulse
    BUTTON_PIN => RPI_PAD1_PIN_22,
    MS         => .001,
};

sub DEBUG($;@) {
    my $msglvl = shift;
    my $fmt    = shift;
    printf STDERR $fmt . "\n", @_ if ( $msglvl <= DEBUGLVL );
}

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
    sleep( 1.0 * MS );    # 1 Millisecond
    croak "Pulse pin not set!" unless $ppin;
    $ppin->value( PULSE_ON );
    DEBUG 2, "sleeping: %.3fms", PULSE_TIME;
    DEBUG 2, "slept: %.3fms",    sleep( PULSE_TIME * MS ) / MS;   # Milliseconds
    $ppin->value( PULSE_OFF );
} ## end sub do_pulse($)

sub do_throw($;$) {

    my $pin = shift @_ or croak "do_throw invalid pin";
    my $dir = shift @_;    # Throw direction

    DEBUG 2, "do_throw: pin: %d, dir: %s", $pin->pinid, dir_name( $dir );

    unless ( defined $dir ) {    # Determine throw direction
        DEBUG 1, "Getting current direction";
        $dir = $pin->value();
        DEBUG 1, "Current direction is %s", dir_name( $dir );
        $dir = $dir == NORMAL ? DIVERT : NORMAL;
        DEBUG 1, "New direction is %s", dir_name( $dir );
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
}

sub kill_it() {
    $pulse_pin->value( PULSE_OFF );
    $throw_pin->value( NORMAL );
    $gpio->unexport_pin( THROW_PIN );
    $gpio->unexport_pin( PULSE_PIN );
    $gpio->unexport_pin( BUTTON_PIN );
} ## end sub kill_it

sub init() {
    DEBUG 1, "Using Throw pin: %d, Pulse pin: %d, Button pin: %d",
      THROW_PIN, PULSE_PIN, BUTTON_PIN;

    # Export the pins
    $gpio->export_pin( THROW_PIN );
    $throw_pin = $gpio->get_pin( THROW_PIN )
      or croak "Unable to capture THROW_PIN: &THROW_PIN";

    $throw_pin->active_low( 1 );
    $gpio->export_pin( PULSE_PIN );
    $pulse_pin = $gpio->get_pin( PULSE_PIN )
      or croak "Unable to capture PULSE_PIN: &PULSE_PIN";

    $pulse_pin->active_low( 1 );
    $gpio->export_pin( BUTTON_PIN );
    $button_pin = $gpio->get_pin( BUTTON_PIN )
      or croak "Unable to capture BUTTON_PIN: &BUTTON_PIN";

    # Set THROW and PULSE pins to be output
    DEBUG 1, "Throw pin old mode=%s",
      mode_name( $throw_pin->mode( RPI_PINMODE_OUTP ) );
    DEBUG 1, "Pulse pin old mode=%s",
      mode_name( $pulse_pin->mode( RPI_PINMODE_OUTP ) );

    # Turn off the pulse right away
    DEBUG 1, "Pulse pin set off, was %d", $pulse_pin->value( PULSE_OFF );

    # Set to normal
    do_throw( $throw_pin, NORMAL );
    set_button( $button_pin );

    DEBUG 1, "Init done ...";
} ## end sub init

init();    # Get started ...

{
    my $stopit = 1;

    local $SIG{ 'INT' } = sub { print "\n"; $stopit = 0; };
    local $SIG{ 'QUIT' } = 'IGNORE';

    while ( $stopit ) {
        sleep( 100.0 * MS );    # Rapid polling - 10ms
        DEBUG 9, "P";
        if ( get_button( $button_pin ) ) {
            my $newdir = do_throw( $throw_pin );
            DEBUG 1, "Set %d to %s", THROW_PIN, dir_name( $newdir );
        }
    } ## end while ( $stopit )
}

kill_it();

DEBUG 1, "Done..."
