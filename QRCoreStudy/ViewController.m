//
//  ViewController.m
//  QRCoreStudy
//
//  Created by caiqiujun on 16/1/15.
//  Copyright © 2016年 caiqiujun. All rights reserved.
//

#import "ViewController.h"
#import "QRCoreImageView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    QRCoreImageView *imageView = [[QRCoreImageView alloc] initWithUrl:@"http://www.163.com" Color:[UIColor yellowColor] withSize:[UIScreen mainScreen].bounds.size.width / 2];
    imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.width / 2);
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width / 2, 40)];
    label.center = self.view.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"gitHb管理开源项目";
    [self.view addSubview:label];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
