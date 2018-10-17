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
@property (weak, nonatomic) IBOutlet AYImagePager *pagerIB;

@end

@implementation ViewController {
    AYImagePager *_pager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _pager = [[AYImagePager alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    _pager.items = @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539765111044&di=8f1e0d52afb0aa6e2e510dcda993b3dc&imgtype=0&src=http%3A%2F%2Fi9.download.fd.pchome.net%2Ft_960x600%2Fg1%2FM00%2F08%2F00%2FoYYBAFNrk5aIOxRVAA6o5j6_TrMAABhAwBaFnkADqj-144.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539765111042&di=18380fc488c03b7ba1c629457896cb9d&imgtype=0&src=http%3A%2F%2Fgss0.baidu.com%2F7Po3dSag_xI4khGko9WTAnF6hhy%2Fzhidao%2Fpic%2Fitem%2Ff636afc379310a551ceaaf92b04543a98326108d.jpg"];
    _pager.delegate = self;
    _pager.indicatorColor = [UIColor colorWithRed:0.609 green:0.775 blue:1.000 alpha:1.000];
    [self.view addSubview:_pager];
    
    
    _pagerIB.items = @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539765111039&di=837a4738798b5dc7bf6ff4335953dd7b&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F011cf15548caf50000019ae9c5c728.jpg%402o.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539765111044&di=8f1e0d52afb0aa6e2e510dcda993b3dc&imgtype=0&src=http%3A%2F%2Fi9.download.fd.pchome.net%2Ft_960x600%2Fg1%2FM00%2F08%2F00%2FoYYBAFNrk5aIOxRVAA6o5j6_TrMAABhAwBaFnkADqj-144.jpg"];
    
    [self performSelector:@selector(reloadPager) withObject:nil afterDelay:7];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadPager {
    _pager.items = @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539765111044&di=8f1e0d52afb0aa6e2e510dcda993b3dc&imgtype=0&src=http%3A%2F%2Fi9.download.fd.pchome.net%2Ft_960x600%2Fg1%2FM00%2F08%2F00%2FoYYBAFNrk5aIOxRVAA6o5j6_TrMAABhAwBaFnkADqj-144.jpg",
                     @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539765111042&di=18380fc488c03b7ba1c629457896cb9d&imgtype=0&src=http%3A%2F%2Fgss0.baidu.com%2F7Po3dSag_xI4khGko9WTAnF6hhy%2Fzhidao%2Fpic%2Fitem%2Ff636afc379310a551ceaaf92b04543a98326108d.jpg",
                     @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539765111039&di=837a4738798b5dc7bf6ff4335953dd7b&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F011cf15548caf50000019ae9c5c728.jpg%402o.jpg"];
    _pager.autoPlayTimeInterval = 1.5;
    _pager.pageControlAlignment = AYPageControlAlignmentRight;
    _pager.indicatorImage = [UIImage imageNamed:@"pageDot"];
    _pager.indicatorSelectedImage = [UIImage imageNamed:@"currentPageDot"];
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
