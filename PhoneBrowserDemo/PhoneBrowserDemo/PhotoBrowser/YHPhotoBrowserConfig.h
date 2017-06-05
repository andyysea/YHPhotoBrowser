//
//  YHPhotoBrowserConfig.h
//  PhoneBrowserDemo
//
//  Created by junde on 2017/6/2.
//  Copyright © 2017年 junde. All rights reserved.
//

/** 本文件用于添加浏览器的一些配置,便于修改样式等 */
#import <Foundation/Foundation.h>

/** 图片浏览器的背景颜色 */
#define  YHPhotoBrowserBackgroundColor  [UIColor blackColor]

/** 图片浏览器加载图片的进度视图的背景颜色 */
#define YHPhotoBrowserLoadingViewBackgroundColor [UIColor colorWithWhite:0 alpha:0.5]

/** 图片浏览器中图片之间的间距 */
#define YHPhotoBrowserImageViewMargin 10

/** 是否支持横屏 -> 默认支持 */
#define  IsSupportLandScape   YES

/** 是否在横屏的时候直接满宽度，而不是满高度，一般是在有长图需求的时候设置为YES */
#define IsFullWidthForLandScape YES

/** 最大图片缩放比 */
#define MaxZoomScale  4.0
/** 最小图片缩放比 */
#define MinZoomScale  0.5
