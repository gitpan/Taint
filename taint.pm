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
$VERSION = '0.02';

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.  If a constant is not found then control is passed
    # to the AUTOLOAD in AutoLoader.

    my $constname;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
	if ($! =~ /Invalid/) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
		croak "Your vendor has not defined Taint macro $constname";
	}
    }
    eval "sub $AUTOLOAD { $val }";
    goto &$AUTOLOAD;
}

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

=head1 AUTHOR

Dan Sugalski <sugalskd@osshe.edu>

=head1 SEE ALSO

perl(1).

=cut
