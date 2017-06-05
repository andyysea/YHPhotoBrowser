//
//  YHPhotoBrowserContentView.m
//  PhoneBrowserDemo
//
//  Created by 杨应海 on 2017/6/3.
//  Copyright © 2017年 junde. All rights reserved.
//

#import "YHPhotoBrowserContentView.h"
#import "YHPhotoBrowserLoadingView.h"
#import "YHPhotoBrowserConfig.h"
#import <UIImageView+WebCache.h>    //*********** 这里使用的是SDWebImage***********

#define Width_Screen  [UIScreen mainScreen].bounds.size.width
#define Height_Screen [UIScreen mainScreen].bounds.size.height

@interface YHPhotoBrowserContentView ()<UIScrollViewDelegate>

/** 加载失败之后显示的提示按钮,点击之后可以重新加载 */
@property (nonatomic, strong) UIButton *reloadButton;
/** 图片的URL */
@property (nonatomic, strong) NSURL *imageURL;
/** 占位图片 */
@property (nonatomic, strong) UIImage *placeholderImage;

/** 加载进度视图 */
@property (nonatomic, weak) YHPhotoBrowserLoadingView *loadingView;

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


#pragma mark - 设置图片的url和占位图片
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    _imageURL = url;
    _placeholderImage = placeholder;
    
    if (self.reloadButton) {
        self.reloadButton.hidden = YES;
    }
    YHPhotoBrowserLoadingView *loadingView = [[YHPhotoBrowserLoadingView alloc] init];
    loadingView.loadingType = YHPhotoBrowserLoadingLoopDiagram;
    loadingView.center = CGPointMake(Width_Screen / 2, Height_Screen / 2);
    [self addSubview:loadingView];
    _loadingView = loadingView;
    // 加载图片
    [self.imageView sd_setImageWithURL:url
                      placeholderImage:placeholder
                               options:SDWebImageRetryFailed
                              progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                  loadingView.progress = (CGFloat)receivedSize / expectedSize;
                              } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                  
                                  [loadingView removeFromSuperview];
                                  if (error) {
                                      if (self.reloadButton) {
                                          self.reloadButton.hidden = NO;
                                      } else {
                                          UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
                                          button.center = CGPointMake(Width_Screen / 2, Height_Screen / 2);
                                          button.layer.cornerRadius = 3;
                                          button.layer.masksToBounds = YES;
                                          button.titleLabel.font = [UIFont systemFontOfSize:13];
                                          button.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.3];
                                          [button setTitle:@"原图加载失败,点击请从新加载" forState:UIControlStateNormal];
                                          [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                                          [button addTarget:self action:@selector(reloadImageClick) forControlEvents:UIControlEventTouchUpInside];
                                          [self addSubview:button];
                                          
                                          self.reloadButton = button;
                                      }
                                  } else {
                                      self.IsHaveLoaded = YES; // 加载完成并且成功
                                  }
                              }];
    
}

#pragma mark - 重新加载按钮点击方法
- (void)reloadImageClick {
    [self setImageWithURL:_imageURL placeholderImage:_placeholderImage];
}

#pragma mark - 布局子视图
- (void)layoutSubviews {
    [super layoutSubviews];
    self.loadingView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    self.reloadButton.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height);
    self.scrollView.frame = self.bounds;
    
    CGRect frame = self.scrollView.frame;
    if (self.imageView.image) {
        CGSize imageSize = self.imageView.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
     // 图片宽度始终和屏幕宽度一样
        if (IsFullWidthForLandScape) {
            CGFloat ratio = frame.size.width / imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height * ratio;
            imageFrame.size.width = frame.size.width;
        } else {
            if (frame.size.width <= frame.size.height) {
                //竖屏
                CGFloat ratio = frame.size.width / imageFrame.size.width;
                imageFrame.size.height = imageFrame.size.height * ratio;
                imageFrame.size.width = frame.size.width;
            } else {
                // 横屏
                CGFloat ratio = frame.size.height / imageFrame.size.height;
                imageFrame.size.width = imageFrame.size.width * ratio;
                imageFrame.size.height = frame.size.height;
            }
        }
        self.imageView.frame = imageFrame;
        self.scrollView.contentSize = self.imageView.frame.size;
        self.imageView.center = [self centerOfScrollViewContent:self.scrollView];
        // 根据图片大小找到最大缩放等级,保证最大缩放的时候,不会黑边
        CGFloat maxScale = frame.size.height / imageFrame.size.height;
        maxScale = frame.size.width / imageFrame.size.width > maxScale ? frame.size.width / imageFrame.size.width : maxScale;
        // 超过了设置的最大缩放比才算数
        maxScale = maxScale > MaxZoomScale ? maxScale : MaxZoomScale;
        // 初始化
        self.scrollView.minimumZoomScale = MinZoomScale;
        self.scrollView.maximumZoomScale = maxScale;
        self.scrollView.zoomScale = 1.0;
    } else {
        frame.origin = CGPointZero;
        self.imageView.frame = frame;
        // 重置内容大小
        self.scrollView.contentSize = self.imageView.frame.size;
    }
    self.scrollView.contentOffset = CGPointZero;
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

#pragma mark - 单点手势监听方法
- (void)singleTapGesture:(UITapGestureRecognizer *)singleTap {
    if (self.singleTapBlock) {
        self.singleTapBlock(singleTap);
    }
}

#pragma mark - 双点手势监听方法 
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


#pragma mark - 设置界面元素
- (void)setupUI {
    
    // 1> 添加滚动视图
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, Width_Screen, Height_Screen)];
    scrollView.delegate = self;
    [self addSubview:scrollView];
    
    // 2> 添加图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Width_Screen, Height_Screen)];
    imageView.userInteractionEnabled = YES;
    [scrollView addSubview:imageView];
    
    // 3> 添加单点手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesture:)];
    singleTap.delaysTouchesBegan = YES;
    [self addGestureRecognizer:singleTap];
    
    // 4> 添加双点手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    // 在识别是否有其他多点手势的情况下再执行是否是单点
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // 5> 添加捏合手势
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:nil action:nil];
    [self addGestureRecognizer:pinchGesture];
    
    // 属性记录
    _scrollView = scrollView;
    _imageView = imageView;
}



@end
