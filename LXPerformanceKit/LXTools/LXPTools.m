//
//  LXPTools.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/22.
//

#import "LXPTools.h"

@implementation LXPTools

+ (NSString *)createUUID{
    NSString *uuid;
    
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    
    if (result) {
        NSString *res =  result;
        
        res = [res stringByReplacingOccurrencesOfString:@"-" withString:@""];
        res = [res stringByReplacingOccurrencesOfString:@" " withString:@""];
        res = [res lowercaseString];
        uuid = res;
    }
    
    if([uuid length] <= 0){
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SSS"];
        NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        formatter.locale = cnLocale;
        NSString *randStr = [formatter stringFromDate:date];
        randStr = [randStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        NSString *outputStr = @"1234567890abcdefghijklmnopqrstuvwxyz";
        while ([randStr length]<32) {
            int index  = arc4random() % outputStr.length;
            NSString *indexString = [outputStr substringWithRange:NSMakeRange(index, 1)];
            
            randStr = [randStr stringByAppendingString:indexString];
        }
        
        if ([randStr length]>32) {
            randStr = [randStr substringToIndex:32];
        }
        
        uuid = randStr;
    }
    
    return uuid;
}


@end
