//
//  AYImagePager.m
//  AYImagePager
//
//  Created by Alpha Yu on 9/1/15.
//  Copyright (c) 2015 tlm group. All rights reserved.
//

#import "AYImagePager.h"
#import "UIImageView+WebCache.h"
#import "SMPageControl.h"

@interface AYImagePager () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) SMPageControl *pageControl;
@property (nonatomic, strong) NSArray *datasourceImages;
@property (nonatomic, assign) NSUInteger currentSelectedPage;
@property (nonatomic, copy) void(^reloadCompleteBlock)(void);

@end

@implementation AYImagePager

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (void)initProperties {
    _continuous = YES;
    _autoPlayTimeInterval = 3.0;
    _contentModeOfImage = UIViewContentModeScaleAspectFill;
    
    _pageControlAlignment = AYPageControlAlignmentCenter;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSArray *subViews = _scrollView.subviews;
    if (subViews.count > 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self initialize];
    
    if (self.reloadCompleteBlock) {
        self.reloadCompleteBlock();
    }
}

- (void)initialize {
    self.clipsToBounds = YES;
    
    [self initializeScrollView];
    [self initializePageControl];
    
    [self loadData];
}

- (void)initializeScrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = self.autoresizingMask;
        _scrollView.scrollsToTop = NO;
        [self addSubview:_scrollView];
    }
    _scrollView.frame = self.bounds;
}

- (void)initializePageControl {
    if (!_pageControl) {
        self.pageControl = [[SMPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.hidesForSinglePage = YES;
        [self addSubview:_pageControl];
    }
    _pageControl.frame = CGRectMake(10, CGRectGetHeight(_scrollView.frame) - 20, CGRectGetWidth(_scrollView.frame) - 20, 20);
    _pageControl.alignment = (SMPageControlAlignment)_pageControlAlignment;
    _pageControl.pageIndicatorImage = _indicatorImage;
    _pageControl.currentPageIndicatorImage = _indicatorSelectedImage;
    _pageControl.pageIndicatorTintColor = _indicatorColor;
    _pageControl.currentPageIndicatorTintColor = _indicatorSelectedColor;
}

- (void)loadData {
    self.datasourceImages = self.items ? : @[];
    
    if (_datasourceImages.count == 0) {
        if (_placeholderImage) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
            imageView.contentMode = _contentModeOfImage;
            imageView.image = _placeholderImage;
            [_scrollView addSubview:imageView];
        }
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
        imageView.clipsToBounds = YES;
        imageView.contentMode = _contentModeOfImage;
        
        id imageSource = _datasourceImages[i];
        if ([imageSource isKindOfClass:[NSString class]]) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageSource]
                         placeholderImage:_placeholderImage];
        } else if ([imageSource isKindOfClass:[UIImage class]]) {
            imageView.image = imageSource;
        }
        [_scrollView addSubview:imageView];
    }
    
    if (self.isContinuous && _datasourceImages.count > 1) {
        _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.frame), 0);
    }
    
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    [_scrollView addGestureRecognizer:tapGestureRecognize];
    
    if ((self.autoPlayTimeInterval > 0.0) && (self.items.count > 1)) {
        [self performSelector:@selector(autoPlayImagePage) withObject:nil afterDelay:self.autoPlayTimeInterval];
    }
}

- (void)reloadData {
    self.reloadCompleteBlock = nil;
    [self setNeedsLayout];
}

- (void)reloadDataWithCompleteBlock:(void(^)(void))competeBlock {
    self.reloadCompleteBlock = competeBlock;
    [self setNeedsLayout];
}

- (void)scrollToIndex:(NSUInteger)toIndex animated:(BOOL)animated {
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
            } else {
                [self moveToTargetPosition:CGRectGetWidth(_scrollView.frame) * (page + 1) withAnimated:animated];
            }
        } else {
            [self moveToTargetPosition:0 withAnimated:animated];
        }
    } else {
        [self moveToTargetPosition:CGRectGetWidth(_scrollView.frame) * page withAnimated:animated];
    }
    
    [self scrollViewDidScroll:_scrollView];
}

- (void)moveToTargetPosition:(CGFloat)targetX withAnimated:(BOOL)animated {
    [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:animated];
}

- (void)autoPlayImagePage {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoPlayImagePage) object:nil];
    
    [self setSwitchPage:-1 animated:YES withUserInterface:NO];
    
    [self performSelector:_cmd withObject:nil afterDelay:self.autoPlayTimeInterval];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat targetX = scrollView.contentOffset.x;
    
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    
    if (self.isContinuous && _datasourceImages.count >= 3) {
        if (targetX >= pageWidth * (_datasourceImages.count - 1)) {
            targetX = pageWidth;
            _scrollView.contentOffset = CGPointMake(targetX, 0);
        } else if (targetX <= 0) {
            targetX = pageWidth * (_datasourceImages.count - 2);
            _scrollView.contentOffset = CGPointMake(targetX, 0);
        }
    }
    
    NSInteger page = (scrollView.contentOffset.x + pageWidth * 0.5) / pageWidth;
    
    if (self.isContinuous && _datasourceImages.count > 1) {
        page--;
        if (page >= _pageControl.numberOfPages) {
            page = 0;
        } else if (page < 0) {
            page = _pageControl.numberOfPages - 1;
        }
    }
    
    
    if (page != _currentSelectedPage) {
        if ([self.delegate respondsToSelector:@selector(ay_imagePager:didScrollToIndex:)]) {
            [self.delegate ay_imagePager:self didScrollToIndex:page];
        }
    }
    
    _currentSelectedPage = page;
    _pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoPlayImagePage) object:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self performSelector:@selector(autoPlayImagePage) withObject:nil afterDelay:self.autoPlayTimeInterval];
}

#pragma mark - UITapGestureRecognizerSelector
- (void)singleTapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    NSInteger page = (NSInteger)(_scrollView.contentOffset.x / CGRectGetWidth(_scrollView.frame));
    
    if ([self.delegate respondsToSelector:@selector(ay_imagePager:didSelectedAtIndex:)]) {
        [self.delegate ay_imagePager:self didSelectedAtIndex:self.isContinuous ? --page : page];
    }
}

#pragma mark - page control properties setter
- (void)setIndicatorImage:(UIImage *)indicatorImage {
    _indicatorImage = indicatorImage;
    self.pageControl.pageIndicatorImage = _indicatorImage;
}

- (void)setIndicatorSelectedImage:(UIImage *)indicatorSelectedImage {
    _indicatorSelectedImage = indicatorSelectedImage;
    self.pageControl.currentPageIndicatorImage = _indicatorSelectedImage;
}

@end

