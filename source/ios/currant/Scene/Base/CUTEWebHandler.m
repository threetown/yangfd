//
//  CUTEWebHandler.m
//  currant
//
//  Created by Foster Yin on 6/27/15.
//  Copyright (c) 2015 Foster Yin. All rights reserved.
//

#import "CUTEWebHandler.h"
#import "CUTETracker.h"
#import "CUTEUser.h"
#import "CUTEDataManager.h"
#import "CUTEWebViewController.h"
#import "NSString+Encoding.h"
#import "CUTECommonMacro.h"
#import "CUTENotificationKey.h"
#import "NSURL+QueryParser.h"
#import "CUTEConfiguration.h"
#import "CUTEUsageRecorder.h"
#import "CUTESurveyHelper.h"
#import "CUTEApptentiveEvent.h"
#import "ATConnect.h"
#import "CUTEShareManager.h"

@implementation CUTEWebHandler


//TODO JS-Native api call need version control, for html host on remote, not sync with current code
- (void)setupWithWebView:(UIWebView *)webView viewController:(CUTEWebViewController *)webViewController {

    [self.bridge registerHandler:@"handshake" handler:^(id data, WVJBResponseCallback responseCallback) {
        TrackEvent(KEventCategorySystem, @"handshake", webView.request.URL.absoluteString, nil);
    }];

    [self.bridge registerHandler:@"login" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *dic = data;
        CUTEUser *user = nil;
        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            NSError *error = nil;
            user = (CUTEUser *)[MTLJSONAdapter modelOfClass:[CUTEUser class] fromJSONDictionary:dic error:&error];
        }

        if (user && [user isKindOfClass:[CUTEUser class]]) {
            UIView *view = [webViewController view];
            if (!IsArrayNilOrEmpty(view.subviews) && [[view subviews][0] isKindOfClass:[UIWebView class]]) {
                UIWebView *webView = (UIWebView *)[view subviews][0];
                NSURL *url = [[webView request] URL];
                NSDictionary *queryDictionary = [url queryDictionary];
                if (queryDictionary && queryDictionary[@"from"]) {
                    NSString *fromURLStr = [queryDictionary[@"from"] URLDecode];
                    //update user data and cookie storage first
                    [NotificationCenter postNotificationName:KNOTIF_USER_DID_LOGIN object:webViewController userInfo:@{@"user": user}];
                    //then update webview
                    [webViewController updateWithURL:[NSURL URLWithString:fromURLStr]];
                    responseCallback(nil);
                }
            }
        }
    }];

    [self.bridge registerHandler:@"logout" handler:^(id data, WVJBResponseCallback responseCallback) {

        [[CUTEDataManager sharedInstance] clearAllCookies];
        [[CUTEDataManager sharedInstance] clearUser];
        UIView *view = [webViewController view];
        if (!IsArrayNilOrEmpty(view.subviews) && [[view subviews][0] isKindOfClass:[UIWebView class]]) {
            NSURL *url = [NSURL URLWithString:data relativeToURL:[CUTEConfiguration hostURL]];
            NSDictionary *queryDictionary = [url queryDictionary];
            if (queryDictionary && queryDictionary[@"return_url"]) {
                [webViewController updateWithURL:[NSURL URLWithString:CONCAT([queryDictionary[@"return_url"] URLDecode], @"?from=", [webViewController.url.absoluteString URLEncode]? : @"/") relativeToURL:[CUTEConfiguration hostURL]]];
                [NotificationCenter postNotificationName:KNOTIF_USER_DID_LOGOUT object:webViewController];
            }
        }
    }];

    [self.bridge registerHandler:@"editRentTicket" handler:^(id data, WVJBResponseCallback responseCallback) {

        NSDictionary *dic = data;
        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            NSError *error = nil;
            CUTETicket *ticket = (CUTETicket *)[MTLJSONAdapter modelOfClass:[CUTETicket class] fromJSONDictionary:dic error:&error];
            if (!error && ticket) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIF_TICKET_EDIT object:webViewController userInfo:@{@"ticket": ticket}];
            }
        }
    }];

    [self.bridge registerHandler:@"createRentTicket" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIF_TICKET_CREATE object:webViewController userInfo:nil];
    }];

    [self.bridge registerHandler:@"shareRentTicket" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *dic = data;
        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            NSError *error = nil;
            CUTETicket *ticket = (CUTETicket *)[MTLJSONAdapter modelOfClass:[CUTETicket class] fromJSONDictionary:dic error:&error];
            if (!error && ticket) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIF_TICKET_WECHAT_SHARE object:self userInfo:@{@"ticket": ticket}];
            }
        }
    }];

    [self.bridge registerHandler:@"share" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *dic = data;
        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            [[[CUTEShareManager sharedInstance] shareText:dic[@"text"] urlString:dic[@"url"] inServices:dic[@"services"] viewController:webViewController onButtonPressBlock:^(NSString *buttonName) {
                if ([buttonName isEqualToString:CUTEShareServiceWechatFriend]) {
                    TrackEvent(KEventCategoryShare, kEventActionPress, @"wechat-friend", @(1));
                }
                else if ([buttonName isEqualToString:CUTEShareServiceWechatCircle]) {
                    TrackEvent(KEventCategoryShare, kEventActionPress, @"wechat-circle", @(1));
                }
                else if ([buttonName isEqualToString:CUTEShareServiceSinaWeibo]) {
                    TrackEvent(KEventCategoryShare, kEventActionPress, @"weibo", @(1));
                }
            }] continueWithBlock:^id(BFTask *task) {
                if (task.error) {
                    responseCallback(@{@"msg":@"error"});
                }
                else if (task.exception) {

                }
                else if (task.isCancelled) {
                    responseCallback(@{@"msg":@"cancel"});
                }
                else {
                    responseCallback(@{@"msg":@"ok"});
                }
                
                return task;
            }];
        }
    }];

    //TODO remove this action in html files, this has been updated by the delegate hook
    [self.bridge registerHandler:@"openURLInNewController" handler:^(id data, WVJBResponseCallback responseCallback) {
        [webViewController loadRequesetInNewController:[NSURLRequest requestWithURL:[NSURL URLWithString:data relativeToURL:[CUTEConfiguration hostURL]]]];
    }];

    [self.bridge registerHandler:@"openHomeTab" handler:^(id data, WVJBResponseCallback responseCallback) {
        [NotificationCenter postNotificationName:KNOTIF_SHOW_HOME_TAB object:webViewController];
    }];

    [self.bridge registerHandler:@"openRentListTab" handler:^(id data, WVJBResponseCallback responseCallback) {
        [NotificationCenter postNotificationName:KNOTIF_SHOW_RENT_TICKET_LIST_TAB object:webViewController];
    }];

    [self.bridge registerHandler:@"openPropertyListTab" handler:^(id data, WVJBResponseCallback responseCallback) {
        [NotificationCenter postNotificationName:KNOTIF_SHOW_PROPERTY_LIST_TAB object:webViewController];
    }];

    [self.bridge registerHandler:@"notifyRentTicketIsRented" handler:^(id data, WVJBResponseCallback responseCallback) {
        [CUTESurveyHelper checkShowRentTicketDidBeRentedSurveyWithViewController:webViewController];
    }];

    [self.bridge registerHandler:@"notifyRentTicketIsDeleted" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *dic = data;
        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            NSError *error = nil;
            CUTETicket *ticket = (CUTETicket *)[MTLJSONAdapter modelOfClass:[CUTETicket class] fromJSONDictionary:dic error:&error];
            if (!error && ticket) {
                [[CUTEDataManager sharedInstance] markRentTicketDeleted:ticket];
                [NotificationCenter postNotificationName:KNOTIF_TICKET_LIST_RELOAD object:webViewController];
            }
        }
    }];

    [self.bridge registerHandler:@"notifyLoadFavoriteRentTicket" handler:^(id data, WVJBResponseCallback responseCallback) {
        [CUTESurveyHelper checkShowFavoriteRentTicketSurveyWithViewController:webViewController data:data];
    }];
}

@end
