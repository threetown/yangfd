//
//  CUTEConfiguration.m
//  currant
//
//  Created by Foster Yin on 3/24/15.
//  Copyright (c) 2015 Foster Yin. All rights reserved.
//

#import "CUTEConfiguration.h"
#import "CUTECommonMacro.h"

@implementation CUTEConfiguration

static NSString *host = nil;
+ (NSString *)host {
    if (!host) {
        host = [[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CurrantHost"] copy];
    }
    return host;
}

+ (void)setHost:(NSString *)theHost {
    host = theHost;
}

+ (NSURL *)hostURL {
    return [NSURL URLWithString:CONCAT(@"https://", [self host])];
}

+ (NSString *)yangfdScheme {
    return @"yangfd";
}

+ (NSString *)ukServicePhone {
    return @"02030402258";
}

+ (NSString *)servicePhone {
    return @"4008299318";
}

+ (NSString *)apiEndpoint {
    return CONCAT(@"https://", [self host], @"/api/1/");
}

+ (NSString *)appStoreId {
    return @"980469674";
}

+ (NSString *)googleAPIKey {
    return @"AIzaSyCXOb8EoLnYOCsxIFRV-7kTIFsX32cYpYU";
}

+ (NSString *)weixinAPPId {
    return @"wxa8e7919a58064daa";
}

+ (NSString *)sinaAppKey {
    return @"3185958365";
}

+ (NSString *)umengAppKey {
    return @"557173da67e58e9316003733";
}

+ (NSString *)umengCallbackURLString {
    return @"http://sns.whalecloud.com/sina2/callback";
}


//http://stackoverflow.com/questions/7608632/how-do-i-get-the-current-version-of-my-ios-project-in-code
+ (NSString *) appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

+ (NSString *) build
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}

+ (NSString *) versionBuild
{
    NSString * version = [self appVersion];
    NSString * build = [self build];

    NSString * versionBuild = [NSString stringWithFormat: @"v%@", version];

    if (![version isEqualToString: build]) {
        versionBuild = [NSString stringWithFormat: @"%@(%@)", versionBuild, build];
    }

    return versionBuild;
}

+ (BOOL)enableMultipleLanguage {
    return NO;
}

+ (BOOL)enableAPNS {
    return NO;
}

+ (BOOL)enableFabric {
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    return [[appInfo objectForKey:@"CurrantChannel"] isEqualToString:@"production"];
}

+ (BOOL)enableBugtags {
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    return ![[appInfo objectForKey:@"CurrantChannel"] isEqualToString:@"production"];
}

@end
