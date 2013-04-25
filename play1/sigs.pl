#!/usr/bin/perl

use 5.14.0;
use strict;
use warnings;

use Try::Tiny::SmartCatch qw/ :all /;

my $stopit;

sub catchit($) {
    my $sig = shift;
    say "\nCaught a SIG$sig";
    $stopit = 1;
    throw "stopit";
} ## end sub catchit($)

{
    local $SIG{ 'INT' };

    $SIG{ 'INT' } = \&catchit;

    try sub {
        for ( 1 .. 4 ) {
            say "Waiting...";
            sleep( 2 );
        } ## end for ( 1 .. 4 )
      }, catch_when 'stopit' => sub {
        say "catch_stopit";
      },
      catch_default sub {
        say "catch_default";
      },
	  finally sub {
		  say "finally!";
	  };

}

say "Done...";
