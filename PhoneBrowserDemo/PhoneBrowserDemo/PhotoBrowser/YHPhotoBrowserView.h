//
//  YHPhotoBrowserView.h
//  PhoneBrowserDemo
//
//  Created by junde on 2017/6/2.
//  Copyright © 2017年 junde. All rights reserved.
//


/** 本类是本人自定义的图片浏览器视图 */

#import <UIKit/UIKit.h>
@class YHPhotoBrowserView;


@protocol YHPhotoBrowserViewDelegate <NSObject>

@required
/** 当前显示的低质量的图片返回给图片浏览器 */
- (UIImage *)photoBrowser:(YHPhotoBrowserView *)browserView currentShowLowQualityImageWithIndex:(NSInteger)Index;

@optional
/** 如果有高质量的图片可以使用,则优先加载高质量的图片以供缩放查看 */
- (NSURL *)photoBrowser:(YHPhotoBrowserView *)browserView highQualityImageWithIndex:(NSInteger)index;

@end


@interface YHPhotoBrowserView : UIView

/** 代理属性 */
@property (nonatomic, weak) id <YHPhotoBrowserViewDelegate>delegate;

/**
 图片浏览器初始化方法
 
 @param currentIndex 当前的显示的图片/点击的图片
 @param totalCount   总的图片数量
 @param sourceView   外部添加图片组的容器视图/父视图
 @return 初始化好的图片浏览器视图
 */
- (instancetype)initWithImageCurrentIndex:(NSInteger)currentIndex
                          imageTotalCount:(NSInteger)totalCount
                    sourceImagesSuperView:(UIView *)sourceView;
/** 展示图片浏览器 */
- (void)showPhotoBrowser;

@end
