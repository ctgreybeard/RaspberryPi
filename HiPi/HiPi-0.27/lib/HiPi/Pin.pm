#########################################################################################
# Package       HiPi::Pin
# Description:  GPIO / Extender Pin
# Created       Wed Feb 20 04:39:18 2013
# SVN Id        $Id: Pin.pm 1076 2013-03-13 08:55:10Z Mark Dootson $
# Copyright:    Copyright (c) 2013 Mark Dootson
# Licence:      This work is free software; you can redistribute it and/or modify it 
#               under the terms of the GNU General Public License as published by the 
#               Free Software Foundation; either version 3 of the License, or any later 
#               version.
#########################################################################################

package HiPi::Pin;

#########################################################################################

use strict;
use warnings;
use HiPi::Class;
use base qw( HiPi::Class );

our $VERSION = '0.22';

__PACKAGE__->create_ro_accessors( qw( pinid ) );

sub _open {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    return $self;
}


sub value {
    my($self, $newval) = @_;
    if(defined($newval)) {
        return $self->_do_setvalue($newval);
    } else {
        return $self->_do_getvalue();
    }
}

sub mode {
    my($self, $newval) = @_;
    if(defined($newval)) {
        return $self->_do_setmode($newval);
    } else {
        return $self->_do_getmode();
    }
}

sub interrupt {
    my($self, $newval) = @_;
    if(defined($newval)) {
        return $self->_do_setinterrupt($newval);
    } else {
        return $self->_do_getinterrupt();
    }
}

1;

__END__
