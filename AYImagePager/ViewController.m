//
//  ViewController.m
//  AYImagePager
//
//  Created by Alpha Yu on 9/1/15.
//  Copyright (c) 2015 tlm group. All rights reserved.
//

#import "ViewController.h"
#import "AYImagePager.h"

@interface ViewController () <AYImagePagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    AYImagePager *pager = [[AYImagePager alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    pager.items = @[@"http://d.hiphotos.baidu.com/image/w%3D2048/sign=5ad7fab780025aafd33279cbcfd5aa64/8601a18b87d6277f15eb8e4f2a381f30e824fcc8.jpg",
                    @"http://e.hiphotos.baidu.com/image/w%3D2048/sign=df5d0b61cdfc1e17fdbf8b317ea8f703/0bd162d9f2d3572c8d2b20ab8813632763d0c3f8.jpg"];
    pager.delegate = self;
    [self.view addSubview:pager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AYImagePagerDelegate
- (void)ay_imagePager:(AYImagePager *)imagePager didScrollToIndex:(NSUInteger)index {
    NSLog(@"didScrollToIndex %lu", (unsigned long)index);
}

- (void)ay_imagePager:(AYImagePager *)imagePager didSelectedAtIndex:(NSUInteger)index {
    NSLog(@"didSelectedAtIndex %lu", (unsigned long)index);
}
@end
