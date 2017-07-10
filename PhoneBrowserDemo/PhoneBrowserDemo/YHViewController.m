//
//  YHViewController.m
//  PhoneBrowserDemo
//
//  Created by YYH on 2017/6/6.
//  Copyright © 2017年 YYH. All rights reserved.
//

#import "YHViewController.h"
#import "YHPhotoBrowserView.h"
#import <UIImageView+WebCache.h>


#define Width_Screen  [UIScreen mainScreen].bounds.size.width
#define Height_Screen [UIScreen mainScreen].bounds.size.height

#define ImageHeight  (Width_Screen * 330 / 750)
#define MyImageViewTag  10010
@interface YHViewController ()<UIScrollViewDelegate, YHPhotoBrowserViewDelegate>

/** 数组 */
@property (nonatomic, strong) NSArray *urlArray;
/** 当前图片 */
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, weak) UIScrollView *imageScrollView;

@property (nonatomic, weak) UILabel *currentPageLabel;

@end

@implementation YHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

#pragma mark - 点击手势
- (void)tapGestureRecognizer {
    
    NSLog(@"tap--> 点击了");
    // 1> 图片加载完毕,再让点击, (没有加载完毕也可以)
    UIImage *currentImage = [((UIImageView *)(self.imageScrollView.subviews[self.currentPage])) image];;
    if (!currentImage) {
        return;
    }
    
    // 2> 弹出图片浏览器
    YHPhotoBrowserView *photoBrowserView = [[YHPhotoBrowserView alloc] initWithCurrentIndex:self.currentPage imageURLArray:self.urlArray placeholderImage:nil sourceView:self.imageScrollView];
    photoBrowserView.delegate = self;
    [photoBrowserView show];
    
}

#pragma mark - YHPhotoBrowserViewDelegate
- (void)photoBrowserView:(YHPhotoBrowserView *)photoBrowser currentIndex:(NSInteger)index {
    
    self.currentPage = index;
    self.currentPageLabel.text = [NSString stringWithFormat:@"%zd / %zd", self.currentPage + 1, self.urlArray.count];
    
    self.imageScrollView.contentOffset = CGPointMake(self.currentPage * Width_Screen, 0);
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetX = scrollView.contentOffset.x;
    self.currentPage = floor(offsetX / Width_Screen + 0.5);
    
    self.currentPageLabel.text = [NSString stringWithFormat:@"%zd / %zd", self.currentPage + 1, self.urlArray.count];
}

#pragma mark - 设置界面元素
- (void)setupUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIScrollView *imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, Width_Screen, Height_Screen - 64)];
    imageScrollView.backgroundColor = [UIColor clearColor];
    imageScrollView.pagingEnabled = YES;
    imageScrollView.showsVerticalScrollIndicator = NO;
    imageScrollView.showsHorizontalScrollIndicator = NO;
    imageScrollView.delegate = self;
    [self.view addSubview:imageScrollView];
    
    NSInteger index = 0;
    for (NSString *urlStr in self.urlArray) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(index * Width_Screen, 30, Width_Screen, ImageHeight)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
        imageView.tag = index + MyImageViewTag;
        index++;
        [imageScrollView addSubview:imageView];
    }
    
    imageScrollView.contentSize = CGSizeMake(self.urlArray.count * Width_Screen, ImageHeight);
    
    UILabel *currentPageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 64 + ImageHeight + 50, Width_Screen - 20, 30)];
    currentPageLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:currentPageLabel];
    currentPageLabel.text = [NSString stringWithFormat:@"1 / %zd", self.urlArray.count];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer)];
    [imageScrollView addGestureRecognizer:tapGesture];
    
    _imageScrollView = imageScrollView;
    _currentPageLabel = currentPageLabel;
}

#pragma mark - 图片链接数组
- (NSArray *)urlArray {
    if (_urlArray == nil) {
        NSArray *urlArray = @[
                              @"https://k.sinaimg.cn/n/default/1_img/uplaod/3933d981/20170620/tipu-fyhfxph4165571.jpg/w640slw.jpg",
                              @"https://k.sinaimg.cn/n/default/1_img/uplaod/3933d981/20170620/YUqj-fyhfxph4165596.jpg/w640slw.jpg",
                              @"http://www.36588.com.cn:8080/ImageResourceMongo/UploadedFile/dimension/big/f639a80b-caa7-40ad-938d-2de882c93934.png",
                              @"http://img.tupianzj.com/uploads/allimg/160229/9-160229114J2-51.jpg"
                              ];
        _urlArray = urlArray;
    }
    return _urlArray;
}

@end
