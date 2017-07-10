//
//  YHPhotoBrowserLoadingView.h
//  YHPhotoBrowser
//
//  Created by YYH on 2017/6/3.
//  Copyright © 2017年 YYH. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, YHPhotoBrowserLoadingType){
    YHPhotoBrowserLoadingLoopDiagram,  // 环形
    YHPhotoBrowserLoadingPieDiagram    // 饼形
};

@interface YHPhotoBrowserLoadingView : UIView

/** 加载进度类型 --> 默认环形 */
@property (nonatomic, assign) YHPhotoBrowserLoadingType loadingType;

/** 加载的进度 */
@property (nonatomic, assign) CGFloat progress;

@end
