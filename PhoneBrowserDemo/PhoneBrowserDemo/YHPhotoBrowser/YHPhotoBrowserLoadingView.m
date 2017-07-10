//
//  YHPhotoBrowserLoadingView.m
//  YHPhotoBrowser
//
//  Created by YYH on 2017/6/3.
//  Copyright © 2017年 YYH. All rights reserved.
//

#import "YHPhotoBrowserLoadingView.h"

@implementation YHPhotoBrowserLoadingView

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        self.frame = CGRectMake(0, 0, 50, 50); // 默认自身大小
        self.layer.cornerRadius = 25;
        self.layer.masksToBounds = YES;
        
        self.loadingType = YHPhotoBrowserLoadingLoopDiagram;
    }
    return self;
}

#pragma mark - 进度属性的setter方法
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
    if (progress >= 1) {
        [self removeFromSuperview];
    }
}

#pragma mark - 重写drawRect方法
- (void)drawRect:(CGRect)rect {
    
    CGContextRef contexR = UIGraphicsGetCurrentContext();
    CGFloat centerX = rect.size.width / 2;
    CGFloat centerY = rect.size.height / 2;
    [[UIColor whiteColor] set];
    
    switch (self.loadingType) {
        case YHPhotoBrowserLoadingLoopDiagram:
        {
            CGContextSetLineWidth(contexR, 5);
            CGContextSetLineCap(contexR, kCGLineCapRound);
            CGFloat radius = MIN(centerX, centerY) - 5;
            CGFloat from = - M_PI / 2;
            CGFloat to = - M_PI / 2 + self.progress * 2 * M_PI + 0.1;
            CGContextAddArc(contexR, centerX, centerY, radius, from, to, 0);
            CGContextStrokePath(contexR);
        }
            break;
        case YHPhotoBrowserLoadingPieDiagram:
        {
            CGFloat width = MIN(rect.size.width ,rect.size.height) - 4;  // 46
            CGFloat height = width;                                      // 46
            CGFloat x = (rect.size.width - width) / 2;                   // 2
            CGFloat y = (rect.size.height - height) / 2;                 // 2
            CGContextAddEllipseInRect(contexR, CGRectMake(x, y, width, height));
            CGContextFillPath(contexR);
            
            [[UIColor colorWithWhite:0 alpha:0.7] set];
            CGContextMoveToPoint(contexR, centerX, centerY);
            CGContextAddLineToPoint(contexR, centerX, 0);
            CGFloat radius = width / 2 - 2;
            CGFloat from = - M_PI / 2;
            CGFloat to = - M_PI / 2 + self.progress * 2 * M_PI + 0.1;
            CGContextAddArc(contexR, centerX, centerY, radius, from, to, 1);
            CGContextClosePath(contexR);
            CGContextFillPath(contexR);
        }
            break;
        default:
            break;
    }
    
}


@end
