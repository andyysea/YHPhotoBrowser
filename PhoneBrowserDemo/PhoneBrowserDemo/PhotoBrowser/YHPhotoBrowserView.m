//
//  YHPhotoBrowserView.m
//  PhoneBrowserDemo
//
//  Created by junde on 2017/6/2.
//  Copyright © 2017年 junde. All rights reserved.
//

#import "YHPhotoBrowserView.h"
#import "YHPhotoBrowserConfig.h"


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

#pragma mark - 展示图片浏览器 
- (void)showPhotoBrowser {
    
    
    // 处理横屏竖屏问题
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 这里先调用一次,为了横屏打开图片时候的处理
        [self currentDeviceOrientationChange];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    });
    
    
    
}

#pragma mark - 监听设备屏幕方向变化的处理
- (void)currentDeviceOrientationChange {
    
    if (!IsSupportLandScape) {
        return;
    }
    
}


#pragma mark - 设置界面元素
- (void)setupUI {
    self.backgroundColor = YHPhotoBrowserBackgroundColor;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
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
        
    }
    
    // 属性记录
    _contentView = contentView;
    _scrollView = scrollView;
}



@end














