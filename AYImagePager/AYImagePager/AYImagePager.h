//
//  AYImagePager.h
//  AYImagePager
//
//  Created by Alpha Yu on 9/1/15.
//  Copyright (c) 2015 tlm group. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AYPageControlAlignment) {
    AYPageControlAlignmentLeft = 1,
    AYPageControlAlignmentCenter,
    AYPageControlAlignmentRight
};

@class AYImagePager;

@protocol AYImagePagerDelegate <NSObject>

@optional
- (void)ay_imagePager:(AYImagePager *)imagePager didScrollToIndex:(NSUInteger)index;
- (void)ay_imagePager:(AYImagePager *)imagePager didSelectedAtIndex:(NSUInteger)index;

@end

@interface AYImagePager : UIView

@property (nonatomic, strong) NSArray *items;                               //support NSString\UIImage
@property (nonatomic, weak) id <AYImagePagerDelegate> delegate;
@property (nonatomic, assign, getter = isContinuous) BOOL continuous;       //default is YES
@property (nonatomic, assign) NSTimeInterval autoPlayTimeInterval;          //default is 3 seconds; if = 0, auto play disable
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, assign) UIViewContentMode contentModeOfImage;         //default is UIViewContentModeScaleAspectFill

@property (nonatomic, assign) AYPageControlAlignment pageControlAlignment;  //default is AYPageControlAlignmentCenter
@property (nonatomic, strong) UIImage *indicatorImage;                      //16*16@2x, would be better
@property (nonatomic, strong) UIImage *indicatorSelectedImage;
@property (nonatomic, strong) UIColor *indicatorColor;                      // ignored if indicatorImage is set
@property (nonatomic, strong) UIColor *indicatorSelectedColor;              // ignored if indicatorSelectedImage is set



- (void)reloadData;
- (void)reloadDataWithCompleteBlock:(void(^)(void))competeBlock;
- (void)scrollToIndex:(NSUInteger)toIndex animated:(BOOL)animated;

@end
