//
//  YHPhotoBrowserContentView.h
//  YHPhotoBrowser
//
//  Created by YYH on 2017/6/3.
//  Copyright © 2017年 YYH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHPhotoBrowserContentView : UIView

/** 滚动视图 */
@property (nonatomic, weak) UIScrollView *scrollView;
/** 加载的需要缩放的图片 */
@property (nonatomic, weak) UIImageView *imageView;


/** 讲单点手势传递给上一级视图做处理 -> 退出浏览器 */
@property (nonatomic, copy) void (^singleTapBlock)(UITapGestureRecognizer *tapGesture);

/** 是否开始加载当前单个图片视图的图片 */
@property (nonatomic, assign) BOOL IsBeginLoading;
/** 图片是否加载完成,并加载成功 -> 没有加载完成不能缩放和保存 */
@property (nonatomic, assign) BOOL IsHaveLoaded;

/** 设置图片的URL,以及占位图片 */
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

@end
