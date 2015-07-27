//
//  BZTimer.h
//  BiZhi
//
//  Created by shangjin on 15/7/23.
//  Copyright (c) 2015年 shangjin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @author shangjin, 15-07-23 20:07:25
 *
 * @brief  定时器的参数
 */
@interface BZTimer : NSObject <NSCoding>

@property (nonatomic, assign) NSInteger time;//时间，单位：秒,
@property (nonatomic, strong) NSURL * folder;//文件夹的地址，最多寻找三层
@property (nonatomic, assign) NSInteger imageCount;//数量，图片文件的数量
@property (nonatomic, assign) NSInteger currentImageIndex;//索引，当前图片的索引
@property (nonatomic, strong) NSArray * imageArray;//图片文件的路径
@property (nonatomic, strong) NSArray * gifArray;
@property (nonatomic, strong) NSArray * gifDelay;
@property (nonatomic, assign) NSInteger currentGifIndex;

@end
