//
//  LXBacktraceLogger.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/17.
//

#import "LXBacktrace.h"
#import <mach/mach.h>
#include <dlfcn.h>
#include <pthread.h>
#include <sys/types.h>
#include <limits.h>
#include <string.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>
#import <dlfcn.h>
#import <execinfo.h>

#pragma -mark DEFINE MACRO FOR DIFFERENT CPU ARCHITECTURE
#if defined(__arm64__)
#define DETAG_INSTRUCTION_ADDRESS(A) ((A) & ~(3UL))
#define LX_THREAD_STATE_COUNT ARM_THREAD_STATE64_COUNT
#define LX_THREAD_STATE ARM_THREAD_STATE64
#define LX_FRAME_POINTER __fp
#define LX_STACK_POINTER __sp
#define LX_INSTRUCTION_ADDRESS __pc
#define MY_SEGMENT_CMD_TYPE LC_SEGMENT_64

#elif defined(__arm__)
#define DETAG_INSTRUCTION_ADDRESS(A) ((A) & ~(1UL))
#define LX_THREAD_STATE_COUNT ARM_THREAD_STATE_COUNT
#define LX_THREAD_STATE ARM_THREAD_STATE
#define LX_FRAME_POINTER __r[7]
#define LX_STACK_POINTER __sp
#define LX_INSTRUCTION_ADDRESS __pc
#define MY_SEGMENT_CMD_TYPE LC_SEGMENT

#elif defined(__x86_64__)
#define DETAG_INSTRUCTION_ADDRESS(A) (A)
#define LX_THREAD_STATE_COUNT x86_THREAD_STATE64_COUNT
#define LX_THREAD_STATE x86_THREAD_STATE64
#define LX_FRAME_POINTER __rbp
#define LX_STACK_POINTER __rsp
#define LX_INSTRUCTION_ADDRESS __rip
#define MY_SEGMENT_CMD_TYPE LC_SEGMENT_64

#elif defined(__i386__)
#define DETAG_INSTRUCTION_ADDRESS(A) (A)
#define LX_THREAD_STATE_COUNT x86_THREAD_STATE32_COUNT
#define LX_THREAD_STATE x86_THREAD_STATE32
#define LX_FRAME_POINTER __ebp
#define LX_STACK_POINTER __esp
#define LX_INSTRUCTION_ADDRESS __eip
#define MY_SEGMENT_CMD_TYPE LC_SEGMENT

#endif


#define CALL_INSTRUCTION_FROM_RETURN_ADDRESS(A) (DETAG_INSTRUCTION_ADDRESS((A)) - 1)

#if defined(__LP64__)
#define TRACE_FMT         "%-4d%-31s 0x%016lx %s + %lu"
#define POINTER_FMT       "0x%016lx"
#define POINTER_SHORT_FMT "0x%lx"
#define LX_NLIST struct nlist_64
typedef struct mach_header_64 mach_header_t;
typedef struct segment_command_64 segment_command_t;
#else
#define TRACE_FMT         "%-4d%-31s 0x%08lx %s + %lu"
#define POINTER_FMT       "0x%08lx"
#define POINTER_SHORT_FMT "0x%lx"
typedef struct mach_header mach_header_t;
typedef struct segment_command segment_command_t;
#define LX_NLIST struct nlist
#endif

typedef struct LXStackFrameEntry{
    const struct LXStackFrameEntry *const previous;
    const uintptr_t return_address;
} LXStackFrameEntry;

static mach_port_t main_thread_id;

__attribute__((constructor)) static void CrashMonitor_Initializer(void){
    main_thread_id = mach_thread_self();
}

struct LXSG_Info{
    const char* name;
    long loadAddr;
    long beginAddr;
    long endAddr;
};

@implementation LXBacktrace

+ (NSString *)backtraceNSThread:(NSThread *)thread{
    thread_t th = lx_machThreadFromNSThread(thread);
    NSArray<NSString *> *array = lx_baseAddressInfo();
    NSString *it = _lx_backtraceOfThread(th);
    NSMutableArray *stack = [NSMutableArray arrayWithArray:array];
    if (it.length > 0) {
        [stack addObject:it];
    }
    NSString *log = [stack componentsJoinedByString:@"\n"];
    return log;
}

+ (NSString *)backtraceCurrentThread{
   // NSArray<NSString *> *array = lx_baseAddressInfo();
    NSString *it = [self backtraceNSThread:[NSThread currentThread]];
    NSMutableArray *stack = [NSMutableArray array];
    if (it.length > 0) {
        [stack addObject:it];
    }
    NSString *log = [stack componentsJoinedByString:@"\n"];
    return log;
}

+ (NSString *)backtraceMainThread{
   // NSArray<NSString *> *array = lx_baseAddressInfo();
    NSString *it = [self backtraceNSThread:[NSThread mainThread]];
    NSMutableArray *stack = [NSMutableArray array];
    if (it.length > 0) {
        [stack addObject:it];
    }
    NSString *log = [stack componentsJoinedByString:@"\n"];
    return log;
}

+ (NSString *)backtraceAllThread{//获取所有线程信息
    thread_act_array_t threads;
    mach_msg_type_number_t thread_count = 0;
    const task_t this_task = mach_task_self();
    kern_return_t kr = task_threads(this_task, &threads, &thread_count);
    if(kr != KERN_SUCCESS) {
        return nil;
    }
    
    NSMutableString *resultString = [NSMutableString stringWithFormat:@"Call Backtrace of %u threads:\n", thread_count];
    for(int i = 0; i < thread_count; i++) {
        NSString *info = _lx_backtraceOfThread(threads[i]);
        if (info) {
            [resultString appendString:info];
        }
    }
   // NSArray<NSString *> *array = lx_baseAddressInfo();
    NSMutableArray *stack = [NSMutableArray array];
    [stack addObject:resultString];
    NSString *log = [stack componentsJoinedByString:@"\n"];
    return log;
}

+ (NSString *)backtraceStacksAndSymbol{
//    NSArray<NSString *> *array = lx_baseAddressInfo();
    NSString *it = lx_stacksAndSymbol();
    NSMutableArray *stack = [NSMutableArray array];
    if (it.length > 0) {
        [stack addObject:it];
    }
    NSString *log = [stack componentsJoinedByString:@"\n"];
    return log;
}

+ (NSString *)backtraceStacksNoSymbol{
    return lx_stacksNoSymbol();
}

///转换oc线程为linux 线程
+ (thread_t)machThreadFromNSThread:(NSThread *)nsthread{
    return lx_machThreadFromNSThread(nsthread);
}

/// 回溯linux 线程
+ (NSString *)backtraceThread:(thread_t)thread{
    NSArray<NSString *> *array = lx_baseAddressInfo();
    NSString *it = _lx_backtraceOfThread(thread);
    NSMutableArray *stack = [NSMutableArray arrayWithArray:array];
    if (it.length > 0) {
        [stack addObject:it];
    }
    NSString *log = [stack componentsJoinedByString:@"\n"];
    return log;
}

+(NSArray *)baseAddressInfo{
    return lx_baseAddressInfo();
}

#pragma -mark Get call backtrace of a mach_thread

#define max_stack_depth_sys 64
NSString *lx_stacksAndSymbol(void){
    /*追踪栈信息*/
    NSMutableString *resultString = [[NSMutableString alloc] initWithFormat:@"Backtrace of stacks:\n"];
    vm_address_t *stacks[max_stack_depth_sys];
    int depth = backtrace((void**)stacks, max_stack_depth_sys);
    char **strings = backtrace_symbols((void *)stacks, depth);
    if (strings == NULL) {
        return nil;
    }
    NSMutableArray<NSString *> *symbols = [NSMutableArray array];
    for (int j = 0; j < depth; j++) {
        NSString *s = [[NSString alloc] initWithCString:strings[j] encoding:NSUTF8StringEncoding];
        [symbols addObject:s];
    }
    free(strings);
    [resultString appendString:[symbols componentsJoinedByString:@"\n"]];
    
    return [resultString copy];
}

NSString *lx_stacksNoSymbol(void){
    size_t size = 0;
    uint32_t count = _dyld_image_count();
    struct LXSG_Info *sinfos = calloc(count, sizeof(struct LXSG_Info));
    for (uint32_t i = 0; i < count; i++) {
        const mach_header_t* header = (const mach_header_t*)_dyld_get_image_header(i);
        const char* name = _dyld_get_image_name(i);
        const char* tmp = strrchr(name, '/');
        long slide = _dyld_get_image_vmaddr_slide(i);
        if (tmp) {
            name = tmp + 1;
        }
        long offset = (long)header + sizeof(mach_header_t);
        for (unsigned int j = 0; j < header->ncmds; j++) {
            const segment_command_t *segment = (const segment_command_t *)offset;
            if (segment->cmd == MY_SEGMENT_CMD_TYPE && strcmp(segment->segname, SEG_TEXT) == 0) {
                long begin = (long)segment->vmaddr + slide;
                long end = (long)(begin + segment->vmsize);
                sinfos[i].name = name;
                sinfos[i].beginAddr = begin;
                sinfos[i].endAddr = end;
                sinfos[i].loadAddr = (long)header;
                size++;
                break;
            }
            offset += segment->cmdsize;
        }
    }
    
    NSMutableString *stackInfo = [[NSMutableString alloc] init];
    vm_address_t *stacks[max_stack_depth_sys];
    int depth = backtrace((void**)stacks, max_stack_depth_sys);
    for (int j = 0; j < depth; j++) {
        vm_address_t addr = (vm_address_t)stacks[j];
        for (size_t i = 0; i < size; i++){
            if (addr > sinfos[i].beginAddr && addr < sinfos[i].endAddr) {
                [stackInfo appendFormat:@"%s 0x%lx 0x%lx\n",(sinfos[i].name != NULL) ? sinfos[i].name : "unknown",sinfos[i].loadAddr,(long)addr];
            }
        }
    }
    [stackInfo appendFormat:@"\n"];
    free(sinfos);
    return [stackInfo copy];
}

NSString *_lx_backtraceOfThread(thread_t thread) {
    
    uintptr_t backtraceBuffer[50];
    int i = 0;
    NSMutableString *resultString = [[NSMutableString alloc] initWithFormat:@"Backtrace of Thread %u:\n", thread];
    
    _STRUCT_MCONTEXT machineContext;
    if(!lx_fillThreadStateIntoMachineContext(thread, &machineContext)) {
        return [NSString stringWithFormat:@"Fail to get information about thread: %u", thread];
    }
    
    const uintptr_t instructionAddress = lx_mach_instructionAddress(&machineContext);
    backtraceBuffer[i] = instructionAddress;
    ++i;
    
    uintptr_t linkRegister = lx_mach_linkRegister(&machineContext);
    if (linkRegister) {
        backtraceBuffer[i] = linkRegister;
        i++;
    }
    
    if(instructionAddress == 0) {
        return @"Fail to get instruction address";
        
    }
    
    LXStackFrameEntry frame = {0};
    const uintptr_t framePtr = lx_mach_framePointer(&machineContext);
    if(framePtr == 0 ||
       lx_mach_copyMem((void *)framePtr, &frame, sizeof(frame)) != KERN_SUCCESS) {
        return @"Fail to get frame pointer";
    }
    
    for(; i < 50; i++) {
        backtraceBuffer[i] = frame.return_address;
        if(backtraceBuffer[i] == 0 ||
           frame.previous == 0 ||
           lx_mach_copyMem(frame.previous, &frame, sizeof(frame)) != KERN_SUCCESS) {
            break;
        }
    }
    
    
    int backtraceLength = i;
    Dl_info symbolicated[backtraceLength];
    lx_symbolicate(backtraceBuffer, symbolicated, backtraceLength, 0);
    for (int i = 0; i < backtraceLength; ++i) {
        [resultString appendFormat:@"%@", lx_logBacktraceEntry(i, backtraceBuffer[i], &symbolicated[i])];
    }
    [resultString appendFormat:@"\n"];
    return [resultString copy];
    
}

#pragma -mark Convert NSThread to Mach thread
thread_t lx_machThreadFromNSThread(NSThread *nsthread) {
    char name[256];
    mach_msg_type_number_t count;
    thread_act_array_t list;
    task_threads(mach_task_self(), &list, &count);
    
    NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
    NSString *originName = [nsthread name];
    [nsthread setName:[NSString stringWithFormat:@"%f", currentTimestamp]];
    
    if ([nsthread isMainThread]) {
        return (thread_t)main_thread_id;
    }
    
    for (int i = 0; i < count; ++i) {
        pthread_t pt = pthread_from_mach_thread_np(list[i]);
        if ([nsthread isMainThread]) {
            if (list[i] == main_thread_id) {
                return list[i];
            }
        }
        if (pt) {
            name[0] = '\0';
            pthread_getname_np(pt, name, sizeof name);
            if (!strcmp(name, [nsthread name].UTF8String)) {
                [nsthread setName:originName];
                return list[i];
            }
        }
    }
    
    [nsthread setName:originName];
    return mach_thread_self();
}

#pragma -mark GenerateBacbsrackEnrty
NSString* lx_logBacktraceEntry(const int entryNum,
                               const uintptr_t address,
                               const Dl_info* const dlInfo) {
    char faddrBuff[20];
    char saddrBuff[20];
    
    const char* fname = lx_lastPathEntry(dlInfo->dli_fname);
    if(fname == NULL) {
        sprintf(faddrBuff, POINTER_FMT, (uintptr_t)dlInfo->dli_fbase);
        fname = faddrBuff;
    }
    
    uintptr_t offset = address - (uintptr_t)dlInfo->dli_saddr;
    const char* sname = dlInfo->dli_sname;
    if(sname == NULL) {
        sprintf(saddrBuff, POINTER_SHORT_FMT, (uintptr_t)dlInfo->dli_fbase);
        sname = saddrBuff;
        offset = address - (uintptr_t)dlInfo->dli_fbase;
    }
    return [NSString stringWithFormat:@"%-30s  0x%08" PRIxPTR " %s + %lu\n" ,fname, (uintptr_t)address, sname, offset];
}

const char* lx_lastPathEntry(const char* const path) {
    if(path == NULL) {
        return NULL;
    }
    
    char* lastFile = strrchr(path, '/');
    return lastFile == NULL ? path : lastFile + 1;
}

#pragma -mark HandleMachineContext
bool lx_fillThreadStateIntoMachineContext(thread_t thread, _STRUCT_MCONTEXT *machineContext) {
    mach_msg_type_number_t state_count = LX_THREAD_STATE_COUNT;
    kern_return_t kr = thread_get_state(thread, LX_THREAD_STATE, (thread_state_t)&machineContext->__ss, &state_count);
    return (kr == KERN_SUCCESS);
}

uintptr_t lx_mach_framePointer(mcontext_t const machineContext){
    return machineContext->__ss.LX_FRAME_POINTER;
}

uintptr_t lx_mach_stackPointer(mcontext_t const machineContext){
    return machineContext->__ss.LX_STACK_POINTER;
}

uintptr_t lx_mach_instructionAddress(mcontext_t const machineContext){
    return machineContext->__ss.LX_INSTRUCTION_ADDRESS;
}

uintptr_t lx_mach_linkRegister(mcontext_t const machineContext){
#if defined(__i386__) || defined(__x86_64__)
    return 0;
#else
    return machineContext->__ss.__lr;
#endif
}

kern_return_t lx_mach_copyMem(const void *const src, void *const dst, const size_t numBytes){
    vm_size_t bytesCopied = 0;
    return vm_read_overwrite(mach_task_self(), (vm_address_t)src, (vm_size_t)numBytes, (vm_address_t)dst, &bytesCopied);
}

#pragma -mark Symbolicate
void lx_symbolicate(const uintptr_t* const backtraceBuffer,
                    Dl_info* const symbolsBuffer,
                    const int numEntries,
                    const int skippedEntries){
    int i = 0;
    
    if(!skippedEntries && i < numEntries) {
        lx_dladdr(backtraceBuffer[i], &symbolsBuffer[i]);
        i++;
    }
    
    for(; i < numEntries; i++) {
        lx_dladdr(CALL_INSTRUCTION_FROM_RETURN_ADDRESS(backtraceBuffer[i]), &symbolsBuffer[i]);
    }
}

bool lx_dladdr(const uintptr_t address, Dl_info* const info) {
    info->dli_fname = NULL;
    info->dli_fbase = NULL;
    info->dli_sname = NULL;
    info->dli_saddr = NULL;
    
    const uint32_t idx = lx_imageIndexContainingAddress(address);
    if(idx == UINT_MAX) {
        return false;
    }
    const struct mach_header* header = _dyld_get_image_header(idx);
    const uintptr_t imageVMAddrSlide = (uintptr_t)_dyld_get_image_vmaddr_slide(idx);
    const uintptr_t addressWithSlide = address - imageVMAddrSlide;
    const uintptr_t segmentBase = lx_segmentBaseOfImageIndex(idx) + imageVMAddrSlide;
    if(segmentBase == 0) {
        return false;
    }
    
    info->dli_fname = _dyld_get_image_name(idx);
    info->dli_fbase = (void*)header;
    // Find symbol tables and get whichever symbol is closet to the address.
    // Find symbol tables and get whichever symbol is closest to the address.
    const LX_NLIST* bestMatch = NULL;
    uintptr_t bestDistance = ULONG_MAX;
    uintptr_t cmdPtr = lx_firstCmdAfterHeader(header);
    if(cmdPtr == 0) {
        return false;
    }
    for(uint32_t iCmd = 0; iCmd < header->ncmds; iCmd++) {
        const struct load_command* loadCmd = (struct load_command*)cmdPtr;
        if(loadCmd->cmd == LC_SYMTAB) {
            const struct symtab_command* symtabCmd = (struct symtab_command*)cmdPtr;
            const LX_NLIST* symbolTable = (LX_NLIST*)(segmentBase + symtabCmd->symoff);
            const uintptr_t stringTable = segmentBase + symtabCmd->stroff;
            
            for(uint32_t iSym = 0; iSym < symtabCmd->nsyms; iSym++) {
                // If n_value is 0, the symbol refers to an external object.
                if(symbolTable[iSym].n_value != 0) {
                    uintptr_t symbolBase = symbolTable[iSym].n_value;
                    uintptr_t currentDistance = addressWithSlide - symbolBase;
                    if((addressWithSlide >= symbolBase) &&
                       (currentDistance <= bestDistance)) {
                        bestMatch = symbolTable + iSym;
                        bestDistance = currentDistance;
                    }
                }
            }
            if(bestMatch != NULL) {
                info->dli_saddr = (void*)(bestMatch->n_value + imageVMAddrSlide);
                info->dli_sname = (char*)((intptr_t)stringTable + (intptr_t)bestMatch->n_un.n_strx);
                if(*info->dli_sname == '_') {
                    info->dli_sname++;
                }
                // This happens if all symbols have been stripped.
                if(info->dli_saddr == info->dli_fbase && bestMatch->n_type == 3) {
                    info->dli_sname = NULL;
                }
                break;
            }
        }
        cmdPtr += loadCmd->cmdsize;
    }
    return true;
}

uintptr_t lx_firstCmdAfterHeader(const struct mach_header* const header) {
    switch(header->magic) {
        case MH_MAGIC:
        case MH_CIGAM:
            return (uintptr_t)(header + 1);
        case MH_MAGIC_64:
        case MH_CIGAM_64:
            return (uintptr_t)(((struct mach_header_64*)header) + 1);
        default:
            return 0;  // Header is corrupt
    }
}

uint32_t lx_imageIndexContainingAddress(const uintptr_t address) {
    const uint32_t imageCount = _dyld_image_count();
    const struct mach_header* header = 0;
    
    for(uint32_t iImg = 0; iImg < imageCount; iImg++) {
        header = _dyld_get_image_header(iImg);
        if(header != NULL) {
            // Look for a segment command with this address within its range.
            uintptr_t addressWSlide = address - (uintptr_t)_dyld_get_image_vmaddr_slide(iImg);
            uintptr_t cmdPtr = lx_firstCmdAfterHeader(header);
            if(cmdPtr == 0) {
                continue;
            }
            for(uint32_t iCmd = 0; iCmd < header->ncmds; iCmd++) {
                const struct load_command* loadCmd = (struct load_command*)cmdPtr;
                if(loadCmd->cmd == LC_SEGMENT) {
                    const struct segment_command* segCmd = (struct segment_command*)cmdPtr;
                    if(addressWSlide >= segCmd->vmaddr &&
                       addressWSlide < segCmd->vmaddr + segCmd->vmsize) {
                        return iImg;
                    }
                }
                else if(loadCmd->cmd == LC_SEGMENT_64) {
                    const struct segment_command_64* segCmd = (struct segment_command_64*)cmdPtr;
                    if(addressWSlide >= segCmd->vmaddr &&
                       addressWSlide < segCmd->vmaddr + segCmd->vmsize) {
                        return iImg;
                    }
                }
                cmdPtr += loadCmd->cmdsize;
            }
        }
    }
    return UINT_MAX;
}

uintptr_t lx_segmentBaseOfImageIndex(const uint32_t idx) {
    const struct mach_header* header = _dyld_get_image_header(idx);
    
    // Look for a segment command and return the file image address.
    uintptr_t cmdPtr = lx_firstCmdAfterHeader(header);
    if(cmdPtr == 0) {
        return 0;
    }
    for(uint32_t i = 0;i < header->ncmds; i++) {
        const struct load_command* loadCmd = (struct load_command*)cmdPtr;
        if(loadCmd->cmd == LC_SEGMENT) {
            const struct segment_command* segmentCmd = (struct segment_command*)cmdPtr;
            if(strcmp(segmentCmd->segname, SEG_LINKEDIT) == 0) {
                return segmentCmd->vmaddr - segmentCmd->fileoff;
            }
        }
        else if(loadCmd->cmd == LC_SEGMENT_64) {
            const struct segment_command_64* segmentCmd = (struct segment_command_64*)cmdPtr;
            if(strcmp(segmentCmd->segname, SEG_LINKEDIT) == 0) {
                return (uintptr_t)(segmentCmd->vmaddr - segmentCmd->fileoff);
            }
        }
        cmdPtr += loadCmd->cmdsize;
    }
    return 0;
}

uintptr_t lx_get_load_address(void) {
    const struct mach_header *exe_header = NULL;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const struct mach_header *header = _dyld_get_image_header(i);
        if (header->filetype == MH_EXECUTE) {
            exe_header = header;
            break;
        }
    }
    
    return (uintptr_t)exe_header;
}
//_dyld_get_image_vmaddr_slide

uintptr_t lx_get_slide_address(void) {
    uintptr_t vmaddr_slide = (uintptr_t)NULL;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const struct mach_header *header = _dyld_get_image_header(i);
        if (header->filetype == MH_EXECUTE) {
            vmaddr_slide = _dyld_get_image_vmaddr_slide(i);
            break;
        }
    }
    
    return (uintptr_t)vmaddr_slide;
}

NSString *lx_get_dSYM_UUID(void){
    const struct mach_header *executableHeader = NULL;
    for (uint32_t i = 0; i < _dyld_image_count(); i++)
    {
        const struct mach_header *header = _dyld_get_image_header(i);
        if (header->filetype == MH_EXECUTE)
        {
            executableHeader = header;
            break;
        }
    }
    
    if (!executableHeader)
        return nil;
    
    BOOL is64bit = executableHeader->magic == MH_MAGIC_64 || executableHeader->magic == MH_CIGAM_64;
    uintptr_t cursor = (uintptr_t)executableHeader + (is64bit ? sizeof(struct mach_header_64) : sizeof(struct mach_header));
    const struct segment_command *segmentCommand = NULL;
    for (uint32_t i = 0; i < executableHeader->ncmds; i++, cursor += segmentCommand->cmdsize)
    {
        segmentCommand = (struct segment_command *)cursor;
        if (segmentCommand->cmd == LC_UUID)
        {
            const struct uuid_command *uuidCommand = (const struct uuid_command *)segmentCommand;
            NSUUID *nsUUID = [[NSUUID alloc] initWithUUIDBytes:uuidCommand->uuid];
            
            return nsUUID.UUIDString;
        }
    }
    
    return nil;
}

NSArray *lx_baseAddressInfo(void){
    NSMutableArray *ret = [NSMutableArray array];
    [ret addObject:[NSString stringWithFormat:@"Base Address:0x%lx",(uintptr_t)lx_get_load_address()]];
    [ret addObject:[NSString stringWithFormat:@"dSYM UUID:%@",lx_get_dSYM_UUID()]];
    [ret addObject:[NSString stringWithFormat:@"Slide Address:0x%lx",(uintptr_t)lx_get_slide_address()]];
    
    return ret;
}




@end

