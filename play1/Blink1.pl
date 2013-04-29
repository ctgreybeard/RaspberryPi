#!/usr/bin/perl

use warnings;
use strict;

use 5.14.0;
use Carp;

use Getopt::Long;

use HiPi::Device::GPIO qw/ :pinstatus /;
use HiPi::Constant qw/:raspberry /;

my ( $dev, $pin, $status, $my_pin,, $delay, $pin_mode );

sub name_status($) {
    my $status = shift;
    my $name   = "Undetermined";

    $name = "DEV_GPIO_PIN_STATUS_NONE" if $status == DEV_GPIO_PIN_STATUS_NONE;
    $name = "DEV_GPIO_PIN_STATUS_EXPORTED"
      if $status == DEV_GPIO_PIN_STATUS_EXPORTED;
  return $name;
} ## end sub name_status($)

sub name_mode($) {
    my $status = shift;
    my $name   = "Undetermined";

    $name = "RPI_PINMODE_INPT" if $status == RPI_PINMODE_INPT;
    $name = "RPI_PINMODE_OUTP" if $status == RPI_PINMODE_OUTP;
    $name = "RPI_PINMODE_ALT0" if $status == RPI_PINMODE_ALT0;
    $name = "RPI_PINMODE_ALT1" if $status == RPI_PINMODE_ALT1;
    $name = "RPI_PINMODE_ALT2" if $status == RPI_PINMODE_ALT2;
    $name = "RPI_PINMODE_ALT3" if $status == RPI_PINMODE_ALT3;
    $name = "RPI_PINMODE_ALT4" if $status == RPI_PINMODE_ALT4;
    $name = "RPI_PINMODE_ALT5" if $status == RPI_PINMODE_ALT5;
  return $name;
} ## end sub name_mode($)

say "Using HiPi::Device::GPIO::VERSION: ", $HiPi::Device::GPIO::VERSION;
say "Using HiPi::Device::GPIO::Pin::VERSION: ",
  $HiPi::Device::GPIO::Pin::VERSION;

$dev = HiPi::Device::GPIO->new() or croak "Cannot create device";

$my_pin = RPI_PAD1_PIN_18;
$delay  = 2.0;

GetOptions(
    'pin=i'   => \$my_pin,
    'delay=f' => \$delay,
) && ( 0 == scalar @ARGV ) or croak "Invalid options";

say "Using GPIO pin: ", $my_pin;
$status = $dev->pin_status( $my_pin );

say "Current status is: ", name_status( $status );

say "Delay time=", $delay;

say "Exporting...";
$dev->export_pin( $my_pin );

$status = $dev->pin_status( $my_pin );

say "Current status is: ", name_status( $status );

$pin = $dev->get_pin( $my_pin ) or croak "Cannot create pin";
say "Got the pin ...";

$pin_mode = $pin->mode();
say "Current mode is: ", name_mode( $pin_mode );

say "Setting to OUTP";
$pin->mode( RPI_PINMODE_OUTP );

$pin_mode = $pin->mode();
say "Current mode is: ", name_mode( $pin_mode );

say "Current active_low is: ", $pin->active_low();
say "Setting active_low: off";
$pin->active_low( 0 );
my $continue = 1;

local $SIG{ 'INT' } = sub { $continue = 0; };

while ( $continue ) {
    say "Reading value...";
    my $pin_val = $pin->value();
    my $new_val = $pin_val == RPI_HIGH ? RPI_LOW : RPI_HIGH;
    say "Current value=", $pin_val, ", setting to ", $new_val;
    $pin->value( $new_val );
    sleep( $delay );
} ## end while ( $continue )

say "Unexporting";
$dev->unexport_pin( $my_pin );

$status = $dev->pin_status( $my_pin );

say "Current status is: ", name_status( $status );
