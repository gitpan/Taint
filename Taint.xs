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
  int i, TaintType;
  SV *WorkingSV;

  if (items == 0) croak("Usage: taint(var[,var[,var...]])");
  
  /* First check to see if all the items are taintable, and croak if */
  /* they're not */
  for (i=0; i < items; i++) {
    if (SvREADONLY(ST(i))) {
      croak("Attempt to taint read-only value");
      XSRETURN_EMPTY;
    }
  }

  for (i=0; i < items; i++) {
    WorkingSV = ST(i);
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
      /* Okay, last chance. We can be an RV, unknown, or an SV. See which */
      /* and act appropriately */
      if (SvROK(WorkingSV)) {
        /* Well, we got a reference. Naughty. Dereference it and see what */
        /* we're yelling about */
        TaintType = SvTYPE(SvRV(WorkingSV));
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
          /* Anything that's not special must be a reference to an SV of */
          /* some sort */
          croak("Attempt to taint a reference");
          break;
        }
      } else {
        /* Okay, it's not a reference. If it's not an SV, then it must be a */
        /* mystery value */
        if (SvOK(WorkingSV)) {
          SvTAINTED_on(WorkingSV);
        } else {
          croak("Attempt to taint something unknown or undef");
        }
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
  if (!PL_tainting)
    XSRETURN_NO;

  if (SvTAINTED(ST(0))) {
    XSRETURN_YES;
  } else {
    XSRETURN_NO;
  }
}
