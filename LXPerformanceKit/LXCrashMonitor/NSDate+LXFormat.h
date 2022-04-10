//
//  NSDate+LXFormat.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (LXFormat)

+ (int64_t) nowAsMilliseconds;
- (int64_t) dateAsMilliseconds;
+ (NSDate *) dateFromMilliseconds:(int64_t) milliseconds;
+ (NSString *) stringFromMilliseconds:(int64_t) milliseconds;
+ (NSString*) unixTimestampAsString;
+ (int64_t) unixTimestampAsLong;



@end

NS_ASSUME_NONNULL_END
