//
//  LXMach_Arm.c
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/7.
//

#if defined (__arm__)


#include "LXMach.h"


static const char* g_registerNames[] =
{
    "r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7",
    "r8", "r9", "r10", "r11", "ip",
    "sp", "lr", "pc", "cpsr"
};
static const int g_registerNamesCount =
sizeof(g_registerNames) / sizeof(*g_registerNames);


static const char* g_exceptionRegisterNames[] =
{
    "exception", "fsr", "far"
};
static const int g_exceptionRegisterNamesCount =
sizeof(g_exceptionRegisterNames) / sizeof(*g_exceptionRegisterNames);


uintptr_t lxmach_framePointer(const STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__r[7];
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
                        STRUCT_MCONTEXT_L* const machineContext)
{
    return lxmach_fillState(thread,
                            (thread_state_t)&machineContext->__ss,
                            ARM_THREAD_STATE,
                            ARM_THREAD_STATE_COUNT);
}

bool lxmach_floatState(const thread_t thread,
                       STRUCT_MCONTEXT_L* const machineContext)
{
    return lxmach_fillState(thread,
                            (thread_state_t)&machineContext->__fs,
                            ARM_VFP_STATE,
                            ARM_VFP_STATE_COUNT);
}

bool lxmach_exceptionState(const thread_t thread,
                           STRUCT_MCONTEXT_L* const machineContext)
{
    return lxmach_fillState(thread,
                            (thread_state_t)&machineContext->__es,
                            ARM_EXCEPTION_STATE,
                            ARM_EXCEPTION_STATE_COUNT);
}

int lxmach_numRegisters(void)
{
    return g_registerNamesCount;
}

const char* lxmach_registerName(const int regNumber)
{
    if(regNumber < lxmach_numRegisters())
    {
        return g_registerNames[regNumber];
    }
    return NULL;
}

uint64_t lxmach_registerValue(const STRUCT_MCONTEXT_L* const machineContext,
                              const int regNumber)
{
    if(regNumber <= 12)
    {
        return machineContext->__ss.__r[regNumber];
    }
    
    switch(regNumber)
    {
        case 13: return machineContext->__ss.__sp;
        case 14: return machineContext->__ss.__lr;
        case 15: return machineContext->__ss.__pc;
        case 16: return machineContext->__ss.__cpsr;
    }
    
    printf("Invalid register number: %d", regNumber);
    return 0;
}

int lxmach_numExceptionRegisters(void)
{
    return g_exceptionRegisterNamesCount;
}

const char* lxmach_exceptionRegisterName(const int regNumber)
{
    if(regNumber < lxmach_numExceptionRegisters())
    {
        return g_exceptionRegisterNames[regNumber];
    }
    printf("Invalid register number: %d", regNumber);
    return NULL;
}

uint64_t lxmach_exceptionRegisterValue(const STRUCT_MCONTEXT_L* const machineContext,
                                       const int regNumber)
{
    switch(regNumber)
    {
        case 0:
            return machineContext->__es.__exception;
        case 1:
            return machineContext->__es.__fsr;
        case 2:
            return machineContext->__es.__far;
    }
    
    printf("Invalid register number: %d", regNumber);
    return 0;
}

uintptr_t lxmach_faultAddress(const STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__es.__far;
}

int lxmach_stackGrowDirection(void)
{
    return -1;
}


#endif

