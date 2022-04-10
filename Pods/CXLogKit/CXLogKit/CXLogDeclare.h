//
//  CXLogDeclare.h
//  CXLog
//
//  Created by 李笑清 on 2020/7/12.
//  Copyright © 2020 李笑清. All rights reserved.
//

#ifndef CXLogDeclare_h
#define CXLogDeclare_h

//设置日志打印级别
typedef NS_ENUM(int,CXLogLevel) {
    CXLogLevelAll = 0,
    CXLogLevelVerbose = 0,
    CXLogLevelDebug,    // Detailed information on the flow through the system.
    CXLogLevelInfo,     // Interesting runtime events (startup/shutdown), should be conservative and keep to a minimum.
    CXLogLevelWarn,     // Other runtime situations that are undesirable or unexpected, but not necessarily "wrong".
    CXLogLevelError,    // Other runtime errors or unexpected conditions.
    CXLogLevelFatal,    // Severe errors that cause premature termination.
    CXLogLevelNone,     // Special level used to disable all log messages.

};

//设置日志打印是同步还是异步，Debug模式不作要求，release版本一定要用异步的方式，因为同步可能导致卡顿
typedef NS_ENUM(int,CXAppenderMode) {
    CXAppednerAsync,   //打印异步添加到日志
    CXAppednerSync,    //打印同步添加到日志
};

#endif /* CXLogDeclare_h */
