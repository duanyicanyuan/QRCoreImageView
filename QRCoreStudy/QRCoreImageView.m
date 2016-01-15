//
//  QRCoreImageView.m
//  Demo-CustomQRCore
//
//  Created by caiqiujun on 16/1/15.
//  Copyright © 2016年 yourtion. All rights reserved.
//

#import "QRCoreImageView.h"

@implementation QRCoreImageView

/**
 *  根据Url和颜色生成图片
 *
 *  url 网址
 *
 *  color 二维码颜色，如果为nil，即默认黑白色
 *
 *  size 二维码宽度
 */
- (instancetype)initWithUrl:(NSString *)url Color:(UIColor *)color withSize:(CGFloat) size
{
    self = [super init];
    if (self) {
        UIImage *codeImage = [self createCreateImageWithUrl:url Color:color withSize:size];
        self.image = codeImage;
        
    }
    return self;
}
/**
 *  设置阴影效果（可选方法）
 *
 *  offset 阴影偏移
 *
 *  radius 阴影半径
 *
 *  color 阴影颜色
 *
 *  opacity 阴影的透明度
 */
-(void)setShadowWithOffset:(CGSize)offset radius:(CGFloat)radius color:(UIColor *)color opacity:(CGFloat)opacity {
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOpacity = opacity;
}


-(UIImage *)createCreateImageWithUrl:(NSString *)url Color:(UIColor *)color withSize:(CGFloat) size {
    UIImage *codeImage = nil;
    // 创建黑白的CIImage
    CIImage *image = [self createQRForString:url];
    // CIImage->UIImage
    codeImage = [self createNonInterpolatedUIImageFormCIImage:image withSize:size];
    if (color != nil) {
        CGColorRef colorRef = [color CGColor];
        long numComponents = CGColorGetNumberOfComponents(colorRef);
        
        if (numComponents == 4)
        {
            const CGFloat *components = CGColorGetComponents(colorRef);
            codeImage = [self imageBlackToTransparent:codeImage withRed:components[0] * 255 andGreen:components[1] * 255 andBlue:components[2] * 255];
        }
    }
    return codeImage;
}

// CIImage-->固定尺寸的UIImage
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // create a bitmap image that we'll draw into a bitmap context at the desired size;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // Create an image with the contents of our bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // Cleanup
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

// 根据qrString的URL网址生成CIImage图片
- (CIImage *)createQRForString:(NSString *)qrString {
    // NSString -> NSData
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // Send the image back
    return qrFilter.outputImage;
}

#pragma mark - imageToTransparent
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

// 因为生成的二维码是黑白的，所以还要对二维码进行颜色填充，并转换为透明背景，使用遍历图片像素来更改图片颜色，因为使用的是CGContext，速度非常快：
- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // context to image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}


@end
