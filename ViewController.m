//
//  ViewController.m
//  封装AFN
//
//  Created by 郭超 on 2017/6/8.
//  Copyright © 2017年 郭超. All rights reserved.
//

#import "ViewController.h"
#import "NetRequestTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NetRequestTool * requetTool =[NetRequestTool shareHttpsRequest];

    [requetTool requestWithUrl:@""
Paraments:[NSDictionary dictionary] Type:POST_REQUEST requestSuccessBlock:^(NSDictionary *dict) {
    
} failedBlock:^(NSError *requestError) {
    
} downProgress:^(float progress) {
    
}];
}



@end
