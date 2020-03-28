#include "__cf_MRFT_CONTROL.h"
#ifndef RTW_HEADER_MRFT_CONTROL_acc_h_
#define RTW_HEADER_MRFT_CONTROL_acc_h_
#include <stddef.h>
#include <float.h>
#ifndef MRFT_CONTROL_acc_COMMON_INCLUDES_
#define MRFT_CONTROL_acc_COMMON_INCLUDES_
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
#include "MRFT_CONTROL_acc_types.h"
#include "multiword_types.h"
#include "rtGetInf.h"
#include "rt_nonfinite.h"
#include "mwmathutil.h"
#include "rt_defines.h"
typedef struct { real_T B_0_0_0 [ 3 ] ; real_T B_0_1_0 ; real_T B_0_2_0 ;
real_T B_0_3_0 ; real_T B_0_4_0 ; real_T B_0_10_0 ; real_T B_0_11_0 ; real_T
B_0_12_0 ; real_T B_0_13_0 ; real_T B_0_15_0 ; real_T B_0_16_0 ; real_T
B_0_19_0 ; real_T B_0_21_0 ; real_T B_0_27_0 [ 2 ] ; real_T B_0_29_0 ; real_T
B_0_30_0 [ 3 ] ; real_T B_0_34_0 ; real_T B_0_0_0_m ; real_T B_0_1_0_c ;
real_T B_0_2_0_k ; real_T B_0_3_0_c ; } B_MRFT_CONTROL_T ; typedef struct {
real_T TimeStampA ; real_T LastUAtTimeA ; real_T TimeStampB ; real_T
LastUAtTimeB ; real_T Memory2_PreviousInput ; real_T Memory_PreviousInput ;
real_T Memory1_PreviousInput ; real_T
 HiddenRateTransitionForToWks_InsertedFor_TAQSigLogging_InsertedFor_MRFT_at_outport_0_at_inport_0_Buffer0
; struct { real_T modelTStart ; } TransportDelay_RWORK ; void * Scope1_PWORK
[ 2 ] ; void * Scope3_PWORK [ 2 ] ; struct { void * AQHandles ; void *
SlioLTF ; } TAQSigLogging_InsertedFor_LTISystem_at_outport_0_PWORK ; struct {
void * AQHandles ; void * SlioLTF ; }
TAQSigLogging_InsertedFor_MRFT_at_outport_0_PWORK ; struct { void *
TUbufferPtrs [ 4 ] ; } TransportDelay_PWORK ; void * Scope_PWORK ; void *
Scope1_PWORK_n ; void * Scope2_PWORK ; void * Scope_PWORK_h ; struct { int_T
Tail [ 2 ] ; int_T Head [ 2 ] ; int_T Last [ 2 ] ; int_T CircularBufSize [ 2
] ; int_T MaxNewBufSize ; } TransportDelay_IWORK ; int_T MinMax_MODE ; int_T
MinMax1_MODE ; int_T Sign_MODE ; int_T Step_MODE ; int8_T
 HiddenRateTransitionForToWks_InsertedFor_TAQSigLogging_InsertedFor_MRFT_at_outport_0_at_inport_0_semaphoreTaken
; boolean_T RelationalOperator_Mode ; char_T pad_RelationalOperator_Mode [ 2
] ; } DW_MRFT_CONTROL_T ; typedef struct { real_T Internal_CSTATE [ 5 ] ;
real_T TransferFcn2_CSTATE ; } X_MRFT_CONTROL_T ; typedef struct { real_T
Internal_CSTATE [ 5 ] ; real_T TransferFcn2_CSTATE ; } XDot_MRFT_CONTROL_T ;
typedef struct { boolean_T Internal_CSTATE [ 5 ] ; boolean_T
TransferFcn2_CSTATE ; } XDis_MRFT_CONTROL_T ; typedef struct { real_T
Internal_CSTATE [ 5 ] ; real_T TransferFcn2_CSTATE ; }
CStateAbsTol_MRFT_CONTROL_T ; typedef struct { real_T
RelationalOperator_RelopInput_ZC ; real_T MinMax_MinmaxInput_ZC ; real_T
MinMax1_MinmaxInput_ZC ; real_T Sign_Input_ZC ; real_T Step_StepTime_ZC ; }
ZCV_MRFT_CONTROL_T ; typedef struct { ZCSigState
RelationalOperator_RelopInput_ZCE ; ZCSigState MinMax_MinmaxInput_ZCE ;
ZCSigState MinMax1_MinmaxInput_ZCE ; ZCSigState Sign_Input_ZCE ; ZCSigState
Step_StepTime_ZCE ; } PrevZCX_MRFT_CONTROL_T ; struct P_MRFT_CONTROL_T_ {
real_T P_0 [ 5 ] ; real_T P_1 [ 3 ] ; real_T P_2 [ 6 ] ; real_T P_3 ; real_T
P_4 ; real_T P_5 ; real_T P_6 ; real_T P_7 ; real_T P_8 ; real_T P_9 ; real_T
P_10 ; real_T P_11 ; real_T P_12 ; real_T P_13 ; real_T P_14 [ 2 ] ; real_T
P_15 [ 2 ] ; real_T P_16 ; real_T P_17 ; real_T P_18 ; real_T P_19 ; real_T
P_20 ; real_T P_21 ; real_T P_22 ; real_T P_23 ; } ; extern P_MRFT_CONTROL_T
MRFT_CONTROL_rtDefaultP ;
#endif
