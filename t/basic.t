#! perl -T
# (Gotta run with taint checking, otherwise what's the point?)
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..6\n"; }
END {print "not ok 1\n" unless $loaded;}
use Taint;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$foo = "bar";
print is_tainted($foo) ? "not ok 2\n": "ok 2\n";
Taint::taint($foo);
print is_tainted($foo) ? "ok 3\n": "not ok 3\n";
Taint::taint($bar, $baz);
print is_tainted($bar) ? "ok 4\n": "not ok 4\n";
print is_tainted($baz) ? "ok 5\n": "not ok 5\n";
print Taint::tainted($bar) ? "ok 6\n": "not ok 6\n";

sub is_tainted {
  return ! eval {
    join('',@_), kill 0;
    1;
  };
}
