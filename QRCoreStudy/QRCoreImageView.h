//
//  QRCoreImageView.h
//  Demo-CustomQRCore
//
//  Created by caiqiujun on 16/1/15.
//  Copyright © 2016年 yourtion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCoreImageView : UIImageView
// init方法
- (instancetype)initWithUrl:(NSString *)url Color:(UIColor *)color withSize:(CGFloat) size;

// 设置阴影
-(void)setShadowWithOffset:(CGSize)offset radius:(CGFloat)radius color:(UIColor *)color opacity:(CGFloat)opacity;

@end
