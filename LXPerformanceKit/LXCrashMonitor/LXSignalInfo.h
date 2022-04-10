//
//  LXSignalInfo.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/9.
//

#ifndef LXSignalInfo_h
#define LXSignalInfo_h

#ifdef __cplusplus
extern "C" {
#endif
    
    
#include <mach/mach.h>
    
    
    /** Get the name of a signal.
     *
     * @param signal The signal.
     *
     * @return The signal's name or NULL if not found.
     */
    const char* lxsignal_signalName(int signal);
    
    /** Get the name of a signal's subcode.
     *
     * @param signal The signal.
     *
     * @param code The signal's code.
     *
     * @return The code's name or NULL if not found.
     */
    const char* lxsignal_signalCodeName(int signal, int code);
    
    /** Get a list of fatal signals.
     *
     * @return A list of fatal signals.
     */
    const int* lxsignal_fatalSignals(void);
    
    /** Get the size of the fatal signals list.
     *
     * @return The size of the fatal signals list.
     */
    int lxsignal_numFatalSignals(void);
    
    /** Get the signal equivalent of a mach exception.
     *
     * @param exception The mach exception.
     *
     * @param code The mach exception code.
     *
     * @return The matching signal, or 0 if not found.
     */
    int lxsignal_signalForMachException(int exception,
                                        mach_exception_code_t code);
    
    /** Get the mach exception equivalent of a signal.
     *
     * @param signal The signal.
     *
     * @return The matching mach exception, or 0 if not found.
     */
    int lxsignal_machExceptionForSignal(int signal);
    
    
#ifdef __cplusplus
}
#endif

#endif /* LXSignalInfo_h */
