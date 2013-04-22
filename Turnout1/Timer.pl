#!/usr/bin/perl -w

use strict;
use warnings;

use feature qw/say/;

use constant {
	DEBUG => 1,
};

my ($t, $r, $c, $f) = @ARGV;

$f = 0.68 unless ($f);

die "Usage: $0 t-Value(secs) r-Value(K Ohms) c-Value(uF) [f-Value(0.68)]\n" unless ( defined $c );

$c *= 1e6;	# Make it picoFarads
$t *= 1e9;	# Make it nanosecs

if ($t == 0) {
	say "Finding T, F=$f, R=$r, C=$c" if (DEBUG);
	$t = $f * $r * $c;
} elsif ($r == 0) {
	say "Finding R, F=$f, T=$t, C=$c" if (DEBUG);
	$r = $t / ($f * $c);
} elsif ($c == 0) {
	say "Finding C, F=$f, R=$r, T=$t" if (DEBUG);
	$c = $t / ($f * $r);
} else {
	die "Nothing to do!\n";
}

$c *= 1e-6;	# Revert back to uF
$t *= 1e-9;	# Revert back to secs

printf "t=%.3gs, r=%.3gK, c=%.3guF, f=%.2g\n", $t, $r, $c, $f;
