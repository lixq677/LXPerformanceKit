//
//  LXMach_Arm64.c
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/7.
//

#if defined (__arm64__)


#include "LXMach.h"


static const char* g_registerNames[] =
{
    "x0",  "x1",  "x2",  "x3",  "x4",  "x5",  "x6",  "x7",
    "x8",  "x9", "x10", "x11", "x12", "x13", "x14", "x15",
    "x16", "x17", "x18", "x19", "x20", "x21", "x22", "x23",
    "x24", "x25", "x26", "x27", "x28", "x29",
    "fp", "lr", "sp", "pc", "cpsr"
};
static const int g_registerNamesCount =
sizeof(g_registerNames) / sizeof(*g_registerNames);


static const char* g_exceptionRegisterNames[] =
{
    "exception", "esr", "far"
};
static const int g_exceptionRegisterNamesCount =
sizeof(g_exceptionRegisterNames) / sizeof(*g_exceptionRegisterNames);


uintptr_t lxmach_framePointer(const STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__fp;
}

uintptr_t lxmach_stackPointer(const STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__sp;
}

uintptr_t lxmach_instructionAddress(const STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__pc;
}

uintptr_t lxmach_linkRegister(const STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__lr;
}

bool lxmach_threadState(const thread_t thread,
                        STRUCT_MCONTEXT_L* const machineContext){
    return lxmach_fillState(thread,
                            (thread_state_t)&machineContext->__ss,
                            ARM_THREAD_STATE64,
                            ARM_THREAD_STATE64_COUNT);
}

bool lxmach_floatState(const thread_t thread,
                       STRUCT_MCONTEXT_L* const machineContext){
    return lxmach_fillState(thread,
                            (thread_state_t)&machineContext->__ns,
                            ARM_VFP_STATE,
                            ARM_VFP_STATE_COUNT);
}

bool lxmach_exceptionState(const thread_t thread,
                           STRUCT_MCONTEXT_L* const machineContext){
    return lxmach_fillState(thread,
                            (thread_state_t)&machineContext->__es,
                            ARM_EXCEPTION_STATE64,
                            ARM_EXCEPTION_STATE64_COUNT);
}

int lxmach_numRegisters(void){
    return g_registerNamesCount;
}

const char* lxmach_registerName(const int regNumber){
    if(regNumber < lxmach_numRegisters())
    {
        return g_registerNames[regNumber];
    }
    return NULL;
}

uint64_t lxmach_registerValue(const STRUCT_MCONTEXT_L* const machineContext,
                              const int regNumber){
    if(regNumber <= 29)
    {
        return machineContext->__ss.__x[regNumber];
    }
    
    switch(regNumber)
    {
        case 30: return machineContext->__ss.__fp;
        case 31: return machineContext->__ss.__lr;
        case 32: return machineContext->__ss.__sp;
        case 33: return machineContext->__ss.__pc;
        case 34: return machineContext->__ss.__cpsr;
    }
    
    printf("Invalid register number: %d", regNumber);
    return 0;
}

int lxmach_numExceptionRegisters(void){
    return g_exceptionRegisterNamesCount;
}

const char* lxmach_exceptionRegisterName(const int regNumber){
    if(regNumber < lxmach_numExceptionRegisters())
    {
        return g_exceptionRegisterNames[regNumber];
    }
    printf("Invalid register number: %d", regNumber);
    return NULL;
}

uint64_t lxmach_exceptionRegisterValue(const STRUCT_MCONTEXT_L* const machineContext,
                                       const int regNumber){
    switch(regNumber){
        case 0:
            return machineContext->__es.__exception;
        case 1:
            return machineContext->__es.__esr;
        case 2:
            return machineContext->__es.__far;
    }
    
    printf("Invalid register number: %d", regNumber);
    return 0;
}

uintptr_t lxmach_faultAddress(const STRUCT_MCONTEXT_L* const machineContext){
    return machineContext->__es.__far;
}

int lxmach_stackGrowDirection(void){
    return -1;
}


#endif

