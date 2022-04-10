//
//  LXNetworkBandwidth.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/7.
//

#import "LXNetworkBandwidth.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <netinet/in.h>
#import <netinet/in_systm.h>

#import "LXNetworkInfo.h"

static NSString *kLXInterfaceWiFi = @"en0";
static NSString *kLXInterfaceWWAN = @"pdp_ip0";
static NSString *kLXInterfaceNone = @"";

@interface LXNetworkBandwidth()

@property (nonatomic, copy)   NSString      *currentInterface;

@property (nonatomic, assign) SCNetworkReachabilityRef reachability;
@property (nonatomic, strong) CTTelephonyNetworkInfo *telephonyNetworkInfo;

@end

@implementation LXNetworkBandwidth

- (instancetype)init{
    self = [super init];
    if (self) {
        self.timestamp = [[NSDate date] timeIntervalSince1970];
        
        do {
            int mib[] = {
                CTL_NET,
                PF_ROUTE,
                0,
                0,
                NET_RT_IFLIST2,
                0
            };
            
            size_t len;
            if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0)
            {
                break;
            }
            
            char *buf = malloc(len);
            if (!buf)
            {
                break;
            }
            
            if (sysctl(mib, 6, buf, &len, NULL, 0) < 0)
            {
                free(buf);
                break;
            }
            char *lim = buf + len;
            char *next = NULL;
            for (next = buf; next < lim; )
            {
                struct if_msghdr *ifm = (struct if_msghdr *)next;
                next += ifm->ifm_msglen;
                
                /* iOS does't include <net/route.h>, so we define our own macros. */
    #define RTM_IFINFO2 0x12
                if (ifm->ifm_type == RTM_IFINFO2)
    #undef RTM_IFINFO2
                {
                    struct if_msghdr2 *if2m = (struct if_msghdr2 *)ifm;
                    
                    char ifnameBuf[IF_NAMESIZE];
                    if (!if_indextoname(ifm->ifm_index, ifnameBuf))
                    {
                        continue;
                    }
                    NSString *ifname = [NSString stringWithCString:ifnameBuf encoding:NSASCIIStringEncoding];
                    
                    if ([ifname isEqualToString:kLXInterfaceWiFi])
                    {
                        self.totalWiFiSent += if2m->ifm_data.ifi_obytes;
                        self.totalWiFiReceived += if2m->ifm_data.ifi_ibytes;
                    }
                    else if ([ifname isEqualToString:kLXInterfaceWWAN])
                    {
                        self.totalWWANSent += if2m->ifm_data.ifi_obytes;
                        self.totalWWANReceived += if2m->ifm_data.ifi_ibytes;
                    }
                }
            }
            
            free(buf);
        }while(0);
    }
    
    return self;
}

- (void)dealloc{
    if (self.reachability)
    {
        CFRelease(self.reachability);
    }
}

#pragma mark - private methods

static void reachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
    assert(info != NULL);
    assert([(__bridge NSObject*)(info) isKindOfClass:[LXNetworkBandwidth class]]);
    
    LXNetworkBandwidth *networkCtrl = (__bridge LXNetworkBandwidth*)(info);
    [networkCtrl reachabilityStatusChangedCB];
}

- (void)initReachability{
    if (!self.reachability){
        struct sockaddr_in hostAddress;
        bzero(&hostAddress, sizeof(hostAddress));
        hostAddress.sin_len = sizeof(hostAddress);
        hostAddress.sin_family = AF_INET;
        
        self.reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&hostAddress);
        
        if (!self.reachability){
            NSLog(@"reachability create has failed.");
            return;
        }
        
        BOOL result;
        SCNetworkReachabilityContext context = { 0, (__bridge void *)self, NULL, NULL, NULL };
        
        result = SCNetworkReachabilitySetCallback(self.reachability, reachabilityCallback, &context);
        if (!result)
        {
            NSLog(@"error setting reachability callback.");
            return;
        }
        
        result = SCNetworkReachabilityScheduleWithRunLoop(self.reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        if (!result)
        {
            NSLog(@"error setting runloop mode.");
            return;
        }
    }
}

- (void)reachabilityStatusChangedCB
{
    [self populateNetworkInfo];
//    if ([[self delegate] respondsToSelector:@selector(networkStatusUpdated)])
//    {
//        [[self delegate] networkStatusUpdated];
//    }
}

- (LXNetworkInfo *)populateNetworkInfo
{
    self.currentInterface = [self internetInterface];
    
    return nil;
}

- (NSString*)readableCurrentInterface
{
    if (!self.currentInterface) {
        [self populateNetworkInfo];
    }
    
    if ([self.currentInterface isEqualToString:kLXInterfaceWiFi])
    {
        return @"WiFi";
    }
    else if ([self.currentInterface isEqualToString:kLXInterfaceWWAN]){
        static NSString *interfaceFormat = @"Cellular (%@)";
        NSString *currentRadioTechnology = [[self telephonyNetworkInfo] currentRadioAccessTechnology];
        
        if ([currentRadioTechnology isEqualToString:CTRadioAccessTechnologyLTE])
            return [NSString stringWithFormat:interfaceFormat, @"LTE"];
        if ([currentRadioTechnology isEqualToString:CTRadioAccessTechnologyEdge])
            return [NSString stringWithFormat:interfaceFormat, @"Edge"];
        if ([currentRadioTechnology isEqualToString:CTRadioAccessTechnologyGPRS])
            return [NSString stringWithFormat:interfaceFormat, @"GPRS"];
        if ([currentRadioTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x] ||
            [currentRadioTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
            [currentRadioTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
            [currentRadioTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB])
            return [NSString stringWithFormat:interfaceFormat, @"CDMA"];
        if ([currentRadioTechnology isEqualToString:CTRadioAccessTechnologyWCDMA])
            return [NSString stringWithFormat:interfaceFormat, @"W-CDMA"];
        if ([currentRadioTechnology isEqualToString:CTRadioAccessTechnologyeHRPD])
            return [NSString stringWithFormat:interfaceFormat, @"eHRPD"];
        if ([currentRadioTechnology isEqualToString:CTRadioAccessTechnologyHSDPA])
            return [NSString stringWithFormat:interfaceFormat, @"HSDPA"];
        if ([currentRadioTechnology isEqualToString:CTRadioAccessTechnologyHSUPA])
            return [NSString stringWithFormat:interfaceFormat, @"HSUPA"];
        
        // If technology is not known, keep it generic.
        return @"Cellular";
    }
    else
    {
        return @"Not Connected";
    }
}

- (NSString*)internetInterface{
    if (!self.reachability){
        [self initReachability];
    }
    
    if (!self.reachability){
        NSLog(@"cannot initialize reachability.");
        return kLXInterfaceNone;
    }
    
    SCNetworkReachabilityFlags flags;
    if (!SCNetworkReachabilityGetFlags(self.reachability, &flags)){
        NSLog(@"failed to retrieve reachability flags.");
        return kLXInterfaceNone;
    }
    
    if ((flags & kSCNetworkFlagsReachable) &&
        (!(flags & kSCNetworkReachabilityFlagsIsWWAN))){
        return kLXInterfaceWiFi;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) &&
        (flags & kSCNetworkReachabilityFlagsIsWWAN)){
        return kLXInterfaceWWAN;
    }
    
    return kLXInterfaceNone;
}

#pragma mark - getters
- (CTTelephonyNetworkInfo *)telephonyNetworkInfo{
    if (!_telephonyNetworkInfo) {
        _telephonyNetworkInfo = [CTTelephonyNetworkInfo new];
    }
    
    return _telephonyNetworkInfo;
}

- (NSString *)interface{
    if (!_interface) {
        [self populateNetworkInfo];
        _interface = [self currentInterface];
    }
    
    return _interface;
}

@end
