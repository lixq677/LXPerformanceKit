//
//  LXMach_x86_64.c
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/7.
//

#if defined (__x86_64__)


#include "LXMach.h"


static const char* g_registerNames[] =
{
    "rax", "rbx", "rcx", "rdx",
    "rdi", "rsi",
    "rbp", "rsp",
    "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15",
    "rip", "rflags",
    "cs", "fs", "gs"
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
    return machineContext->__ss.__rbp;
}

uintptr_t lxmach_stackPointer(const STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__rsp;
}

uintptr_t lxmach_instructionAddress(const STRUCT_MCONTEXT_L* const machineContext)
{
    return machineContext->__ss.__rip;
}

uintptr_t lxmach_linkRegister(const STRUCT_MCONTEXT_L* const machineContext __attribute__ ((unused)))
{
    return 0;
}

bool lxmach_threadState(const thread_t thread,
                        STRUCT_MCONTEXT_L* const machineContext)
{
    return lxmach_fillState(thread,
                            (thread_state_t)&machineContext->__ss,
                            x86_THREAD_STATE64,
                            x86_THREAD_STATE64_COUNT);
}

bool lxmach_floatState(const thread_t thread,
                       STRUCT_MCONTEXT_L* const machineContext)
{
    return lxmach_fillState(thread,
                            (thread_state_t)&machineContext->__fs,
                            x86_FLOAT_STATE64,
                            x86_FLOAT_STATE64_COUNT);
}

bool lxmach_exceptionState(const thread_t thread,
                           STRUCT_MCONTEXT_L* const machineContext)
{
    return lxmach_fillState(thread,
                            (thread_state_t)&machineContext->__es,
                            x86_EXCEPTION_STATE64,
                            x86_EXCEPTION_STATE64_COUNT);
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
            return machineContext->__ss.__rax;
        case 1:
            return machineContext->__ss.__rbx;
        case 2:
            return machineContext->__ss.__rcx;
        case 3:
            return machineContext->__ss.__rdx;
        case 4:
            return machineContext->__ss.__rdi;
        case 5:
            return machineContext->__ss.__rsi;
        case 6:
            return machineContext->__ss.__rbp;
        case 7:
            return machineContext->__ss.__rsp;
        case 8:
            return machineContext->__ss.__r8;
        case 9:
            return machineContext->__ss.__r9;
        case 10:
            return machineContext->__ss.__r10;
        case 11:
            return machineContext->__ss.__r11;
        case 12:
            return machineContext->__ss.__r12;
        case 13:
            return machineContext->__ss.__r13;
        case 14:
            return machineContext->__ss.__r14;
        case 15:
            return machineContext->__ss.__r15;
        case 16:
            return machineContext->__ss.__rip;
        case 17:
            return machineContext->__ss.__rflags;
        case 18:
            return machineContext->__ss.__cs;
        case 19:
            return machineContext->__ss.__fs;
        case 20:
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
