#include "__cf_PD_CONTROL.h"
#ifndef RTW_HEADER_PD_CONTROL_acc_h_
#define RTW_HEADER_PD_CONTROL_acc_h_
#include <stddef.h>
#include <float.h>
#ifndef PD_CONTROL_acc_COMMON_INCLUDES_
#define PD_CONTROL_acc_COMMON_INCLUDES_
#include <stdlib.h>
#define S_FUNCTION_NAME simulink_only_sfcn 
#define S_FUNCTION_LEVEL 2
#define RTW_GENERATED_S_FUNCTION
#include "sl_AsyncioQueue/AsyncioQueueCAPI.h"
#include "simtarget/slSimTgtSigstreamRTW.h"
#include "simtarget/slSimTgtSlioCoreRTW.h"
#include "simtarget/slSimTgtSlioClientsRTW.h"
#include "simtarget/slSimTgtSlioSdiRTW.h"
#include "rtwtypes.h"
#include "simstruc.h"
#include "fixedpoint.h"
#endif
#include "PD_CONTROL_acc_types.h"
#include "multiword_types.h"
#include "rtGetInf.h"
#include "rt_nonfinite.h"
#include "mwmathutil.h"
#include "rt_defines.h"
typedef struct { real_T B_1_0_0 ; real_T B_1_2_0 ; real_T B_1_3_0 ; real_T
B_1_8_0 ; real_T B_1_9_0 ; real_T B_1_10_0 ; real_T B_1_11_0 ; real_T
B_1_0_0_m ; real_T B_0_0_1 ; } B_PD_CONTROL_T ; typedef struct { real_T
TimeStampA ; real_T LastUAtTimeA ; real_T TimeStampB ; real_T LastUAtTimeB ;
struct { real_T modelTStart ; } TransportDelay_RWORK ; void * Scope_PWORK ;
struct { void * TUbufferPtrs [ 2 ] ; } TransportDelay_PWORK ; struct { void *
AQHandles ; void * SlioLTF ; }
TAQSigLogging_InsertedFor_LTISystem_at_outport_0_PWORK ; struct { void *
AQHandles ; void * SlioLTF ; }
TAQSigLogging_InsertedFor_MATLABFunction_at_outport_0_PWORK ; int32_T
MATLABFunction_sysIdxToRun ; struct { int_T Tail ; int_T Head ; int_T Last ;
int_T CircularBufSize ; int_T MaxNewBufSize ; } TransportDelay_IWORK ; }
DW_PD_CONTROL_T ; typedef struct { real_T Internal_CSTATE [ 3 ] ; }
X_PD_CONTROL_T ; typedef struct { real_T Internal_CSTATE [ 3 ] ; }
XDot_PD_CONTROL_T ; typedef struct { boolean_T Internal_CSTATE [ 3 ] ; }
XDis_PD_CONTROL_T ; typedef struct { real_T Internal_CSTATE [ 3 ] ; }
CStateAbsTol_PD_CONTROL_T ; struct P_PD_CONTROL_T_ { real_T P_0 [ 4 ] ;
real_T P_1 ; real_T P_2 ; real_T P_3 ; real_T P_4 ; real_T P_5 ; real_T P_6 ;
real_T P_7 ; real_T P_8 ; } ; extern P_PD_CONTROL_T PD_CONTROL_rtDefaultP ;
#endif
