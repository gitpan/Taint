#! perl
# (Gotta run with taint checking, otherwise what's the point?)
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..11\n"; }
END {print "not ok 1\n" unless $loaded;}
use Taint;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my ($foo, $bar, $baz);
# Initially set the variables to something, so they're not undef.
$foo = "a";
$bar = "b";
$baz = "";
# Check to see if a basic variable is tainted. Shouldn't be
print is_tainted($foo) ? "not ok 2\n": "ok 2\n";
Taint::taint($foo);
# Did the previous taint work? Check
print is_tainted($foo) ? "ok 3\n": "not ok 3\n";
Taint::taint($bar, $baz);
# Checking to see if tainting multiple arguments works
print is_tainted($bar) ? "ok 4\n": "not ok 4\n";
print is_tainted($baz) ? "ok 5\n": "not ok 5\n";
# Now check our XS' tainted check
print Taint::tainted($bar) ? "ok 6\n": "not ok 6\n";

# Check to see if we can taint a constant
eval{Taint::taint(1)};
# Did we error out properly?
if ($@ =~ m/Attempt to taint read-only value/) {
    print "ok 7\n";
} else {
    print "not ok 7\n";
}

$foo = "bar";
$baz = \$foo;
Taint::taint($foo);

# Can we taint a reference?
eval{Taint::taint($baz)};
# Did we error out properly?
if ($@ =~ m/Attempt to taint a reference/) {
    print "ok 8\n";
} else {
    print "not ok 8 #$@";
}

# How about an array?
@yada = ('a', 'b', 'c');
$baz = \@yada;
eval{Taint::taint($baz)};
# Did we error out properly?
if ($@ =~ m/Attempt to taint an array/) {
    print "ok 9\n";
} else {
    print "not ok 9 #$@";
}

# How about a hash?
$baz = \%ahash;
eval{Taint::taint($baz)};
# Did we error out properly?
if ($@ =~ m/Attempt to taint a hash/) {
    print "ok 10\n";
} else {
    print "not ok 10 #$@";
}

# How about a reference that refers to itself?
my $should_be_undef_to_start;
eval{Taint::taint($should_be_undef_to_start)};
# Did we error out properly?
if ($@ =~ m/Attempt to taint something unknown or undef/) {
    print "ok 11\n";
} else {
    print "not ok 11\n";
}

sub is_tainted {
  return ! eval {

    join('',@_), kill 0;
    1;
  };
}
