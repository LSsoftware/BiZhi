//
//  AppDelegate.h
//  BiZhi
//
//  Created by shangjin on 15/7/15.
//  Copyright (c) 2015年 shangjin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BZTimer.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) BZTimer * timerModel;

- (void)getData;
- (void)storeData;
- (void)startTimer;//开始计时器
- (void)stopTimer;//结束计时器

@end

