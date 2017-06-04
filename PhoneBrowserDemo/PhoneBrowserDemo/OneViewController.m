//
//  OneViewController.m
//  PhoneBrowserDemo
//
//  Created by junde on 2017/5/27.
//  Copyright © 2017年 junde. All rights reserved.
//

#import "OneViewController.h"
#import <UIImageView+WebCache.h>

#define  ScreenWidth   [UIScreen mainScreen].bounds.size.width
#define  ScreenHeight  [UIScreen mainScreen].bounds.size.height
#define  ImageHeight   ScreenWidth * 9 / 16

@interface OneViewController ()<UIScrollViewDelegate>

/** 网络数据的图片 URL数组 */
@property (nonatomic, strong) NSArray *imageArray;

/** 底层添加的滚动图片的滚动视图 */
@property (nonatomic, weak) UIScrollView *imageScrollView;

/** 顶层控制器水平图片滚动视图的滚动视图 */
@property (nonatomic, weak) UIScrollView *wrapperScrollView;

/** 中间滚动视图 */
@property (nonatomic, weak) UIScrollView *scrollView;

/** 当前页数 */
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    
    [self loadData];
    
    // 初始化当前页数
    _currentPage = 1;
}


#pragma mark - 点按手势
- (void)tapClick {
    NSLog(@"--> %zd", _currentPage);
    // 点击之后,跳转图片浏览器
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
 
    CGFloat offsetY = self.scrollView.contentOffset.y + self.scrollView.contentInset.top;
    CGFloat offsetX = self.wrapperScrollView.contentOffset.x;
    
    NSInteger page = floor(offsetX / ScreenWidth + 0.5);
    if (offsetY < 0) {
        UIImageView *imageView = nil;
        for (UIView *subView in self.imageScrollView.subviews) {
            if ([subView isKindOfClass:[UIImageView class]]) {
                if (subView.tag == page) {
                    imageView = (UIImageView *)subView;
                }
            }
        }
        
        CGFloat scaleWidth = (ABS(offsetY) + ScreenWidth * 9 / 16) * ScreenWidth / (ScreenWidth * 9 / 16);
        CGRect rect = CGRectMake(- (scaleWidth - ScreenWidth) / 2 + ScreenWidth * page, 64, scaleWidth, ABS(offsetY) + ScreenWidth * 9 / 16);
        imageView.frame = rect;
    
        CGRect frame = self.imageScrollView.frame;
        
        frame.origin.y = 0;
        self.imageScrollView.frame = frame;
    } else {
     
        self.imageScrollView.contentOffset = CGPointMake(offsetX, offsetY);
//     
        CGRect rect = self.imageScrollView.frame;
        

        rect.origin.y = - offsetY / 2;
        self.imageScrollView.frame = rect;

    }
    
    _currentPage = page + 1;
    
}

#pragma mark - 模拟加载数据
- (void)loadData {
    _imageArray =  @[
                     @"http://ww2.sinaimg.cn/thumbnail/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg",
                     @"http://ww2.sinaimg.cn/thumbnail/642beb18gw1ep3629gfm0g206o050b2a.gif",
                     @"http://ww4.sinaimg.cn/thumbnail/9e9cb0c9jw1ep7nlyu8waj20c80kptae.jpg",
                     @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg",
                     @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg",
                     @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",
                     @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg",
                     @"http://ww2.sinaimg.cn/thumbnail/677febf5gw1erma104rhyj20k03dz16y.jpg",
                     @"http://ww4.sinaimg.cn/thumbnail/677febf5gw1erma1g5xd0j20k0esa7wj.jpg"
                     ];

    // 请求完毕数据之后,设置图片
    NSInteger index = 0;
    for (NSString *urlStr in _imageArray) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(index * ScreenWidth, 64, ScreenWidth, ImageHeight)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"hehe"]];
        imageView.tag = index;
        index++;
        [self.imageScrollView addSubview:imageView];
    }
    self.imageScrollView.contentSize = CGSizeMake(_imageArray.count * ScreenWidth, ImageHeight);
    self.wrapperScrollView.contentSize = CGSizeMake(_imageArray.count * ScreenWidth, ImageHeight);
    
    
}


#pragma mark - 设置界面元素
- (void)setupUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = @"one";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    imageScrollView.backgroundColor = [UIColor clearColor];
    imageScrollView.showsHorizontalScrollIndicator = NO;
    imageScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:imageScrollView];
    
    UIScrollView *wrapperScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ImageHeight)];
    wrapperScrollView.backgroundColor = [UIColor clearColor];
    wrapperScrollView.delegate = self;
    wrapperScrollView.pagingEnabled = YES;
    wrapperScrollView.showsVerticalScrollIndicator = NO;
    wrapperScrollView.showsHorizontalScrollIndicator = NO;
//    wrapperScrollView.contentSize = CGSizeMake(imagesArray.count * ImageWidth, ImageHeight);

    // 添加点按手势
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [wrapperScrollView addGestureRecognizer:tapgesture];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, ImageHeight + 64, ScreenWidth, ScreenHeight)];
    imageView.image = [UIImage imageNamed:@"dummyProfile"];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.contentSize = CGSizeMake(ScreenWidth, 64 + ImageHeight + ScreenHeight);
    [scrollView addSubview:wrapperScrollView];
    [scrollView addSubview:imageView];
    [self.view addSubview:scrollView];

    // 记录属性
    _imageScrollView = imageScrollView;
    _wrapperScrollView = wrapperScrollView;
    _scrollView = scrollView;
}




@end
