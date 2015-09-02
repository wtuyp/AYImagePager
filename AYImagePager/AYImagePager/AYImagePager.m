//
//  AYImagePager.m
//  AYImagePager
//
//  Created by Alpha Yu on 9/1/15.
//  Copyright (c) 2015 tlm group. All rights reserved.
//

#import "AYImagePager.h"
#import "UIImageView+WebCache.h"

@interface AYImagePager () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *datasourceImages;
@property (assign, nonatomic) NSUInteger currentSelectedPage;
@property (strong, nonatomic) void(^completeBlock)(void);

@end

@implementation AYImagePager

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initProperties];
    }
    return self;
}

- (void)initProperties {
    _continuous = YES;
    _autoPlayTimeInterval = 3;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSArray *subViews = self.subviews;
    if (subViews.count > 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self initialize];
    
    if (self.completeBlock) {
        self.completeBlock();
    }
}

- (void)initialize {
    self.clipsToBounds = YES;
    
    [self initializeScrollView];
    [self initializePageControl];
    
    [self loadData];
    
    if (self.autoPlayTimeInterval > 0) {
        if ((self.isContinuous && _datasourceImages.count > 3) || (!self.isContinuous && _datasourceImages.count > 1)) {
            [self performSelector:@selector(autoSwitchBannerView) withObject:nil afterDelay:self.autoPlayTimeInterval];
        }
    }
}

- (void)initializeScrollView {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.autoresizingMask = self.autoresizingMask;
    _scrollView.scrollsToTop = NO;
    [self addSubview:_scrollView];
}

- (void)initializePageControl {
    CGRect pageControlFrame = CGRectMake(0, 0, CGRectGetWidth(_scrollView.frame), 30);
    _pageControl = [[UIPageControl alloc] initWithFrame:pageControlFrame];
    _pageControl.center = CGPointMake(CGRectGetWidth(_scrollView.frame)*0.5, CGRectGetHeight(_scrollView.frame) - 12.);
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_pageControl];
}

- (void)loadData {
    _datasourceImages = self.items ? : @[];
    
    if (_datasourceImages.count == 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame))];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor clearColor];
        if (_placeholderImage) {
            imageView.image = _placeholderImage;
        }
        [_scrollView addSubview:imageView];
        return;
    }
    
    _pageControl.numberOfPages = _datasourceImages.count;
    _pageControl.currentPage = 0;
    
    if (self.isContinuous) {
        NSMutableArray *cycleDatasource = [_datasourceImages mutableCopy];
        [cycleDatasource insertObject:[_datasourceImages lastObject] atIndex:0];
        [cycleDatasource addObject:[_datasourceImages firstObject]];
        _datasourceImages = [cycleDatasource copy];
    }
    
    CGFloat contentWidth = CGRectGetWidth(_scrollView.frame);
    CGFloat contentHeight = CGRectGetHeight(_scrollView.frame);
    
    _scrollView.contentSize = CGSizeMake(contentWidth * _datasourceImages.count, contentHeight);
    
    for (NSInteger i = 0; i < _datasourceImages.count; i++) {
        CGRect imgRect = CGRectMake(contentWidth * i, 0, contentWidth, contentHeight);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imgRect];
        imageView.backgroundColor = [UIColor clearColor];
        if (_contentModeOfImage) {
            imageView.contentMode = _contentModeOfImage;
        }
        
        id imageSource = [_datasourceImages objectAtIndex:i];
        if ([imageSource isKindOfClass:[UIImage class]]) {
            imageView.image = imageSource;
        }else if ([imageSource isKindOfClass:[NSString class]] || [imageSource isKindOfClass:[NSURL class]]) {
            [imageView sd_setImageWithURL:[imageSource isKindOfClass:[NSString class]] ? [NSURL URLWithString:imageSource] : imageSource placeholderImage:_placeholderImage];
        }
        [_scrollView addSubview:imageView];
    }
    
    if (self.isContinuous && _datasourceImages.count > 1) {
        _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.frame), 0);
    }
    
    // single tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognize.delegate = self;
    tapGestureRecognize.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:tapGestureRecognize];
    
}

- (void)reloadData {
    self.completeBlock = nil;
    [self setNeedsLayout];
}

- (void)reloadDataWithCompleteBlock:(void(^)(void))competeBlock {
    self.completeBlock = competeBlock;
    [self setNeedsLayout];
}

- (void)moveToTargetPosition:(CGFloat)targetX withAnimated:(BOOL)animated {
    [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:animated];
}

- (void)scrollToIndex:(NSInteger)toIndex animated:(BOOL)animated {
    NSInteger page = MIN(_datasourceImages.count - 1, MAX(0, toIndex));
    
    [self setSwitchPage:page animated:animated withUserInterface:YES];
}

- (void)setSwitchPage:(NSInteger)switchPage animated:(BOOL)animated withUserInterface:(BOOL)userInterface {
    NSInteger page = -1;
    
    if (userInterface) {
        page = switchPage;
    }else {
        _currentSelectedPage++;
        page = _currentSelectedPage % (self.isContinuous ? (_datasourceImages.count - 1) : _datasourceImages.count);
    }
    
    if (self.isContinuous) {
        if (_datasourceImages.count > 1) {
            if (page >= (_datasourceImages.count -2)) {
                page = _datasourceImages.count - 3;
                _currentSelectedPage = 0;
                [self moveToTargetPosition:CGRectGetWidth(_scrollView.frame) * (page + 2) withAnimated:animated];
            }else {
                [self moveToTargetPosition:CGRectGetWidth(_scrollView.frame) * (page + 1) withAnimated:animated];
            }
        }else {
            [self moveToTargetPosition:0 withAnimated:animated];
        }
    }else {
        [self moveToTargetPosition:CGRectGetWidth(_scrollView.frame) * page withAnimated:animated];
    }
    
    [self scrollViewDidScroll:_scrollView];
}

- (void)autoSwitchBannerView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoSwitchBannerView) object:nil];
    
    [self setSwitchPage:-1 animated:YES withUserInterface:NO];
    
    [self performSelector:_cmd withObject:nil afterDelay:self.autoPlayTimeInterval];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat targetX = scrollView.contentOffset.x;
    
    CGFloat item_width = CGRectGetWidth(scrollView.frame);
    
    if (self.isContinuous && _datasourceImages.count >= 3) {
        if (targetX >= item_width * (_datasourceImages.count - 1)) {
            targetX = item_width;
            _scrollView.contentOffset = CGPointMake(targetX, 0);
        }else if (targetX <= 0) {
            targetX = item_width * (_datasourceImages.count - 2);
            _scrollView.contentOffset = CGPointMake(targetX, 0);
        }
    }
    
    NSInteger page = (scrollView.contentOffset.x + item_width * 0.5) / item_width;
    
    if (self.isContinuous && _datasourceImages.count > 1) {
        page--;
        if (page >= _pageControl.numberOfPages) {
            page = 0;
        }else if (page < 0) {
            page = _pageControl.numberOfPages - 1;
        }
    }
    
    _currentSelectedPage = page;
    
    if (page != _pageControl.currentPage) {
        if ([self.delegate respondsToSelector:@selector(ay_imagePager:didScrollToIndex:)]) {
            [self.delegate ay_imagePager:self didScrollToIndex:page];
        }
    }
    
    _pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoSwitchBannerView) object:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self performSelector:@selector(autoSwitchBannerView) withObject:nil afterDelay:self.autoPlayTimeInterval];
}

#pragma mark - UITapGestureRecognizerSelector
- (void)singleTapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    NSInteger page = (NSInteger)(_scrollView.contentOffset.x / CGRectGetWidth(_scrollView.frame));
    
    if ([self.delegate respondsToSelector:@selector(ay_imagePager:didSelectedAtIndex:)]) {
        [self.delegate ay_imagePager:self didSelectedAtIndex:self.isContinuous ? --page : page];
    }
}

@end
