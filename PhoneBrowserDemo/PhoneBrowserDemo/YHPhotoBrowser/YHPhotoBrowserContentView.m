//
//  YHPhotoBrowserContentView.m
//  YHPhotoBrowser
//
//  Created by YYH on 2017/6/3.
//  Copyright © 2017年 YYH. All rights reserved.
//

#import "YHPhotoBrowserContentView.h"
#import "YHPhotoBrowserLoadingView.h"
#import <UIImageView+WebCache.h>

#define Width_Screen  [UIScreen mainScreen].bounds.size.width
#define Height_Screen [UIScreen mainScreen].bounds.size.height


@interface YHPhotoBrowserContentView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

/** 图片的URL */
@property (nonatomic, strong) NSURL *imageUrl;
/** 占位图片 */
@property (nonatomic, strong) UIImage *placeholderImage;
/** 点击重新加载按钮 */
@property (nonatomic, strong) UIButton *reloadButton;

/** 加载进度视图 */
@property (nonatomic, strong) YHPhotoBrowserLoadingView *loadingView;


@end

@implementation YHPhotoBrowserContentView

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark - 设置图片的URL,以及占位图片
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    _imageUrl = url;
    _placeholderImage = placeholder;
    
    [self.reloadButton removeFromSuperview];
    [self addSubview:self.loadingView];
    
    __weak typeof(self) weakSelf = self;
    [_imageView sd_setImageWithURL:url
                  placeholderImage:placeholder
                           options:SDWebImageRetryFailed
                          progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                              __strong typeof(weakSelf) strongSelf = weakSelf;
                              strongSelf.loadingView.progress = (CGFloat)receivedSize / expectedSize;
                          }
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             __strong typeof(weakSelf) strongSelf = weakSelf;
                             [strongSelf.loadingView removeFromSuperview];
                             if (error) {
                                 [strongSelf addSubview:strongSelf.reloadButton];
                             } else {
                                 strongSelf.IsHaveLoaded = YES;
                                 [strongSelf layoutImageFrame];
                             }
                         }];
}


- (void)layoutImageFrame {
    CGRect frame = self.scrollView.frame;
    if (self.imageView.image) {
        CGSize imageSize = self.imageView.image.size;
        CGFloat scaleH = imageSize.height * frame.size.width / imageSize.width;
        CGRect imageFrame = CGRectMake(0, 0, frame.size.width, scaleH);
        
        self.imageView.frame = imageFrame;
        self.scrollView.contentSize = self.imageView.frame.size;
        self.imageView.center = [self centerOfScrollViewContent:self.scrollView];
    } else {
        frame.origin = CGPointZero;
        self.imageView.frame = frame;
        self.scrollView.contentSize = self.imageView.frame.size;
    }
    self.scrollView.contentOffset = CGPointZero;
}

#pragma mark - 重新加载按钮的监听方法
- (void)reloadImageButtonClick {
    [self setImageWithURL:self.imageUrl placeholderImage:self.placeholderImage];
}

#pragma mark - 单点手势
- (void)singleTapGesture:(UITapGestureRecognizer *)singleTap {
    if (self.singleTapBlock) {
        self.singleTapBlock(singleTap);
    }
}

#pragma mark - 双点手势
- (void)doubleTapGesture:(UITapGestureRecognizer *)doubleTap {
    if (!self.IsHaveLoaded) {
        return;
    }
    CGPoint touchPoint = [doubleTap locationInView:self];
    if (self.scrollView.zoomScale <= 1.0) {
        CGFloat scaleX = touchPoint.x + self.scrollView.contentOffset.x;
        CGFloat scaleY = touchPoint.y + self.scrollView.contentOffset.y;
        [self.scrollView zoomToRect:CGRectMake(scaleX, scaleY, 15, 15) animated:YES];
    } else {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //对缩放进行调整
    self.imageView.center = [self centerOfScrollViewContent:scrollView];
}

#pragma mark - 对视图缩放进行调整
- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? ((scrollView.bounds.size.width - scrollView.contentSize.width) / 2) : 0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? ((scrollView.bounds.size.height - scrollView.contentSize.height) / 2) : 0;
    return CGPointMake(scrollView.contentSize.width / 2 + offsetX, scrollView.contentSize.height / 2 + offsetY);
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutImageFrame];
}

#pragma mark - 设置界面元素
- (void)setupUI {
    // 1> 添加滚动视图
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.delegate = self;
    scrollView.maximumZoomScale = 3.0;
    scrollView.minimumZoomScale = 0.8;
    [self addSubview:scrollView];
    
    // 2> 添加图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:scrollView.bounds];
    imageView.userInteractionEnabled = YES;
    [scrollView addSubview:imageView];
    
    // 3> 添加单点手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesture:)];
    singleTap.delaysTouchesBegan = YES;
    singleTap.delegate = self;
    [self addGestureRecognizer:singleTap];
    
    // 4> 添加双点手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    [self addGestureRecognizer:doubleTap];
    // 在识别是否有其他多点手势的情况下再执行是否是单点
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // 5> 添加捏合手势
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:nil action:nil];
    pinchGesture.delegate = self;
    [self addGestureRecognizer:pinchGesture];
    
    
    // 属性记录
    _scrollView = scrollView;
    _imageView = imageView;
}


#pragma mark - 懒加载
/** 加载进度视图 */
- (YHPhotoBrowserLoadingView *)loadingView {
    if (_loadingView == nil) {
        YHPhotoBrowserLoadingView *loadingView = [[YHPhotoBrowserLoadingView alloc] init];
        loadingView.center = CGPointMake(Width_Screen / 2, Height_Screen / 2);
        _loadingView = loadingView;
    }
    return _loadingView;
}

/** 重新加载按钮 */
- (UIButton *)reloadButton {
    if (_reloadButton == nil) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        button.center = CGPointMake(Width_Screen / 2, Height_Screen / 2);
        button.layer.cornerRadius = 3;
        button.layer.masksToBounds = YES;
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        button.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.3];
        [button setTitle:@"原图加载失败,点击请从新加载" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(reloadImageButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _reloadButton = button;
    }
    return _reloadButton;
}

@end
