#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

MODULE = Taint		PACKAGE = Taint		

void
taint(...)
  PPCODE:
{
  int i;

  if (items == 0) croak("Usage: taint(var[,var[,var...]])");

  for (i=0; i < items; i++) {
    SvTAINTED_on(ST(i));
  }
   XSRETURN_EMPTY;
 }

void
tainted(...)
  PPCODE:
{
  if (items != 1) croak("Usage: tainted(var)");
  if (SvTAINTED(ST(0)))
    XSRETURN_YES;
  else
    XSRETURN_NO;
}
