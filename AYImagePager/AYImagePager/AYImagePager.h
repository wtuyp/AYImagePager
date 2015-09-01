//
//  AYImagePager.h
//  AYImagePager
//
//  Created by Alpha Yu on 9/1/15.
//  Copyright (c) 2015 tlm group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AYImagePager;

@protocol AYImagePagerDelegate <NSObject>

@optional
- (void)ay_imagePager:(AYImagePager *)imagePager didScrollToIndex:(NSUInteger)index;
- (void)ay_imagePager:(AYImagePager *)imagePager didSelectedAtIndex:(NSUInteger)index;

@end

@interface AYImagePager : UIView

@property (nonatomic, strong) NSArray *items;                           //support NSString\NSURL\UIImage
@property (nonatomic, weak) id <AYImagePagerDelegate> delegate;
@property (nonatomic, assign, getter = isContinuous) BOOL continuous;   //default is YES
@property (nonatomic, assign) NSUInteger autoPlayTimeInterval;          //default is 3 seconds
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, assign) UIViewContentMode contentModeOfImage;

- (void)reloadData;
- (void)reloadDataWithCompleteBlock:(void(^)(void))competeBlock;
- (void)scrollToIndex:(NSInteger)toIndex animated:(BOOL)animated;

@end
