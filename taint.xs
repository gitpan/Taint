#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

/* This function takes the passed SV (Which is really an RV) and */
/* checks to see if it's already in the stack. We use a fairly naive */
/* check, assuming if the returned SV pointer is the same as the SV */
/* pointer we're checking against then we've got the same SV. WHich, I */
/* suppose, we really do */
int
OnStack(AV *RefCountStack, SV *RefToCheck)
{
  SV *SVToCheck;
  I32 NumAVEntries;
  I32 AVStackPointer;

  NumAVEntries = av_len(RefCountStack);
  /* If it's -1, the array's empty so we bail */
  if (NumAVEntries == -1) {
    return FALSE;
  } else {
    for (AVStackPointer = 0; AVStackPointer <= NumAVEntries;
	 AVStackPointer++) {
      {
	SVToCheck = *av_fetch(RefCountStack, AVStackPointer, 0);
	if (SVToCheck == RefToCheck) {
	  return TRUE;
	}
      }
    }
  }

  /* If we've gotten here, then we must not have found it. */
  return FALSE;
}

/* This routine checks its input argument. If it's an RV, it returns a */
/* pointer to the SV the RV points to. It will go recursive if the RV */
/* points to an RV. The passed AV pointer is used to store the RVs, so */
/* we can check to see if we've gotten into an infinite loop. */
SV *
GetAnSV(SV *CheckSV, AV *DepthArray, int Depth)
{
  SV *DereffedSV;
  if (SvROK(CheckSV)) {
    /* Check to see if the current RV's already on the stack. If so, */
    /* complain. Otherwise push it on the stack and call ourselves */
    /* recursively */
    if (OnStack(DepthArray, CheckSV)) {
      croak("Taint reference recursion detected");
    } else {
      SV * TempSV;
      /* Push the SV on the stack */
      av_push(DepthArray, CheckSV);
      /* Call ourselves recursively and save the return to return */
      DereffedSV = GetAnSV(SvRV(CheckSV), DepthArray, Depth + 1);
      /* Pop the value off the stack */
      TempSV = av_pop(DepthArray);
      return DereffedSV;
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
  AV *AVStack;

  if (items == 0) croak("Usage: taint(var[,var[,var...]])");
  
  /* First check to see if all the items are taintable, and croak if */
  /* they're not */
  for (i=0; i < items; i++) {
    /* Allocate an array for our ref check stack */
    AVStack = newAV();
    if (SvREADONLY(GetAnSV(ST(i), AVStack, 0))) {
      /* Clear out the stack before going away */
      av_undef(AVStack);
      croak("Attempt to taint read-only value");
    }

    /* Toss the array for this run through the loop */
    av_undef(AVStack);
  }

  for (i=0; i < items; i++) {
    /* Allocate an array for our ref check stack */
    AVStack = newAV();
    WorkingSV = GetAnSV(ST(i), AVStack, 0);
    /* Are we really working with an SV? */
    if (SvOK(WorkingSV)) {
      SvTAINTED_on(WorkingSV);
    } else {
      TaintType = SvTYPE(WorkingSV);
      switch(TaintType) {
      case SVt_PVAV:
	/* Clean up the stack before we go */
	av_undef(AVStack);
	croak("Attempt to taint an array");
	break;
      case SVt_PVHV:
	/* Clean up the stack before we go */
	av_undef(AVStack);
	croak("Attempt to taint a hash");
	break;
      case SVt_PVCV:
	/* Clean up the stack before we go */
	av_undef(AVStack);
	croak("Attempt to taint code");
	break;
      case SVt_PVGV:
	/* Clean up the stack before we go */
	av_undef(AVStack);
	croak("Attempt to taint a typeglob");
	break;
      case SVt_RV:
	/* Clean up the stack before we go */
	av_undef(AVStack);
	croak("Attempt to taint a reference");
	break;
      default:
	/* Clean up the stack before we go */
	av_undef(AVStack);
	croak("Attempt to taint something unknown or undef");
	break;
      }
    }
    /* Clear out the AV for the next run through */
    av_clear(AVStack);
  }

  XSRETURN_EMPTY;
}

void
tainted(...)
  PPCODE:
{
  AV *AVStack;
  if (items != 1) croak("Usage: tainted(var)");
  /* If we're not in tainting mode, unconditionally return no */
  if (!tainting)
    XSRETURN_NO;

  /* Allocate the AV we need as a ref loop stack */
  AVStack = newAV();

  if (SvTAINTED(GetAnSV(ST(0), AVStack, 0))) {
    /* Clean up the stack before we go */
    av_undef(AVStack);
    XSRETURN_YES;
  } else {
    /* Clean up the stack before we go */
    av_undef(AVStack);
    XSRETURN_NO;
  }
}
