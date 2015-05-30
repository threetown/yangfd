//
//  CUTEImageUploader.m
//  currant
//
//  Created by Foster Yin on 4/17/15.
//  Copyright (c) 2015 Foster Yin. All rights reserved.
//

#import "CUTEImageUploader.h"
#import <Bolts.h>
#import <BBTRestClient.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CUTEConfiguration.h"
#import "CUTEDataManager.h"
#import "CUTECommonMacro.h"
#import "AssetsLibraryProvider.h"
#import <UIImage+Resize.h>
#import "UIImage+FixJPEGRotation.h"
#import "NSURL+Assets.h"
#import <NSArray+ObjectiveSugar.h>
#import "ALAsset+GetImage.h"
#import "UIImage+CalculatedSize.h"

@interface CUTEImageUploader () {

    BBTRestClient *_imageUploader;

    NSMutableDictionary *_requestTaskDictionary;
}

@end

@implementation CUTEImageUploader

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred;
    __strong static id sharedInstance = nil;

    dispatch_once(&pred, ^{
        sharedInstance = [[[self class] alloc] init];
    });

    return sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageUploader = [BBTRestClient clientWithBaseURL:[NSURL URLWithString:[CUTEConfiguration apiEndpoint]] account:nil];
        _imageUploader.operationQueue.maxConcurrentOperationCount = 1; // send image one by one by network bindwidth no enough in network
        _requestTaskDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}


//http://stackoverflow.com/questions/8042360/nsdata-and-uploading-images-via-post-in-ios
- (NSURLRequest *)makeUploadRequestWithURL:(NSURL*)url data:(NSData *)imageData {
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:120];
    [request setHTTPMethod:@"POST"];

    NSString *boundary = @"-------CUTEboundary------";
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];

    // post body
    NSMutableData *body = [NSMutableData data];

    //http://stackoverflow.com/questions/8564833/ios-upload-image-and-text-using-http-post
    NSDictionary *params = @{@"watermark": @"True"};
    // add params (all params are strings)
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", @"data"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    // setting the body of the post to the reqeust
    [request setHTTPBody:body];

    // set URL
    [request setURL:url];
    return request;
}

#define MAX_IMAGE_PIXEL 2048

-  (BFTask *)getImageDataWithAssetURLString:(NSString *)assetURLStr {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        [[AssetsLibraryProvider sharedInstance].assetsLibrary assetForURL:[NSURL URLWithString:assetURLStr] resultBlock:^(ALAsset *asset) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                UIImage *image = [asset thumbnailForWithMaxPixelSize:MAX_IMAGE_PIXEL];
                if (image) {
                    //TODO dynamic choose compressionQuality base image file size
                    NSData *imageData = UIImageJPEGRepresentation(image, 1);
                    [tcs setResult:imageData];
                }
                else {
                    [tcs setError:[NSError errorWithDomain:@"CUTE" code:-1 userInfo:@{NSLocalizedDescriptionKey: STR(@"图片读取失败")}]];
                }
            });
        } failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [tcs setError:error];
            });
        }];
    });
    return tcs.task;
}

- (BFTask *)uploadImageWithAssetURLString:(NSString*)assetURLStr {
    if (_requestTaskDictionary[assetURLStr]) {
        return [_requestTaskDictionary objectForKey:assetURLStr];
    }

    if (!IsNilNullOrEmpty(assetURLStr)) {
        NSString *urlStr = [[CUTEDataManager sharedInstance] getImageURLStringForAssetURLString:assetURLStr];
        if (!IsNilNullOrEmpty(urlStr)) {
            return [BFTask taskWithResult:urlStr];
        }
    }

    BFTask *task = [[self getImageDataWithAssetURLString:assetURLStr] continueWithBlock:^id(BFTask *task) {
        if (task.error || task.exception || task.isCancelled) {
            return task;
        }
        else {
            NSData *imageData = task.result;
            BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
            if (imageData) {
                [_imageUploader.operationQueue addOperation: [_imageUploader HTTPRequestOperationWithRequest:[self makeUploadRequestWithURL:[NSURL URLWithString:@"/api/1/upload_image" relativeToURL:[CUTEConfiguration uploadHostURL]] data:imageData] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSDictionary *responseDic = (NSDictionary *)responseObject;
                    if ([[responseDic objectForKey:@"ret"] integerValue] == 0) {
                        NSString *urlStr = responseDic[@"val"][@"url"];
                        [[CUTEDataManager sharedInstance] saveImageURLString:urlStr forAssetURLString:assetURLStr];
                        [[CUTEDataManager sharedInstance] saveAssetURLString:assetURLStr forImageURLString:urlStr];
                        [_requestTaskDictionary removeObjectForKey:assetURLStr];
                        [tcs setResult:urlStr];
                    }
                    else {
                        [_requestTaskDictionary removeObjectForKey:assetURLStr];
                        [tcs setError:[NSError errorWithDomain:responseDic[@"msg"] code:[[responseDic objectForKey:@"ret"] integerValue] userInfo:responseDic]];
                    }

                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [tcs setError:error];
                }]];
            }
            else {
                [tcs setResult:nil];
            }
            return tcs.task;
        }
    }];

    [_requestTaskDictionary setObject:task forKey:assetURLStr];
    return task;
}

- (BFTask *)getAssetsOrNullsFromURLArray:(NSArray *)array {
    return [BFTask taskForCompletionOfAllTasksWithResults:[array map:^id(NSString *object) {
        return [self getAssetOrNullFromURL:object];
        }
    ]];
}

- (BFTask *)getAssetOrNullFromURL:(NSString *)object {
    NSURL *url = [NSURL URLWithString:object];
    if (![url isAssetURL]) {
        NSString *assetString = [[CUTEDataManager sharedInstance] getAssetURLStringForImageURLString:object];
        url = [NSURL URLWithString:assetString];
    }

    if ([url isAssetURL]) {
        BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            [[[AssetsLibraryProvider sharedInstance] assetsLibrary] assetForURL:url resultBlock:^(ALAsset *asset) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [tcs setResult:asset];
                });
            } failureBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [tcs setError:error];
                });
            }];
        });
        return tcs.task;

    }
    else {
        return [BFTask taskWithResult:[NSNull null]];
    }
}

@end
