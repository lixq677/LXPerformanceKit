//
//  LXMach_i386.c
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/7.
//

#if defined (__i386__)

#include "LXMach.h"

static const char* g_registerNames[] =
{
    "eax", "ebx", "ecx", "edx",
    "edi", "esi",
    "ebp", "esp", "ss",
    "eflags", "eip",
    "cs", "ds", "es", "fs", "gs",
};
static const int g_registerNamesCount =
sizeof(g_registerNames) / sizeof(*g_registerNames);


static const char* g_exceptionRegisterNames[] =
{
    "trapno", "err", "faultvaddr"
};
static const int g_exceptionRegisterNamesCount =
sizeof(g_exceptionRegisterNames) / sizeof(*g_exceptionRegisterNames);


uintptr_t lxmach_framePointer(const STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__ebp;
}

uintptr_t lxmach_stackPointer(const STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__esp;
}

uintptr_t lxmach_instructionAddress(const STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__eip;
}

uintptr_t lxmach_linkRegister(__unused const STRUCT_MCONTEXT_L* const machineContext)
{
    return 0;
}

bool lxmach_threadState(const thread_t thread,
                        STRUCT_MCONTEXT_L* const machineContext)
{
    return lxmach_fillState(thread,
                            (thread_state_t)&machineContext->__ss,
                            x86_THREAD_STATE32,
                            x86_THREAD_STATE32_COUNT);
}

bool lxmach_floatState(const thread_t thread,
                       STRUCT_MCONTEXT_L* const machineContext)
{
    return lxmach_fillState(thread,
                            (thread_state_t)&machineContext->__fs,
                            x86_FLOAT_STATE32,
                            x86_FLOAT_STATE32_COUNT);
}

bool lxmach_exceptionState(const thread_t thread,
                           STRUCT_MCONTEXT_L* const machineContext)
{
    return lxmach_fillState(thread,
                            (thread_state_t)&machineContext->__es,
                            x86_EXCEPTION_STATE32,
                            x86_EXCEPTION_STATE32_COUNT);
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
    switch(regNumber)
    {
        case 0:
            return machineContext->__ss.__eax;
        case 1:
            return machineContext->__ss.__ebx;
        case 2:
            return machineContext->__ss.__ecx;
        case 3:
            return machineContext->__ss.__edx;
        case 4:
            return machineContext->__ss.__edi;
        case 5:
            return machineContext->__ss.__esi;
        case 6:
            return machineContext->__ss.__ebp;
        case 7:
            return machineContext->__ss.__esp;
        case 8:
            return machineContext->__ss.__ss;
        case 9:
            return machineContext->__ss.__eflags;
        case 10:
            return machineContext->__ss.__eip;
        case 11:
            return machineContext->__ss.__cs;
        case 12:
            return machineContext->__ss.__ds;
        case 13:
            return machineContext->__ss.__es;
        case 14:
            return machineContext->__ss.__fs;
        case 15:
            return machineContext->__ss.__gs;
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
            return machineContext->__es.__trapno;
        case 1:
            return machineContext->__es.__err;
        case 2:
            return machineContext->__es.__faultvaddr;
    }
    
    printf("Invalid register number: %d", regNumber);
    return 0;
}

uintptr_t lxmach_faultAddress(const STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__es.__faultvaddr;
}

int lxmach_stackGrowDirection(void)
{
    return -1;
}

#endif
