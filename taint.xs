#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

/* How many rimes will we dereference an RV? */
#define MAXDEPTH 64

/* This routine checks its input argument. If it's an RV, it returns a */
/* pointer to the SV the RV points to. It will go recursive if the RV */
/* points to an RV...*/
SV *
GetAnSV(SV *CheckSV, int DepthCounter)
{
  if (SvROK(CheckSV)) {
    if (DepthCounter < MAXDEPTH) {
      return GetAnSV(SvRV(CheckSV), DepthCounter +1);
    } else {
      croak("Taint reference recursion level too deep");
    }
  } else {
    return CheckSV;
  }
}

MODULE = Taint		PACKAGE = Taint		

void
taint(...)
  PPCODE:
{
  int i, TaintType;
  SV *WorkingSV;
  
  if (items == 0) croak("Usage: taint(var[,var[,var...]])");
  
  /* First check to see if all the items are taintable, and croak if */
  /* they're not */
  for (i=0; i < items; i++) {
    if (SvREADONLY(GetAnSV(ST(i), 1)))
      croak("Attempt to taint read-only value");
  }
  
  for (i=0; i < items; i++) {
    WorkingSV = GetAnSV(ST(i), 1);
    /* Are we really working with an SV? */
    if (SvOK(WorkingSV)) {
      SvTAINTED_on(WorkingSV);
    } else {
      TaintType = SvTYPE(WorkingSV);
      switch(TaintType) {
      case SVt_PVAV:
	croak("Attempt to taint an array");
	break;
      case SVt_PVHV:
	croak("Attempt to taint a hash");
	break;
      case SVt_PVCV:
	croak("Attempt to taint code");
	break;
      case SVt_PVGV:
	croak("Attempt to taint a typeglob");
	break;
      case SVt_RV:
	croak("Attempt to taint a reference");
	break;
      default:
	croak("Attempt to taint something unknown or undef");
	break;
      }
    }
  }
  XSRETURN_EMPTY;
}

void
tainted(...)
  PPCODE:
{
  if (items != 1) croak("Usage: tainted(var)");
  /* If we're not in tainting mode, unconditionally return no */
  if (!tainting)
    XSRETURN_NO;

  if (SvTAINTED(GetAnSV(ST(0), 1)))
    XSRETURN_YES;
  else
    XSRETURN_NO;
}
