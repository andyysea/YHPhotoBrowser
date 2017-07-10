//
//  YHPhotoBrowserView.m
//  YHPhotoBrowser
//
//  Created by YYH on 2017/6/3.
//  Copyright © 2017年 YYH. All rights reserved.
//

#import "YHPhotoBrowserView.h"
#import "YHPhotoBrowserContentView.h"
#import <UIImageView+WebCache.h>


#define Width_Screen  [UIScreen mainScreen].bounds.size.width
#define Height_Screen [UIScreen mainScreen].bounds.size.height

@interface YHPhotoBrowserView ()<UIScrollViewDelegate>

/** 外部添加图片组的容器视图/父视图 */
@property (nonatomic, weak) UIView *sourceView;
/** 当前的显示的图片/点击的图片 */
@property (nonatomic, assign) NSInteger currentIndex;
/** 图片浏览器要显示的图片的URL数组 */
@property (nonatomic, strong) NSArray <NSString *>*imageURLArray;
/** 占位图片 */
@property (nonatomic, strong) UIImage *placeholderImage;

/** 底层添加的滚动视图 */
@property (nonatomic, weak) UIScrollView *scrollView;
/** 显示当前页数/总页数的标签 */
@property (nonatomic, weak) UILabel *currentPageLabel;


/** 提示标签是否能够保存图片,保存成功与否 */
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation YHPhotoBrowserView

#pragma mark - 初始化方法
- (instancetype)initWithCurrentIndex:(NSInteger)currentIndex
                       imageURLArray:(NSArray <NSString *>*)imageUrls
                    placeholderImage:(UIImage *)placeholderImage
                          sourceView:(UIView *)sourceView {
    self = [super init];
    if (self) {
        
        //****************** 清除缓存,便于测试 *********************
//        [[SDWebImageManager sharedManager].imageCache clearDisk];
        
        _currentIndex = currentIndex;
        _imageURLArray = imageUrls;
        _placeholderImage = placeholderImage;
        _sourceView = sourceView;
        if (!placeholderImage) {
            _placeholderImage  = [UIImage imageNamed:@"placeholderImage"];
        }
        
        [self setupUI];
    }
    return self;
}

#pragma mark - 展示图片浏览器
- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelStatusBar;
    [window addSubview:self];
}

#pragma mark - 退出图片浏览器按钮的点击方法
- (void)exitButtonClick {
    self.window.windowLevel = UIWindowLevelNormal;
    CGAffineTransform transform = self.transform;
    transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.25 animations:^{
        self.transform  = transform;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 保存按钮点击方法
- (void)saveCurrentImageIntoPhotoGallery {
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;
    YHPhotoBrowserContentView *browserContentView = self.scrollView.subviews[index];
    if (browserContentView.IsHaveLoaded) {
        UIImageWriteToSavedPhotosAlbum(browserContentView.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    } else {
        self.tipLabel.text = @"加载中,请稍后🙂!";
        self.tipLabel.center = self.center;
        [self addSubview:self.tipLabel];
        [self bringSubviewToFront:self.tipLabel];
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
    self.tipLabel.center = self.center;
    [self addSubview:self.tipLabel];
    [self bringSubviewToFront:self.tipLabel];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tipLabel removeFromSuperview];
    });
}


#pragma mark - 单点手势的回调处理
- (void)singleTapBlockCallBackHandle:(UITapGestureRecognizer *)singleTap {
    
    if (!self.sourceView) {
        self.window.windowLevel = UIWindowLevelNormal;
        CGAffineTransform transform = self.transform;
        transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.25 animations:^{
            self.transform  = transform;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
        return;
    }
    YHPhotoBrowserContentView *browserContentView = (YHPhotoBrowserContentView *)singleTap.view;
    UIImageView *currentImageView = browserContentView.imageView;
    UIImageView *sourceImageView = self.sourceView.subviews[self.currentIndex]
    ;
    CGRect tempRect = [self.sourceView convertRect:sourceImageView.frame toView:self];
    NSLog(@"--> %@",NSStringFromCGRect(tempRect));
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:currentImageView.image];
    CGFloat scaleH = tempImageView.image.size.height * Width_Screen / tempImageView.image.size.width;
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
    self.window.windowLevel = UIWindowLevelNormal;
    [UIView animateWithDuration:0.25 animations:^{
        tempImageView.frame = tempRect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger currentIndex = floor(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width + 0.5);
    self.currentPageLabel.text = [NSString stringWithFormat:@"%zd / %zd", currentIndex + 1, self.imageURLArray.count];
    if ([self.delegate respondsToSelector:@selector(photoBrowserView:currentIndex:)]) {
        [self.delegate photoBrowserView:self currentIndex:currentIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    for (YHPhotoBrowserContentView *browserContentView in scrollView.subviews) {
        [browserContentView.scrollView setZoomScale:1.0 animated:NO];
    }
    NSInteger currentIndex = floor(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width + 0.5);
    self.currentIndex = currentIndex;
    NSInteger left = currentIndex - 1;
    NSInteger right = currentIndex + 1;
    left = left > 0 ? left : 0;
    right = right > self.imageURLArray.count ? self.imageURLArray.count : right;
    // 滚动的时候加载当前页的图片和即将滚动到的图片视图的图片
    for (NSInteger Index = left; Index < right; Index++) {
        [self loadImageOfTheImageViewWithIndex:Index];
    }
}

#pragma mark - 根据当前对应的数组的下标加载图片的下标
- (void)loadImageOfTheImageViewWithIndex:(NSInteger)index {
    YHPhotoBrowserContentView *browserContentView = self.scrollView.subviews[index];
    if (browserContentView.IsBeginLoading) {
        return;
    }
    browserContentView.IsBeginLoading = YES;
    NSURL *url = [NSURL URLWithString:self.imageURLArray[index]];
    [browserContentView setImageWithURL:url placeholderImage:self.placeholderImage];
}

#pragma mark - 动画显示第一张图片
- (void)showFirstImageAnimation {
    if (!self.sourceView) {
        return;
    }
    UIImageView *sourceImageView = self.sourceView.subviews[self.currentIndex];
    CGRect fromRect = [self.sourceView convertRect:sourceImageView.frame toView:self];
    
    //    NSLog(@"fromRect--> %@",NSStringFromCGRect(fromRect));
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:fromRect];
    tempImageView.image = sourceImageView.image;
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:tempImageView];
    
    CGFloat tempW = tempImageView.image.size.width;
    CGFloat tempH = tempImageView.image.size.height;
    CGFloat scaleH = tempH * Width_Screen / tempW;
    CGRect tempRect;
    if (scaleH < Height_Screen) {
        tempRect = CGRectMake(0, (Height_Screen - scaleH) / 2, Width_Screen, scaleH);
    } else {
        tempRect = CGRectMake(0, 0, Width_Screen, scaleH);
    }
    
    self.scrollView.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        tempImageView.frame = tempRect;
    } completion:^(BOOL finished) {
        [tempImageView removeFromSuperview];
        self.scrollView.hidden = NO;
    }];
}

#pragma mark - 设置界面元素
- (void)setupUI {
    self.backgroundColor = [UIColor blackColor];
    self.frame = [UIScreen mainScreen].bounds;
    
    // 1> 添加底层滚动视图
    CGFloat margin = 10;
    CGRect rect = self.bounds;
    rect.size.width += margin * 2; // 图片之前留边距
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:rect];
    scrollView.center = self.center;
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    [self addSubview:scrollView];
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width * self.imageURLArray.count, scrollView.bounds.size.height);
    scrollView.contentOffset = CGPointMake(self.currentIndex * scrollView.bounds.size.width, 0);
    
    //  在滚动视图上添加单个能够缩放的图片视图
    CGFloat x = margin;
    CGFloat y = 0;
    CGFloat w = scrollView.bounds.size.width - 2 * margin;
    CGFloat h = scrollView.bounds.size.height;
    CGRect contentRect = CGRectMake(x, y, w, h);
    for (NSInteger Index = 0; Index < self.imageURLArray.count; Index++) {
        YHPhotoBrowserContentView *browserContentView = [[YHPhotoBrowserContentView alloc] initWithFrame:contentRect];
        browserContentView.frame = CGRectOffset(contentRect, Index * scrollView.bounds.size.width, 0);
        browserContentView.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:browserContentView];
        
        __weak typeof(self) weakSelf = self;
        [browserContentView setSingleTapBlock:^(UITapGestureRecognizer *singleTap){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf singleTapBlockCallBackHandle:singleTap];
        }];
    }
    
    // 2> 添加一个显示当前页数的标签
    UILabel *currentPageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    currentPageLabel.center = CGPointMake(Width_Screen / 2, 30);
    currentPageLabel.textAlignment = NSTextAlignmentCenter;
    currentPageLabel.textColor = [UIColor whiteColor];
    currentPageLabel.font = [UIFont systemFontOfSize:25];
    currentPageLabel.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
    currentPageLabel.layer.cornerRadius = 15;
    currentPageLabel.layer.masksToBounds = YES;
    if (self.imageURLArray.count > 1) {
        currentPageLabel.text = [NSString stringWithFormat:@"%zd / %zd", self.currentIndex + 1, self.imageURLArray.count];
    } else {
        currentPageLabel.hidden = YES;
    }
    [self addSubview:currentPageLabel];
    
    // 3>添加一个按钮,用于保存当前图片
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
    
    // 4> 添加一个退出图片浏览器的按钮
    UIButton *exitButton = [[UIButton alloc] initWithFrame:CGRectMake(Width_Screen - 50, 20, 20, 20)];
    [exitButton setBackgroundImage:[UIImage imageNamed:@"bowser_x_icon"] forState:UIControlStateNormal];
    [self addSubview:exitButton];
    [exitButton addTarget:self action:@selector(exitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    // 属性记录
    _scrollView = scrollView;
    _currentPageLabel = currentPageLabel;
    _saveImageButton = saveImageButton;
    
    // 动画显示点击的一张图片
    [self showFirstImageAnimation];
    // 加载当前要展示给用户第一眼看到的图片
    [self loadImageOfTheImageViewWithIndex:self.currentIndex];
}


#pragma mark - 懒加载TipLabel
- (UILabel *)tipLabel {
    if (_tipLabel == nil) {
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
        tipLabel.layer.cornerRadius = 5;
        tipLabel.layer.masksToBounds = YES;
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = [UIFont systemFontOfSize:20];
        _tipLabel = tipLabel;
    }
    return _tipLabel;
}

@end
