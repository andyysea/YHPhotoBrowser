//
//  YHPhotoBrowserView.h
//  YHPhotoBrowser
//
//  Created by YYH on 2017/6/3.
//  Copyright © 2017年 YYH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YHPhotoBrowserView;

@protocol YHPhotoBrowserViewDelegate <NSObject>

/** 返回图片浏览器当前的图片的下标 */
- (void)photoBrowserView:(YHPhotoBrowserView *)photoBrowser currentIndex:(NSInteger)index;

@end

@interface YHPhotoBrowserView : UIView

/** 保存当前图片到相册的按钮 */
@property (nonatomic, weak) UIButton *saveImageButton;

/** 代理属性 */
@property (nonatomic, weak) id <YHPhotoBrowserViewDelegate> delegate;

/**
 初始化方法 currentIndex 和 imageUrls 必传参数
 placeholderImage 和 sourceView 可为空
 
 @param currentIndex 当前的图片对应的数组下标
 @param imageUrls 图片浏览器要呈现的图片的URL数组
 @param placeholderImage 占位图片
 @param sourceView 原来的小图片的源视图/父视图,要保证这个视图上只有自己添加的图片视图
 @return 返回初始化的图片浏览器
 */
- (instancetype)initWithCurrentIndex:(NSInteger)currentIndex
                       imageURLArray:(NSArray <NSString *>*)imageUrls
                    placeholderImage:(UIImage *)placeholderImage
                          sourceView:(UIView *)sourceView;

/**
 展示图片浏览器
 */
- (void)show;

@end
