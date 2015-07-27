//
//  AppDelegate.m
//  BiZhi
//
//  Created by shangjin on 15/7/15.
//  Copyright (c) 2015年 shangjin. All rights reserved.
//

#import "AppDelegate.h"
//#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>
//#import <CoreFoundation/CoreFoundation.h>

@interface AppDelegate ()

@property (nonatomic, strong) NSTimer*gifTimer;
//更换背景图片
- (void)setDesktopBackgoundImage:(NSURL*)bgImageUrl;
- (void)setImageWhenTimeout;

@end

@implementation AppDelegate
- (void)applicationWillBecomeActive:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [self storeData];
}

- (void)getData
{
    //获取数据
    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString * filePath = [NSString stringWithFormat:@"%@/BiZhi.file",[paths lastObject]];
    NSFileManager*manager=[NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        self.timerModel=[NSKeyedUnarchiver unarchiveObjectWithData:[manager contentsAtPath:filePath]];
    }else {
        self.timerModel = [[BZTimer alloc]init];
    }
    
    if (self.timerModel.imageArray.count>0&&self.timerModel.time>0) {
        [self startTimer];
    }
}

- (void)storeData
{
    //保存数据
    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString * filePath = [NSString stringWithFormat:@"%@/BiZhi.file",[paths lastObject]];
    NSData*data = [NSKeyedArchiver archivedDataWithRootObject:self.timerModel];
    NSFileManager*manager=[NSFileManager defaultManager];
    [manager createFileAtPath:filePath contents:data attributes:nil];
}

- (void)startTimer
{
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timerModel.time target:self selector:@selector(setImageWhenTimeout) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer=nil;
    }
}

- (void)setImageWhenTimeout
{
    NSURL*oldUrl = [self.timerModel.imageArray objectAtIndex:self.timerModel.currentImageIndex];
    if ([oldUrl.path rangeOfString:@".gif" options:NSCaseInsensitiveSearch].location!=NSNotFound) {
        [self stopGif];
    }
    self.timerModel.currentImageIndex+=1;
    if (self.timerModel.currentImageIndex>=self.timerModel.imageArray.count) {
        self.timerModel.currentImageIndex=0;
    }
    NSURL*bgImageUrl = [self.timerModel.imageArray objectAtIndex:self.timerModel.currentImageIndex];
    NSMutableArray*images=[NSMutableArray array];
    NSMutableArray*delayTimes=[NSMutableArray array];
    NSInteger total = [self getGif:bgImageUrl image:&images delay:&delayTimes];
    if (total>0) {
        self.timerModel.gifArray=images;
        self.timerModel.gifDelay=delayTimes;
        self.timerModel.currentGifIndex=0;
        [self startGifs];
    }else {
        [self setDesktopBackgoundImage:bgImageUrl];
    }
}

- (void)setDesktopBackgoundImage:(NSURL*)bgImageUrl
{
    NSWorkspace*workspace = [NSWorkspace sharedWorkspace];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSWorkspaceDesktopImageAllowClippingKey, [NSNumber numberWithInteger:NSImageScaleProportionallyUpOrDown], NSWorkspaceDesktopImageScalingKey, nil];
    NSError*error;
//    NSLog(@"%@",[workspace desktopImageOptionsForScreen:[NSScreen mainScreen]]);
    BOOL result = [workspace setDesktopImageURL:bgImageUrl forScreen:[NSScreen mainScreen] options:options error:&error];
    
    if (!result) {
        [NSApp presentError:error];
//        NSLog(@"失败");
//    }else {
//        NSLog(@"成功");
    }
}

- (NSInteger)getGif:(NSURL*)fileurl image:(NSMutableArray**)images delay:(NSMutableArray**)delayTimes
{
    if ([fileurl.path rangeOfString:@".gif" options:NSCaseInsensitiveSearch].location == NSNotFound) {
        return 0;
    }
    NSInteger total = 0;
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileurl, NULL);
    
    // get image count
    size_t imageCount = CGImageSourceGetCount(gifSource);
    for (size_t i = 0; i < imageCount; ++i) {
        // get each image
        CGImageRef image = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        NSImage*im=[[NSImage alloc]initWithCGImage:(CGImageRef)image size:NSZeroSize];
        //保存到本地
        NSArray*paths=NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString * filePath = [NSString stringWithFormat:@"%@/tempfile%d.jpg",[paths lastObject],(int)i];
        NSData*dd=im.TIFFRepresentation;
        [dd writeToFile:filePath atomically:NO];
        //使用本地图片
        NSURL * fileUrl = [NSURL fileURLWithPath:filePath];
        [*images addObject:fileUrl];
//        if (fileUrl) {
//            NSLog(@"file  存在  是 ： %@",fileUrl);
//        }
        CGImageRelease(image);
        
        // get gif info with each frame
        NSDictionary *dict = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL));
//        NSLog(@"kCGImagePropertyGIFDictionary %@", [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary]);
        
        // kCGImagePropertyGIFDictionary中kCGImagePropertyGIFDelayTime，kCGImagePropertyGIFUnclampedDelayTime值是一样的
        NSDictionary *gifDict = [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
        [*delayTimes addObject:[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime]];
        
        if (total>=0) {
            total = total + [[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
        }
    }
    return total;
}



- (void)startGifs
{
    [self stopGif];
    //显示当前图片
    NSURL*fileUrl = [self.timerModel.gifArray objectAtIndex:self.timerModel.currentGifIndex];
    [self setDesktopBackgoundImage:fileUrl];
    //延时时间
    CGFloat delaytime = [[self.timerModel.gifDelay objectAtIndex:self.timerModel.currentGifIndex] floatValue];
    self.gifTimer=[NSTimer scheduledTimerWithTimeInterval:delaytime target:self selector:@selector(startGifs) userInfo:nil repeats:NO];
    self.timerModel.currentGifIndex+=1;
    if (self.timerModel.currentGifIndex>self.timerModel.gifArray.count-1) {
        self.timerModel.currentGifIndex=0;
    }
}

- (void)stopGif
{
    if (self.gifTimer) {
        [self.gifTimer invalidate];
        self.gifTimer=nil;
    }
}

@end
