#!/usr/bin/perl

# needs apt-get install libjson-xs-perl

#########################################################################################
# Description:  Publish Sensor Output
# Created       Wed Mar 27 03:51:41 2013
# svn id        $Id: roomtemp.pl 1719 2013-04-07 12:23:34Z Mark Dootson $
# Copyright:    Copyright (c) 2013 Mark Dootson
# Licence:      This work is free software; you can redistribute it and/or modify it 
#               under the terms of the GNU General Public License as published by the 
#               Free Software Foundation; either version 3 of the License, or any later 
#               version.
#########################################################################################
use 5.14.0;

#----------------------------------
  package MyRoomTemp::MetOffice;
#----------------------------------
use strict;
use warnings;
use parent qw( HiPi::Class );
use JSON::XS;
use LWP::UserAgent;
use Try::Tiny;
use Carp;

__PACKAGE__->create_accessors( qw( datakey stationid agentname maxlength ) );

sub new {
    my($class, %userparams ) = @_;
    
    my %params = (
        datakey   => 'nodatakey',
        stationid => 0,
        agentname => 'Raspberry Data Muncher',
        maxlength => 65000,
    );
    
    while( my($key, $value) = each %userparams ) {
        $params{$key} = $value;
    }
    
    my $self = $class->SUPER::new( %params );
    return $self;
}

sub get_current_data {
    my $self = shift;
    
    my $ua = LWP::UserAgent->new(
        timeout     => 60,
        agent       => $self->agentname,
        max_size    => 20000,
    );
    
    $ua->env_proxy;
    
    my $target = 'http://datapoint.metoffice.gov.uk';
    $target   .= '/public/data/val/wxobs/all/json/';
    $target   .= $self->stationid;
    $target   .= '?res=hourly&key=';
    $target   .= $self->datakey;
    
    my $response = $ua->get( $target );
    
    unless( $response->is_success ) {
        croak(sprintf(
            '%s failed to retrieve content for station %s : %s',
            $self->agentname,
            $self->stationid,
            $response->message)
        );
    }
    
    my $handler = JSON::XS->new();
    
    return $handler->decode( $response->decoded_content );
}

package main;
use strict;
use warnings;
use Data::Dumper;
my $met = MyRoomTemp::MetOffice->new(
    stationid  => '3316',
    datakey    => 'fdfc251a-3a19-40df-bdc3-e828f146e74d',
);

my $data = $met->get_current_data;

print Dumper( $data );








1;
