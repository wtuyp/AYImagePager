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

@implementation ViewController {
    AYImagePager *_pager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _pager = [[AYImagePager alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    _pager.items = @[@"http://d.hiphotos.baidu.com/image/w%3D2048/sign=5ad7fab780025aafd33279cbcfd5aa64/8601a18b87d6277f15eb8e4f2a381f30e824fcc8.jpg",
                    @"http://e.hiphotos.baidu.com/image/w%3D2048/sign=df5d0b61cdfc1e17fdbf8b317ea8f703/0bd162d9f2d3572c8d2b20ab8813632763d0c3f8.jpg"];
    _pager.delegate = self;
    [self.view addSubview:_pager];
    
    [self performSelector:@selector(reloadPager) withObject:nil afterDelay:7];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadPager {
    _pager.items = @[@"http://d.hiphotos.baidu.com/image/w%3D2048/sign=ed59838948ed2e73fce9812cb339a08b/58ee3d6d55fbb2fb9835341f4d4a20a44623dca5.jpg",
                     @"http://d.hiphotos.baidu.com/image/w%3D2048/sign=a11d7b94552c11dfded1b823571f63d0/eaf81a4c510fd9f914eee91e272dd42a2934a4c8.jpg"];
    [_pager reloadDataWithCompleteBlock:^{
        NSLog(@"reload data done!");
    }];
}

#pragma mark - AYImagePagerDelegate
- (void)ay_imagePager:(AYImagePager *)imagePager didScrollToIndex:(NSUInteger)index {
    NSLog(@"didScrollToIndex %lu", (unsigned long)index);
}

- (void)ay_imagePager:(AYImagePager *)imagePager didSelectedAtIndex:(NSUInteger)index {
    NSLog(@"didSelectedAtIndex %lu", (unsigned long)index);
}
@end
