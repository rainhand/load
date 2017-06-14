//
//  NetRequestTool.h
//  封装AFN
//
//  Created by 郭超 on 2017/6/8.
//  Copyright © 2017年 郭超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
//请求方式
typedef NS_ENUM(NSUInteger, RequestMethod){
    POST_REQUEST = 1,
    GET_REQUEST = 1<<1
};
//解析方式
typedef NS_ENUM(NSUInteger, AnalysisType){
    JOSN_TYPE = 1,
    XML_TYPE = 1<<1,
};
typedef NS_ENUM(NSUInteger, ReachType) {
    reach_unknown = 1,
    reach_wwan = 1<<1,
    reach_wifi =1<<2,
    reach_faild =1<<3
};

//成功回调
typedef void(^ successBlock)(NSDictionary * dict);
//失败回调
typedef void(^ failedBlock)(NSError * requestError);
//下载进度
typedef void(^ downProgress)(float progress);
//上传进度
typedef void(^ upProgress)(float progress);

typedef  NSURLSessionDataTask  dataTask;

@interface NetRequestTool : NSObject

@property(nonatomic,strong)NSMutableArray * taskArr;//存放任务的数组
+(instancetype)shareHttpsRequest;
+(ReachType)reachStatus;

//请求
-(void)requestWithUrl:(NSString*)url
            Paraments:(NSDictionary*)paraments
                 Type:(RequestMethod)type
  requestSuccessBlock:(successBlock)successBlcok
          failedBlock:(failedBlock)failedBlock
         downProgress:(downProgress)progress;
//上传
-(void)uploadtWithUrl:(NSString*)url
            Paraments:(NSDictionary*)paraments
           uploadData:(NSData*)uploadData
                 name:(NSString*)name
             fileName:(NSString*)fileName
                 Type:(RequestMethod)type
  requestSuccessBlock:(successBlock)successBlcok
          failedBlock:(failedBlock)failedBlock
       uploadProgress:(upProgress)progress;

//直接取消某个请求
-(void)cancleWithRequestUrl:(NSString*)url;
//暂停某个请求
-(void)suspendWithRequestUrl:(NSString*)url;
//恢复某个请求
-(void)resumeWithRequestUrl:(NSString*)url;
@end
