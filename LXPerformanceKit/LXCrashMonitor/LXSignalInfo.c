//
//  LXSignalInfo.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/9.
//

#import "LXSignalInfo.h"

#include <signal.h>


typedef struct
{
    const int code;
    const char* const name;
} LXSignalCodeInfo;

typedef struct
{
    const int sigNum;
    const char* const name;
    const LXSignalCodeInfo* const codes;
    const int numCodes;
} LXSignalInfo;

#define ENUM_NAME_MAPPING(A) {A, #A}

static const LXSignalCodeInfo g_sigIllCodes[] =
{
    ENUM_NAME_MAPPING(ILL_NOOP),
    ENUM_NAME_MAPPING(ILL_ILLOPC),
    ENUM_NAME_MAPPING(ILL_ILLTRP),
    ENUM_NAME_MAPPING(ILL_PRVOPC),
    ENUM_NAME_MAPPING(ILL_ILLOPN),
    ENUM_NAME_MAPPING(ILL_ILLADR),
    ENUM_NAME_MAPPING(ILL_PRVREG),
    ENUM_NAME_MAPPING(ILL_COPROC),
    ENUM_NAME_MAPPING(ILL_BADSTK),
};

static const LXSignalCodeInfo g_sigTrapCodes[] =
{
    ENUM_NAME_MAPPING(0),
    ENUM_NAME_MAPPING(TRAP_BRKPT),
    ENUM_NAME_MAPPING(TRAP_TRACE),
};

static const LXSignalCodeInfo g_sigFPECodes[] =
{
    ENUM_NAME_MAPPING(FPE_NOOP),
    ENUM_NAME_MAPPING(FPE_FLTDIV),
    ENUM_NAME_MAPPING(FPE_FLTOVF),
    ENUM_NAME_MAPPING(FPE_FLTUND),
    ENUM_NAME_MAPPING(FPE_FLTRES),
    ENUM_NAME_MAPPING(FPE_FLTINV),
    ENUM_NAME_MAPPING(FPE_FLTSUB),
    ENUM_NAME_MAPPING(FPE_INTDIV),
    ENUM_NAME_MAPPING(FPE_INTOVF),
};

static const LXSignalCodeInfo g_sigBusCodes[] =
{
    ENUM_NAME_MAPPING(BUS_NOOP),
    ENUM_NAME_MAPPING(BUS_ADRALN),
    ENUM_NAME_MAPPING(BUS_ADRERR),
    ENUM_NAME_MAPPING(BUS_OBJERR),
};

static const LXSignalCodeInfo g_sigSegVCodes[] =
{
    ENUM_NAME_MAPPING(SEGV_NOOP),
    ENUM_NAME_MAPPING(SEGV_MAPERR),
    ENUM_NAME_MAPPING(SEGV_ACCERR),
};

#define SIGNAL_INFO(SIGNAL, CODES) {SIGNAL, #SIGNAL, CODES, sizeof(CODES) / sizeof(*CODES)}
#define SIGNAL_INFO_NOCODES(SIGNAL) {SIGNAL, #SIGNAL, 0, 0}

static const LXSignalInfo g_fatalSignalData[] =
{
    SIGNAL_INFO_NOCODES(SIGABRT),
    SIGNAL_INFO(SIGBUS, g_sigBusCodes),
    SIGNAL_INFO(SIGFPE, g_sigFPECodes),
    SIGNAL_INFO(SIGILL, g_sigIllCodes),
    SIGNAL_INFO_NOCODES(SIGPIPE),
    SIGNAL_INFO(SIGSEGV, g_sigSegVCodes),
    SIGNAL_INFO_NOCODES(SIGSYS),
    SIGNAL_INFO(SIGTERM, g_sigTrapCodes),
};
static const int g_fatalSignalsCount = sizeof(g_fatalSignalData) / sizeof(*g_fatalSignalData);

// Note: Dereferencing a NULL pointer causes SIGILL, ILL_ILLOPC on i386
//       but causes SIGTRAP, 0 on arm.
static const int g_fatalSignals[] =
{
    SIGABRT,
    SIGBUS,
    SIGFPE,
    SIGILL,
    SIGPIPE,
    SIGSEGV,
    SIGSYS,
    SIGTRAP,
};

const char* lxsignal_signalName(const int sigNum)
{
    for(int i = 0; i < g_fatalSignalsCount; i++)
    {
        if(g_fatalSignalData[i].sigNum == sigNum)
        {
            return g_fatalSignalData[i].name;
        }
    }
    return NULL;
}

const char* lxsignal_signalCodeName(const int sigNum, const int code)
{
    for(int si = 0; si < g_fatalSignalsCount; si++)
    {
        if(g_fatalSignalData[si].sigNum == sigNum)
        {
            for(int ci = 0; ci < g_fatalSignalData[si].numCodes; ci++)
            {
                if(g_fatalSignalData[si].codes[ci].code == code)
                {
                    return g_fatalSignalData[si].codes[ci].name;
                }
            }
        }
    }
    return NULL;
}

const int* lxsignal_fatalSignals(void)
{
    return g_fatalSignals;
}

int lxsignal_numFatalSignals(void)
{
    return g_fatalSignalsCount;
}

#define EXC_UNIX_BAD_SYSCALL 0x10000 /* SIGSYS */
#define EXC_UNIX_BAD_PIPE    0x10001 /* SIGPIPE */
#define EXC_UNIX_ABORT       0x10002 /* SIGABRT */

int lxsignal_machExceptionForSignal(const int sigNum){
    switch(sigNum){
        case SIGFPE:
            return EXC_ARITHMETIC;
        case SIGSEGV:
            return EXC_BAD_ACCESS;
        case SIGBUS:
            return EXC_BAD_ACCESS;
        case SIGILL:
            return EXC_BAD_INSTRUCTION;
        case SIGTRAP:
            return EXC_BREAKPOINT;
        case SIGEMT:
            return EXC_EMULATION;
        case SIGSYS:
            return EXC_UNIX_BAD_SYSCALL;
        case SIGPIPE:
            return EXC_UNIX_BAD_PIPE;
        case SIGABRT:
            // The Apple reporter uses EXC_CRASH instead of EXC_UNIX_ABORT
            return EXC_CRASH;
        case SIGKILL:
            return EXC_SOFT_SIGNAL;
    }
    return 0;
}

int lxsignal_signalForMachException(const int exception,
                                    const mach_exception_code_t code)
{
    switch(exception)
    {
        case EXC_ARITHMETIC:
            return SIGFPE;
        case EXC_BAD_ACCESS:
            return code == KERN_INVALID_ADDRESS ? SIGSEGV : SIGBUS;
        case EXC_BAD_INSTRUCTION:
            return SIGILL;
        case EXC_BREAKPOINT:
            return SIGTRAP;
        case EXC_EMULATION:
            return SIGEMT;
        case EXC_SOFTWARE:
        {
            switch (code)
            {
                case EXC_UNIX_BAD_SYSCALL:
                    return SIGSYS;
                case EXC_UNIX_BAD_PIPE:
                    return SIGPIPE;
                case EXC_UNIX_ABORT:
                    return SIGABRT;
                case EXC_SOFT_SIGNAL:
                    return SIGKILL;
            }
            break;
        }
    }
    return 0;
}
