//
//  LXNetworking.m
//  LXNetworkingDemo
//
//  Created by 刘鑫 on 16/4/5.
//  Copyright © 2016年 liuxin. All rights reserved.
//

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#import "LXNetworking.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "MBProgressHUD.h"


static NSMutableArray *tasks;
@implementation LXNetworking

+ (LXNetworking *)sharedLXNetworking
{
    static LXNetworking *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[LXNetworking alloc] init];
    });
    return handler;
}

+(NSMutableArray *)tasks{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DLog(@"创建数组");
        tasks = [[NSMutableArray alloc] init];
    });
    return tasks;
}

+(LXURLSessionTask *)getWithUrl:(NSString *)url
                         params:(NSDictionary *)params
                        success:(LXResponseSuccess)success
                           fail:(LXResponseFail)fail
                        showHUD:(BOOL)showHUD{
    
    return [self baseRequestType:1 url:url params:params success:success fail:fail showHUD:showHUD];
    
}

+(LXURLSessionTask *)postWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                         success:(LXResponseSuccess)success
                            fail:(LXResponseFail)fail
                         showHUD:(BOOL)showHUD{
   return [self baseRequestType:2 url:url params:params success:success fail:fail showHUD:showHUD];
}

+(LXURLSessionTask *)baseRequestType:(NSUInteger)type
                                 url:(NSString *)url
                              params:(NSDictionary *)params
                             success:(LXResponseSuccess)success
                                fail:(LXResponseFail)fail
                             showHUD:(BOOL)showHUD{
    DLog(@"请求地址----%@\n    请求参数----%@",url,params);
    if (url==nil) {
        return nil;
    }
    
    if (showHUD==YES) {
        [MBProgressHUD showHUD];
    }
    
    //检查地址中是否有中文
    NSString *urlStr=[NSURL URLWithString:url]?url:[self strUTF8Encoding:url];
    
    AFHTTPSessionManager *manager=[self getAFManager];
    
    LXURLSessionTask *sessionTask=nil;
    
    if (type==1) {
       sessionTask = [manager GET:urlStr parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            DLog(@"请求结果=%@",responseObject);
            if (success) {
                success(responseObject);
            }
            
            [[self tasks] removeObject:sessionTask];
            
            if (showHUD==YES) {
                [MBProgressHUD dissmiss];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            DLog(@"error=%@",error);
            if (fail) {
                fail(error);
            }
            
            [[self tasks] removeObject:sessionTask];
           
            if (showHUD==YES) {
                [MBProgressHUD dissmiss];
            }
            
        }];
        
    }else{
        
       sessionTask = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            DLog(@"请求成功=%@",responseObject);
            if (success) {
                success(responseObject);
            }
            
            [[self tasks] removeObject:sessionTask];
            
            if (showHUD==YES) {
                [MBProgressHUD dissmiss];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            DLog(@"error=%@",error);
            if (fail) {
                fail(error);
            }
            
            [[self tasks] removeObject:sessionTask];
            
            if (showHUD==YES) {
                [MBProgressHUD dissmiss];
            }
            
        }];
        
        
    }
    
    if (sessionTask) {
        [[self tasks] addObject:sessionTask];
    }
    
    return sessionTask;
    
}

+(LXURLSessionTask *)uploadWithImage:(UIImage *)image
                                 url:(NSString *)url
                            filename:(NSString *)filename
                                name:(NSString *)name
                              params:(NSDictionary *)params
                            progress:(LXUploadProgress)progress
                             success:(LXResponseSuccess)success
                                fail:(LXResponseFail)fail
                             showHUD:(BOOL)showHUD{
    
    DLog(@"请求地址----%@\n    请求参数----%@",url,params);
    if (url==nil) {
        return nil;
    }
    
    if (showHUD==YES) {
        [MBProgressHUD showHUD];
    }
    
    //检查地址中是否有中文
    NSString *urlStr=[NSURL URLWithString:url]?url:[self strUTF8Encoding:url];
    
    AFHTTPSessionManager *manager=[self getAFManager];
    
    LXURLSessionTask *sessionTask = [manager POST:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //压缩图片
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        
        NSString *imageFileName = filename;
        if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
        }
        
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        DLog(@"上传进度--%lld,总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DLog(@"上传图片成功=%@",responseObject);
        if (success) {
            success(responseObject);
        }
        
        [[self tasks] removeObject:sessionTask];
        
        if (showHUD==YES) {
            [MBProgressHUD dissmiss];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DLog(@"error=%@",error);
        if (fail) {
            fail(error);
        }
        
        [[self tasks] removeObject:sessionTask];
        
        if (showHUD==YES) {
            [MBProgressHUD dissmiss];
        }
        
    }];
    
    
    if (sessionTask) {
        [[self tasks] addObject:sessionTask];
    }
    
    return sessionTask;

    
}

+ (LXURLSessionTask *)downloadWithUrl:(NSString *)url
                            saveToPath:(NSString *)saveToPath
                              progress:(LXDownloadProgress)progressBlock
                               success:(LXResponseSuccess)success
                               failure:(LXResponseFail)fail
                               showHUD:(BOOL)showHUD{

    
    DLog(@"请求地址----%@\n    ",url);
    if (url==nil) {
        return nil;
    }
    
    if (showHUD==YES) {
        [MBProgressHUD showHUD];
    }
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPSessionManager *manager = [self getAFManager];
    
    LXURLSessionTask *sessionTask = nil;
    
    sessionTask = [manager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        DLog(@"下载进度--%.2f",1.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
        //回到主线程刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock) {
                progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (!saveToPath) {
            
            NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            DLog(@"默认路径--%@",downloadURL);
            return [downloadURL URLByAppendingPathComponent:[response suggestedFilename]];
            
        }else{
            return [NSURL fileURLWithPath:saveToPath];
        
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        DLog(@"下载文件成功");

        [[self tasks] removeObject:sessionTask];
        
        if (error == nil) {
            if (success) {
                success([filePath path]);//返回完整路径
            }
           
        } else {
            if (fail) {
                fail(error);
            }
        }
        
        if (showHUD==YES) {
            [MBProgressHUD dissmiss];
        }
        
    }];
    
    //开始启动任务
    [sessionTask resume];
    if (sessionTask) {
        [[self tasks] addObject:sessionTask];
    }
    
    return sessionTask;
    
    
}

+(AFHTTPSessionManager *)getAFManager{
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPSessionManager *manager = manager = [AFHTTPSessionManager manager];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];//设置请求数据为json
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//设置返回数据为json
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.requestSerializer.timeoutInterval=10;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    

    return manager;

}

#pragma makr - 开始监听网络连接

+ (void)startMonitoring
{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                DLog(@"未知网络");
                [LXNetworking sharedLXNetworking].networkStats=StatusUnknown;
                
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                DLog(@"没有网络");
                [LXNetworking sharedLXNetworking].networkStats=StatusNotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                DLog(@"手机自带网络");
                [LXNetworking sharedLXNetworking].networkStats=StatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                
                [LXNetworking sharedLXNetworking].networkStats=StatusReachableViaWiFi;
                DLog(@"WIFI--%d",[LXNetworking sharedLXNetworking].networkStats);
                break;
        }
    }];
    [mgr startMonitoring];
}


+(NSString *)strUTF8Encoding:(NSString *)str{
    //return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end
