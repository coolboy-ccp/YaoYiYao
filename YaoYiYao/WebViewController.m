//
//  WebViewController.m
//  YaoYiYao
//
//  Created by liqunfei on 15/10/14.
//  Copyright © 2015年 chuchengpeng. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *myWeb;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myWeb.delegate = (id<UIWebViewDelegate>)self;

    [self.myWeb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://music.baidu.com/tag"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
}

@end
