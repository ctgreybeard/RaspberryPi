#########################################################################################
# Package       HiPi::Device::GPIO::Pin
# Description:  Pin
# Created       Wed Feb 20 04:37:38 2013
# SVN Id        $Id: Pin.pm 1589 2013-03-19 07:33:09Z Mark Dootson $
# Copyright:    Copyright (c) 2013 Mark Dootson
# Licence:      This work is free software; you can redistribute it and/or modify it 
#               under the terms of the GNU General Public License as published by the 
#               Free Software Foundation; either version 3 of the License, or any later 
#               version.
#########################################################################################

package HiPi::Device::GPIO::Pin;

#########################################################################################
use 5.14.0;
use strict;
use warnings;
use parent qw( HiPi::Pin );
use Carp;
use Fcntl;
use HiPi::Constant qw( :raspberry );
use HiPi;

our $VERSION = '0.22';

__PACKAGE__->create_accessors( qw( valfh pinroot dirfh ) );

sub _open {
    my ($class, %params) = @_;
    defined($params{pinid}) or croak q(pinid not defined in parameters);
    
    
    my $pinroot = qq(/sys/class/gpio/gpio$params{pinid});
    croak qq(pin $params{pinid} is not exported) if !-d $pinroot;
    
    my $valfile = qq($pinroot/value);
    my $dirfile = qq($pinroot/direction);
    sysopen($params{valfh}, $valfile, O_RDWR  ) or croak qq(failed to open sysfs value file for pin $params{pinid} : $!);
    sysopen($params{dirfh}, $dirfile, O_RDWR  ) or croak qq(failed to open sysfs mode file for pin $params{pinid} : $!);
    $params{pinroot} = $pinroot;
    my $self = $class->SUPER::_open(%params);
    return $self;
}

sub _do_getvalue {
    my $self = shift;
    sysseek($self->valfh,0,0);
    my $result;
    sysread($self->valfh, $result, 16);
    chomp($result);
    return $result;
}

sub _do_setvalue {
    my ($self, $newval) = @_;
    syswrite($self->valfh, $newval);
}

sub _do_getmode {
    my $self = shift;
    sysseek($self->dirfh,0,0);
    my $result;
    sysread($self->dirfh, $result, 16);
    chomp($result);
    return ( $result eq 'out' ) ? RPI_PINMODE_OUTP : RPI_PINMODE_INPT;
}

sub _do_setmode {
    my ($self, $newdir) = @_;
    if( ($newdir == RPI_PINMODE_OUTP) || ($newdir eq 'out') )  {
        syswrite($self->dirfh, 'out');
    } else {
        syswrite($self->dirfh, 'in');
    }
    return $newdir;
}

sub _reset_value_handle {
    my $self = shift;
    close($self->valfh);
    my $newfh;
    my $filepath = $self->pinroot . '/value';
    sysopen($newfh, $filepath, O_RDWR ) or croak qq( failed to open file $filepath : $!);
    $self->valfh($newfh);
}

sub _do_getinterrupt {
    my $self = shift;
    my $edgepath = $self->pinroot . '/edge';
    my $result = HiPi::qx_sudo(qq(/bin/cat $edgepath));
    if( $? ) {
        croak qq(failed reading $edgepath : $!);
    }
    chomp( $result );
    if($result eq 'rising') {
        return RPI_INT_RISE;
    } elsif($result eq 'falling') {
        return RPI_INT_FALL;
    } elsif($result eq 'both') {
        return RPI_INT_BOTH;
    } else {
        return RPI_INT_NONE;
    }
}

sub _do_setinterrupt {
    my ($self, $newedge) = @_;
    my $stredge = 'none';
    given( $newedge ) {
        when( [ RPI_INT_AFALL, RPI_INT_FALL, RPI_INT_LOW, 'falling'  ] ) {
            $stredge = 'falling';
        }
        when( [ RPI_INT_ARISE, RPI_INT_RISE, RPI_INT_HIGH, 'rising'  ] ) {
            $stredge = 'rising';
        }
        when( [ RPI_INT_BOTH, 'both'  ] ) {
            $stredge = 'both';
        }
        default {
            $stredge = 'none';
        }
    }
    
    my $edgepath = $self->pinroot . '/edge';
    HiPi::system_sudo_shell(qq(/bin/echo $stredge > $edgepath)) and croak qq( failed to write to $edgepath : $!);
}


sub active_low {
    my($self, $newval) = @_;
    
    my $filepath = $self->pinroot . '/active_low';
    
    if(defined($newval)) {
        HiPi::system_sudo_shell(qq(/bin/echo $newval > $filepath)) and croak qq( failed to write to $filepath : $!);
    }
    
    my $value = HiPi::qx_sudo(qq(/bin/cat $filepath));
    if($?) {
        croak qq(failed to read $filepath : $!);
    }
    chomp($value);
    return $value;
} 

sub DESTROY {
    my $self = shift;
    close($self->valfh);
    close($self->dirfh);
}

1;
