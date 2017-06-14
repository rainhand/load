//
//  NetRequestTool.m
//  封装AFN
//
//  Created by 郭超 on 2017/6/8.
//  Copyright © 2017年 郭超. All rights reserved.
//

#import "NetRequestTool.h"
#import <AFNetworking.h>
static  AFHTTPSessionManager * manage;//创建成单利

@interface NetRequestTool()
@property(nonatomic, copy)NSString * url;

@end
@implementation NetRequestTool

//创建单利
+(instancetype)shareHttpsRequest
{
    static NetRequestTool * requestTool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestTool = [[NetRequestTool alloc]initWithRequest];

    });
    return requestTool;
}

-(instancetype)initWithRequest
{
    if (self =[super init]) {
      
    }
    return self;
}

//监测网络
+(ReachType)reachStatus{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    
    if (status==AFNetworkReachabilityStatusNotReachable) {
        return reach_unknown;
    }else if (status==AFNetworkReachabilityStatusReachableViaWWAN){
        return reach_wwan;
    }else if (status==AFNetworkReachabilityStatusReachableViaWiFi){
        return reach_wifi;
    }
    return reach_faild;
}

-(void)requestWithUrl:(NSString *)url
            Paraments:(NSDictionary *)paraments
                 Type:(RequestMethod)type
  requestSuccessBlock:(successBlock)successBlcok
          failedBlock:(failedBlock)failedBlock
         downProgress:(downProgress)progress
{
    AFHTTPSessionManager * manage = [self getSessionManage];
    dataTask * task = nil;
    if (type ==POST_REQUEST) {
        
    task = [manage POST:url
             parameters:paraments
               progress:^(NSProgress * _Nonnull uploadProgress) {
                   progress(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
               } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                   
                   if (responseObject!=nil) {
                       
                   successBlcok(responseObject);
                       
                   }
                   [self.taskArr removeObject:task];
                   
               } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                   failedBlock(error);
                   [self.taskArr removeObject:task];
                   
               }];
        
        
        if (task) {
            
            [self.taskArr addObject:task];
        }
        
    }else{
    
        task =[manage GET:url parameters:paraments progress:^(NSProgress * _Nonnull downloadProgress) {
            
            progress(downloadProgress.completedUnitCount/ downloadProgress.totalUnitCount);
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject!=nil) {
       
             successBlcok(responseObject);
                
            }
            [self.taskArr removeObject:task];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            failedBlock(error);
            [self.taskArr removeObject:task];
        }];
    
    }
}


-(void)uploadtWithUrl:(NSString *)url
            Paraments:(NSDictionary *)paraments
           uploadData:(NSData *)uploadData
                 name:(NSString *)name
             fileName:(NSString *)fileName
                 Type:(RequestMethod)type
  requestSuccessBlock:(successBlock)successBlcok
          failedBlock:(failedBlock)failedBlock
       uploadProgress:(upProgress)progress
{

    AFHTTPSessionManager * manage = [self getSessionManage];
    dataTask * task = nil;
        
        task = [manage POST:url parameters:paraments constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
            [formData appendPartWithFileData:uploadData name:name fileName:fileName mimeType:@"image/png"];
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
             progress(uploadProgress.completedUnitCount/ uploadProgress.totalUnitCount);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject!=nil) {
                
                successBlcok(responseObject);
                
            }
            [self.taskArr removeObject:task];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failedBlock(error);
            [self.taskArr removeObject:task];
        }];
        
    
}
//生成单利
-(AFHTTPSessionManager*)getSessionManage{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [AFHTTPSessionManager manager];
    });
    //这是请求数据为json
    manage.requestSerializer = [AFJSONRequestSerializer serializer];
    //设置返回数据为JOSN
    manage.responseSerializer = [AFJSONResponseSerializer serializer];
    //设置超市时间
    manage.requestSerializer.timeoutInterval =120;
    manage.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    
    return manage;
    
    
    
}

//直接取消某个请求
- (void)cancleWithRequestUrl:(NSString*)url
{
    
    if (url ==nil) {
        return;
    }
    
    [self.taskArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dataTask * task = obj;
        if ([task.currentRequest.URL.absoluteString hasSuffix:url]) {
            [task cancel];
            [self.taskArr removeObject:task];
            return;
        }
    }];
}
//暂停某个请求
-(void)suspendWithRequestUrl:(NSString*)url
{
    if (url ==nil) {
        return;
    }
    
    [self.taskArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dataTask * task = obj;
        if ([task.currentRequest.URL.absoluteString hasSuffix:url]) {
            [task suspend];
            return;
        }
    }];
}
//恢复某个请求
-(void)resumeWithRequestUrl:(NSString*)url
{
    if (url ==nil) {
        return;
    }
    
    [self.taskArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dataTask * task = obj;
        if ([task.currentRequest.URL.absoluteString hasSuffix:url]) {
            [task resume];
            return;
        }
    }];
}

-(NSMutableArray *)taskArr
{
    if (_taskArr ==nil) {
        _taskArr = [NSMutableArray array];
    }
    return _taskArr;
}



//图片压缩函数

-(UIImage*)obtinImagePercent:(UIImage *)image
{
    NSData * imageData = UIImageJPEGRepresentation(image, 1);
    NSInteger options;
    
    NSInteger len = [imageData length]/1024;
    if(len > 50 && len < 100){
        options = 95;
    } else if(len >= 100 && len < 200){
        options = 90;
    } else if(len >= 200 && len < 300){
        options = 85;
    } else if(len >= 300 && len < 400){
        options = 80;
    } else if(len >= 400 && len < 500){
        options = 75;
    } else if(len >= 500 && len < 600){
        options = 60;
    } else if(len >= 600 && len < 700){
        options = 50;
    } else if(len >= 700 && len < 800){
        options = 40;
    } else if(len >= 800 && len < 900){
        options = 30;
    }else if (len >=900  && len <2000)
    {
        options = 40;
    }
    else
    {
        options=10;
    }
    NSData * yasuoImageData = UIImageJPEGRepresentation(image, options/100);
    UIImage * yaosuo =[UIImage imageWithData:yasuoImageData];
    return yaosuo;
}

@end
