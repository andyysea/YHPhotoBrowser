//
//  YHPhotoBrowserView.m
//  PhoneBrowserDemo
//
//  Created by junde on 2017/6/2.
//  Copyright © 2017年 junde. All rights reserved.
//

#import "YHPhotoBrowserView.h"
#import "YHPhotoBrowserConfig.h"
#import "YHPhotoBrowserContentView.h"

#define Width_Screen  [UIScreen mainScreen].bounds.size.width
#define Height_Screen [UIScreen mainScreen].bounds.size.height

@interface YHPhotoBrowserView ()<UIScrollViewDelegate>

/** 外部添加图片组的容器视图/父视图 */
@property (nonatomic, weak) UIView *sourceImagesSuperView;
/** 当前的显示的图片/点击的图片 */
@property (nonatomic, assign) NSInteger ImageCurrentIndex;
/** 总的图片数量 */
@property (nonatomic, assign) NSInteger ImageTotalCount;


/** 内容视图,作为self的父视图 */
@property (nonatomic, weak) UIView *contentView;
/** 对底层滚动视图 */
@property (nonatomic, weak) UIScrollView *scrollView;

/** 显示当前页数/总页数的标签 */
@property (nonatomic, weak) UILabel *currentPageLabel;
/** 保存当前图片到相册的按钮 */
@property (nonatomic, weak) UIButton *saveImageButton;

/** 提示标签是否能够保存图片,保存成功与否 */
@property (nonatomic, strong) UILabel *tipLabel;

/** 是否已经显示第一张图片视图 */
@property (nonatomic, assign) BOOL IsHaveShowFirstView;

@end

@implementation YHPhotoBrowserView

#pragma mark - 图片浏览器的初始化方法
- (instancetype)initWithImageCurrentIndex:(NSInteger)currentIndex imageTotalCount:(NSInteger)totalCount sourceImagesSuperView:(UIView *)sourceView {
    self = [super init];
    if (self) {
        // 记录初始化信息
        _ImageCurrentIndex = currentIndex;
        _ImageTotalCount = totalCount;
        _sourceImagesSuperView = sourceView;
        
        [self setupUI];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 展示图片浏览器 
- (void)showPhotoBrowser {
    // 处理横屏竖屏问题
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 这里先调用一次,为了横屏打开图片时候的处理
        [self currentDeviceOrientationChange];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
//    });
}

#pragma mark  监听设备屏幕方向变化的处理
- (void)currentDeviceOrientationChange {
    if (!IsSupportLandScape) {
        return;
    }
    YHPhotoBrowserContentView *browserContentView = self.scrollView.subviews[self.ImageCurrentIndex];
    [browserContentView.scrollView setZoomScale:1.0 animated:YES];
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)orientation];
            self.transform = (orientation == UIDeviceOrientationLandscapeRight) ? CGAffineTransformMakeRotation(M_PI * 1.5) : CGAffineTransformMakeRotation(M_PI / 2);
            self.bounds = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:nil];
    } else if (UIDeviceOrientationIsPortrait(orientation)) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)orientation];
            self.transform = (orientation == UIDeviceOrientationPortrait) ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
            self.bounds = screenBounds;
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:nil];
    }
}


#pragma mark - 单点手势的回调处理
- (void)singleTapBlockCallBackHandle:(UITapGestureRecognizer *)singleTap {
    YHPhotoBrowserContentView *browserContentView = self.scrollView.subviews[self.ImageCurrentIndex];
    [browserContentView.scrollView setZoomScale:1.0 animated:YES];
    self.currentPageLabel.hidden = YES;
    self.saveImageButton.hidden = YES;
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
            self.transform = CGAffineTransformIdentity;
            self.bounds = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height);
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self hidePhotoBrowser:singleTap];
        }];
    } else {
        [self hidePhotoBrowser:singleTap];
    }
}

#pragma mark  退出图片控制器
- (void)hidePhotoBrowser:(UITapGestureRecognizer *)singleTap {
    YHPhotoBrowserContentView *browserContentView = (YHPhotoBrowserContentView *)singleTap.view;
    UIImageView *currentImageView = browserContentView.imageView;
    NSInteger currentIndex = currentImageView.tag;
    UIView *sourceView = self.sourceImagesSuperView.subviews[currentIndex];
   
    CGRect tempRect = [self.sourceImagesSuperView convertRect:sourceView.frame toView:self];
    UIImageView *tempImageView = [[UIImageView alloc] init];
    tempImageView.image = currentImageView.image;
    
    CGFloat lowQImageW = tempImageView.image.size.width;
    CGFloat lowQImageH = tempImageView.image.size.height;
    CGFloat scaleH = lowQImageH * Width_Screen / lowQImageW;
    if (scaleH < Height_Screen) {
        tempImageView.frame = CGRectMake(0, (Height_Screen - scaleH) / 2, Width_Screen, scaleH);
    } else {
        tempImageView.frame = CGRectMake(0, 0, Width_Screen, scaleH);
    }
    [self addSubview:tempImageView];
    
    self.scrollView.hidden = YES;
    self.saveImageButton.hidden = YES;
    self.currentPageLabel.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.window.windowLevel = UIWindowLevelNormal;
    [UIView animateWithDuration:0.25 animations:^{
        tempImageView.frame = tempRect;
    } completion:^(BOOL finished) {
        [self.contentView removeFromSuperview];
        [tempImageView removeFromSuperview];
    }];
}

#pragma mark - 保存当前的图片到图片库
- (void)saveCurrentImageIntoPhotoGallery {
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;
    YHPhotoBrowserContentView *browserContentView = self.scrollView.subviews[index];
    // 是否加载完成
    if (browserContentView.IsHaveLoaded) {
        UIImageWriteToSavedPhotosAlbum(browserContentView.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    } else {
        self.tipLabel.text = @"加载中,请稍后🙂!";
        [[UIApplication sharedApplication].keyWindow addSubview:self.tipLabel];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.tipLabel];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tipLabel removeFromSuperview];
        });
    }
}

#pragma mark 保存图片回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        self.tipLabel.text = @"保存失败💔..";
    } else {
        self.tipLabel.text = @"保存成功😎..";
    }
    [[UIApplication sharedApplication].keyWindow addSubview:self.tipLabel];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.tipLabel];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tipLabel removeFromSuperview];
    });
}


#pragma mark - 加载点击到的当前图片视图的图片
- (void)loadImageOfImageViewWithIndex:(NSInteger)Index {
    YHPhotoBrowserContentView *currentView = self.scrollView.subviews[Index];
    if (currentView.IsBeginLoading) {
        return;
    }
    // 先获取是否有高质量的图片的 URL, 如果没有就就讲之前显示的图片直接加载进来
    NSURL *highQURL = [self highQualityImageURLForIndex:Index];
    UIImage *lowQImage = [self lowQuailtyImageWithIndex:Index];
    if (highQURL.description.length) {
        [currentView setImageWithURL:highQURL placeholderImage:lowQImage];
    } else {
        currentView.imageView.image = lowQImage;
    }
    currentView.IsBeginLoading = YES;
}

#pragma mark  判断是否有代理返回高质量图片
- (NSURL *)highQualityImageURLForIndex:(NSInteger)Index {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageWithIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageWithIndex:Index];
    }
    return nil;
}

#pragma mark  如果没有高质量的图片,就把之前显示的小图片或者低质量的图片直接呈现给图片浏览器
- (UIImage *)lowQuailtyImageWithIndex:(NSInteger)Index {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:currentShowLowQualityImageWithIndex:)]) {
        return [self.delegate photoBrowser:self currentShowLowQualityImageWithIndex:Index];
    }
    return nil;
}

#pragma mark - 布局子视图
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.size.width += YHPhotoBrowserImageViewMargin * 2;
    self.scrollView.bounds = rect;
    self.scrollView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.subviews.count * self.scrollView.frame.size.width, self.scrollView.frame.size.height);

    self.scrollView.contentOffset = CGPointMake(self.ImageCurrentIndex * self.scrollView.frame.size.width, 0);
    CGFloat y = 0;
    CGFloat w = self.scrollView.frame.size.width - YHPhotoBrowserImageViewMargin * 2;
    CGFloat h = self.scrollView.frame.size.height;
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof YHPhotoBrowserContentView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat x = YHPhotoBrowserImageViewMargin + (w + YHPhotoBrowserImageViewMargin * 2) * idx;
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    if (!self.IsHaveShowFirstView) {
        [self showFirstImageOfTheImageView];
    }
}

#pragma mark 显示当前的图片视图的图片
- (void)showFirstImageOfTheImageView {
    UIView *sourceView = self.sourceImagesSuperView.subviews[self.ImageCurrentIndex];
    CGRect rect = [self.sourceImagesSuperView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:rect];
    tempImageView.image = [self lowQuailtyImageWithIndex:self.ImageCurrentIndex];
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:tempImageView];
    
    CGFloat lowQImageW = tempImageView.image.size.width;
    CGFloat lowQImageH = tempImageView.image.size.height;
    CGFloat scaleH = lowQImageH * Width_Screen / lowQImageW;
    
    CGRect tempImageViewF;
    if (scaleH < Height_Screen) {
        tempImageViewF = CGRectMake(0, (Height_Screen - scaleH) / 2, Width_Screen, scaleH);
    } else {
        tempImageViewF = CGRectMake(0, 0, Width_Screen, scaleH);
    }
    
    // 先隐藏
    self.scrollView.hidden = YES;
    self.currentPageLabel.hidden = YES;
    self.saveImageButton.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        tempImageView.frame = tempImageViewF;
    } completion:^(BOOL finished) {
        self.IsHaveShowFirstView = YES;
        [tempImageView removeFromSuperview];
        self.scrollView.hidden = NO;
        self.currentPageLabel.hidden = NO;
        self.saveImageButton.hidden = NO;
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger currentIndex = floor(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width + 0.5);
    self.ImageCurrentIndex = currentIndex;
    self.currentPageLabel.text = [NSString stringWithFormat:@"%zd / %zd", currentIndex + 1, self.ImageTotalCount];
    NSInteger left = currentIndex - 1;
    NSInteger right = currentIndex + 1;
    left = left > 0 ? left : 0;
    right = right > self.ImageTotalCount ? self.ImageTotalCount : right;
    // 滚动的时候加载当前页的图片和即将滚动到的图片视图的图片
    for (NSInteger i = left; i < right; i++) {
        [self loadImageOfImageViewWithIndex:i];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    for (YHPhotoBrowserContentView *browserContentView in self.scrollView.subviews) {
        [browserContentView.scrollView setZoomScale:1.0 animated:NO];
    }
}

#pragma mark - 设置界面元素
- (void)setupUI {
    self.backgroundColor = YHPhotoBrowserBackgroundColor;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelStatusBar + 10;
    // 1> 添加内容视图
    UIView *contentView = [[UIView alloc] initWithFrame:window.bounds];
    contentView.backgroundColor = YHPhotoBrowserBackgroundColor;
    self.center = contentView.center;
    self.bounds = contentView.bounds;

    [contentView addSubview:self];
    [window addSubview:contentView];

    // 2> 添加底部滚动视图
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    [self addSubview:scrollView];
    
    // a> 遍历图片数据源 添加滚动视图上面的图片视图
    for (NSInteger i = 0; i < self.ImageTotalCount; i++) {
        YHPhotoBrowserContentView *browserContentView = [[YHPhotoBrowserContentView alloc] init];
        browserContentView.imageView.tag = i;
        // 处理单击事件
        __weak typeof(self) weakSelf = self;
        [browserContentView setSingleTapBlock:^(UITapGestureRecognizer *singleTap){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf singleTapBlockCallBackHandle:singleTap];
        }];
        [scrollView addSubview:browserContentView];
    }
    
    // b> 先加载图片当前点击到的图片视图的图片
    [self loadImageOfImageViewWithIndex:self.ImageCurrentIndex];
    
    
    // 3> 添加一个显示当前页数的标签
    UILabel *currentPageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    currentPageLabel.center = CGPointMake(Width_Screen / 2, 30);
    currentPageLabel.textAlignment = NSTextAlignmentCenter;
    currentPageLabel.textColor = [UIColor whiteColor];
    currentPageLabel.font = [UIFont systemFontOfSize:20];
    currentPageLabel.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
    currentPageLabel.layer.cornerRadius = 15;
    currentPageLabel.layer.masksToBounds = YES;
    if (self.ImageTotalCount > 1) {
        currentPageLabel.text = [NSString stringWithFormat:@"%zd / %zd", self.ImageCurrentIndex + 1, self.ImageTotalCount];
    } else {
        currentPageLabel.hidden = YES;
    }
    [self addSubview:currentPageLabel];
    
    // 4>添加一个按钮,用于保存当前图片
    UIButton *saveImageButton = [[UIButton alloc] initWithFrame:CGRectMake(30, self.bounds.size.height - 75, 55, 30)];
    [saveImageButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveImageButton.layer.cornerRadius = 5;
    saveImageButton.layer.masksToBounds = YES;
    saveImageButton.layer.borderColor = [UIColor whiteColor].CGColor;
    saveImageButton.layer.borderWidth = 1;
    saveImageButton.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
    [self addSubview:saveImageButton];
    [saveImageButton addTarget:self action:@selector(saveCurrentImageIntoPhotoGallery) forControlEvents:UIControlEventTouchUpInside];
    
    // 属性记录
    _contentView = contentView;
    _scrollView = scrollView;
    _currentPageLabel = currentPageLabel;
    _saveImageButton = saveImageButton;
}

#pragma mark - 懒加载TipLabel
- (UILabel *)tipLabel {
    if (_tipLabel == nil) {
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
        tipLabel.center = self.center;
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
        tipLabel.layer.cornerRadius = 5;
        tipLabel.layer.masksToBounds = YES;
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = [UIFont systemFontOfSize:20];
        _tipLabel = tipLabel;
    }
    return _tipLabel;
}

@end














