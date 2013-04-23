#########################################################################################
# Package       HiPi::Device::GPIO
# Description:  System GPIO Device
# Created       Wed Feb 20 02:40:29 2013
# SVN Id        $Id: GPIO.pm 1717 2013-03-26 23:34:36Z Mark Dootson $
# Copyright:    Copyright (c) 2013 Mark Dootson
# Licence:      This work is free software; you can redistribute it and/or modify it 
#               under the terms of the GNU General Public License as published by the 
#               Free Software Foundation; either version 3 of the License, or any later 
#               version.
#########################################################################################

package HiPi::Device::GPIO;

#########################################################################################
use 5.14.0;
use strict;
use warnings;
use HiPi;
use parent qw( HiPi::Device );
use HiPi::Constant qw( :raspberry );
use Carp;
use HiPi::Device::GPIO::Pin;

our $VERSION = '0.22';

use constant {
    DEV_GPIO_PIN_STATUS_NONE         => 0x00,
    DEV_GPIO_PIN_STATUS_EXPORTED     => 0x01,
};

our @EXPORT_OK = qw(
    DEV_GPIO_PIN_STATUS_NONE 
    DEV_GPIO_PIN_STATUS_EXPORTED
);

our %EXPORT_TAGS = ( all => \@EXPORT_OK, pinstatus => \@EXPORT_OK );

sub new {
    my ($class, %userparams) = @_;
    
    my %params = ();
    
    foreach my $key (sort keys(%userparams)) {
        $params{$key} = $userparams{$key};
    }
    
    my $self = $class->SUPER::new(%params);
    return $self;
}

# Methods are class methods

sub get_pin {
    my( $self, $pinid ) = @_;
    HiPi::Device::GPIO::Pin->_open( pinid => $pinid );
}

sub export_pin {
    my( $self, $pinno, $gname ) = @_;
    my $pinroot = '/sys/class/gpio/gpio' . $pinno;
    # export the pin
    
    if( !-d $pinroot ) {
        HiPi::system_sudo_shell(qq(/bin/echo $pinno > /sys/class/gpio/export)) and croak qq(failed to export pin $pinno : $!);
    }
    if( $gname ) {
        # change exported permissions
        for my $fname ( qw(value edge direction active_low) ) {
            my $file = qq($pinroot/$fname);
            HiPi::system_sudo( qq(chmod 0664 $pinroot/$fname) ) and croak qq(failed to change permissions for pin $pinno : $!);
            HiPi::system_sudo( qq(chown root:$gname $pinroot/$fname) ) and croak qq(failed to change group for pin $pinno : $!);
        }
    }
}

sub unexport_pin {
    my( $self, $pinno ) = @_;
    my $pinroot = '/sys/class/gpio/gpio' . $pinno;
    return if !-d $pinroot;
    # unexport the pin
    HiPi::system_sudo_shell( qq(/bin/echo $pinno > /sys/class/gpio/unexport) ) and croak qq(failed to unexport pin $pinno : $!);
}

sub pin_status {
    my($self, $pinno) = @_;
    my $pinroot = '/sys/class/gpio/gpio' . $pinno;
    return (-d $pinroot ) ? DEV_GPIO_PIN_STATUS_EXPORTED : DEV_GPIO_PIN_STATUS_NONE;    
}

1;
