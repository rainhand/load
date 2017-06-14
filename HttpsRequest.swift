//
//  HttpsRequest.swift
//  xinwoxing
//
//  Created by 郭超 on 2017/6/7.
//  Copyright © 2017年 郭超. All rights reserved.
//

import UIKit
import Foundation
import AFNetworking
//成功以后的回调
typealias successBlock = (NSDictionary)-> Void
//失败以后的回调
typealias failedBlock = (Error)-> Void
//下载进度的回调
typealias downBlock = (Progress)-> Void
//上传进度的回调
typealias upBlock = (Progress)-> Void
//每次请求的时候返回的都是URLSessionDataTask
typealias  dataTask = URLSessionDataTask
//请求方式

enum RequestType {
    case POST_REQUEST
    case GET_REQUEST
}
enum connectType {
    case UNKNOW
    case WWAN
    case WIFI
    case FAILED
}

class HttpsRequest: NSObject {

    
    //单利类
    static let requedt: HttpsRequest = HttpsRequest()
    class func shareRequest() -> HttpsRequest {
        return requedt
    }
    var requestType: RequestType?
    
    
    //请求函数
    func startRequest(url: String,
                      paraments:NSDictionary,
                      requestType:RequestType,
                      successBack:@escaping successBlock,
                      faildBack:@escaping failedBlock,
                      downProgress:@escaping downBlock){
        
        let manage:AFHTTPSessionManager = creatManager()
        var task:dataTask?
        
        //成功之后的回调
        let sucBack = { (task: URLSessionDataTask, responseObj: Any?) in
            successBack(responseObj as! NSDictionary)
            self.lazyRequestArr().remove(task)
        }
        
        let faildBackBlock = {(task: URLSessionDataTask?, error:Error) in
            faildBack(error)
            self.lazyRequestArr().remove(task!)
        }
        
        let progressBackBlock = {(progress: Progress) in
            downProgress(progress)
        }
        
        if  requestType == RequestType.POST_REQUEST{//post 请求
            
         task = manage.post(url, parameters: paraments, progress: progressBackBlock, success: sucBack, failure: faildBackBlock)
            
            if (task != nil) {
                self.lazyRequestArr().add(task!)
            }
        }else{//get请求
            task = manage.get(url, parameters: paraments, progress: progressBackBlock, success: sucBack, failure: faildBackBlock)
            if (task != nil) {
                self.lazyRequestArr().add(task!)
            }
        }
        
        
    }
    
    
    
    //上传函数
    func startRequest(url: String,
                      uploadData:NSData,
                      name:NSString,
                      fileName:NSString,
                      paraments:NSDictionary,
                      requestType:RequestType,
                      successBack:@escaping successBlock,
                      faildBack:@escaping failedBlock,
                      downProgress:@escaping downBlock){
        
        let manage:AFHTTPSessionManager = creatManager()
        var task:dataTask?
        
        //成功之后的回调
        let sucBack = { (task: URLSessionDataTask, responseObj: Any?) in
            successBack(responseObj as! NSDictionary)
            self.lazyRequestArr().remove(task)
        }
        
        let faildBackBlock = {(task: URLSessionDataTask?, error:Error) in
            faildBack(error)
            self.lazyRequestArr().remove(task!)
        }
        
        let progressBackBlock = {(progress: Progress) in
            downProgress(progress)
        }
        
        let formDataBlock = {(forData:AFMultipartFormData) in
            
            forData.appendPart(withFileData: uploadData as Data, name: name as String, fileName: fileName as String, mimeType: "image/png")
        }
        
           //调用上传函数
            task = manage.post(url, parameters: paraments, constructingBodyWith: formDataBlock, progress: progressBackBlock, success: sucBack, failure: faildBackBlock)

            if (task != nil) {
                self.lazyRequestArr().add(task!)
            }
            
    }
    //取消某个请求
    func cancleRequest(url:String) {
        if !url.isEmpty {
            self.requestsArr.enumerateObjects(_:) { (object, count, stop) in
                let task:dataTask = object as! dataTask
                if (task.currentRequest?.url?.absoluteString.hasSuffix(url))!{
                    task.cancel()
                    return
                }
            }
        }
    }
    //恢复某个请求
    func resumeRequest(url:String) {
        if !url.isEmpty {
            self.requestsArr.enumerateObjects(_:) { (object, count, stop) in
                let task:dataTask = object as! dataTask
                if (task.currentRequest?.url?.absoluteString.hasSuffix(url))!{
                    task.resume()
                    return
                }
            }
        }
    }
    //暂停某个请求
    func suspendRequest(url:String) {
        if !url.isEmpty {
            self.requestsArr.enumerateObjects(_:) { (object, count, stop) in
                let task:dataTask = object as! dataTask
                if (task.currentRequest?.url?.absoluteString.hasSuffix(url))!{
                    task.suspend()
                    return
                }
            }
        }
    }
    static var manage: AFHTTPSessionManager? = nil
    //设置manage
    private func creatManager() -> AFHTTPSessionManager{
        
        if HttpsRequest.manage == nil {
        HttpsRequest.manage = AFHTTPSessionManager()
        HttpsRequest.manage!.requestSerializer = AFJSONRequestSerializer()
        HttpsRequest.manage!.responseSerializer = AFJSONResponseSerializer()
        HttpsRequest.manage!.requestSerializer.timeoutInterval = 120
        HttpsRequest.manage!.responseSerializer.acceptableContentTypes = NSSet.init(array: ["application/json", "text/html" , "text/json", "text/plain", "text/javascript", "text/xml", "image/*"]) as? Set<String>
        
        
        //设置请求头
        let dict:NSDictionary = ["IMEI":"597D4D61-D364-4BD8-AAA3-8B15EC7499EB", "DEVICE":"IOS", "Accept-Language":"zh-CN;q=0.5", "AUTHORIZATION":"Bearer eyJhbGciOiJIUzI1NiIsImNhbGciOiJHWklQIn0.H4sIAAAAAAAAAKtWyiwuVrJScncMcQ13jFTSUcpMLFGyMjSxNDWzMLI0MNFRKi5NAiowMjUBSqZWFAAlTY3MjQwtwJIpqWWZyalAeU__YJDm3NRMIMfU0tzFxMXMUNfF2MxE18TJxULX0dHRWNfCydDU1dncxNLS1UmpFgAbrY5wfAAAAA.AUFDyDR_g5cYKqXTFDHwN1aRZIMmiGc0KicLWnAzogM"]
        let enumeratorKey:NSEnumerator = dict.keyEnumerator()
        for objc:Any in enumeratorKey {
            HttpsRequest.manage!.requestSerializer.setValue(dict.object(forKey: objc) as? String, forHTTPHeaderField: objc as! String)
        }
        
        }
        
        return HttpsRequest.manage!
    }
    
    
    
    //存放任务的数组(懒加载)
    lazy var requestsArr:NSMutableArray = self.lazyRequestArr()
 
    
    //懒加载
    func lazyRequestArr() -> NSMutableArray {
        let requests:NSMutableArray = NSMutableArray()
        return requests
        
    }
}
