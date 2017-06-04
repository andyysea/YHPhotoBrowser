//
//  YHPhotoBrowserView.h
//  PhoneBrowserDemo
//
//  Created by junde on 2017/6/2.
//  Copyright © 2017年 junde. All rights reserved.
//


/** 本类是本人自定义的图片浏览器视图 */

#import <UIKit/UIKit.h>


@interface YHPhotoBrowserView : UIView

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
