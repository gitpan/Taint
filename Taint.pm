package Taint;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD);

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
	
);
@EXPORT_OK = qw(&taint &tainted);
$VERSION = '0.07';

bootstrap Taint $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Taint - Perl extension to taint variables

=head1 SYNOPSIS

  use Taint;
  taint($taintvar[, $anothervar[, $yetmorevars]]);
  $bool = tainted($vartocheck);

=head1 DESCRIPTION

C<taint()> marks its arguments as tainted.

C<tainted()> returns true if its argument is tainted, false otherwise

=head1 DIAGNOSTICS

=head2 Attempt to taint read-only value

You attempted to taint something untaintable, such as a constant or
expression. C<taint()> only takes lvalues for arguments

=head2 Attempt to taint an array

A reference to an array was passed to C<taint>. You can only taint
individual array items, not array itself.

=head2 Attempt to taint a hash

A reference to a hash was passed to C<taint>. You can only taint individual
hash items, not the entire hash.

=head2 Attempt to taint code

You passed a coderef to C<taint>. You can't I<do> that.

=head2 Attempt to taint a typeglob

You passed a typeglob to C<taint>. C<taint> only taints scalars, and a
typeglob isn't one.

=head2 Attempt to taint a reference

You tried to taint a reference, which you just can't do. 

=head2 Attempt to taint something unknown or undef

You tried C<taint>ing either a variable set to undef, or your version
of perl has more types of variables than mine did when this module was
written. Odds are, you're trying to taint a variable with an undef value like,
for example, one that has been created (either explicitly or implicitly) but
not had a value assigned.

Doing this:

	my $foo;
	taint($foo);

will trigger this error.

=head1 AUTHOR

Dan Sugalski <sugalskd@osshe.edu>

=head1 SEE ALSO

perl(1).

=cut
