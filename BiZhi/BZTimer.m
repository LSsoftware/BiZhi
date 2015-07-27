//
//  BZTimer.m
//  BiZhi
//
//  Created by shangjin on 15/7/23.
//  Copyright (c) 2015年 shangjin. All rights reserved.
//

#import "BZTimer.h"

@implementation BZTimer

- (instancetype)init
{
    if (self = [super init]) {
        self.time=0;
        self.folder=[NSURL URLWithString:@""];
        self.imageCount=0;
        self.currentImageIndex=-1;
        self.imageArray=@[];
        self.gifArray=@[];
        self.gifDelay=@[];
        self.currentGifIndex=-1;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.time = [aDecoder decodeIntegerForKey:@"time"];
        self.folder = [aDecoder decodeObjectForKey:@"folder"];
        self.imageCount=[aDecoder decodeIntegerForKey:@"imageCount"];
        self.currentImageIndex=[aDecoder decodeIntegerForKey:@"currentImageIndex"];
        self.imageArray=[aDecoder decodeObjectForKey:@"imageArray"];
        self.gifArray=[aDecoder decodeObjectForKey:@"gifArray"];
        self.gifDelay=[aDecoder decodeObjectForKey:@"gifDelay"];
        self.currentGifIndex=[aDecoder decodeIntegerForKey:@"currentGifIndex"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.time forKey:@"time"];
    [aCoder encodeObject:self.folder forKey:@"folder"];
    [aCoder encodeInteger:self.imageCount forKey:@"imageCount"];
    [aCoder encodeInteger:self.currentImageIndex forKey:@"currentImageIndex"];
    [aCoder encodeObject:self.imageArray forKey:@"imageArray"];
    [aCoder encodeObject:self.gifArray forKey:@"gifArray"];
    [aCoder encodeObject:self.gifDelay forKey:@"gifDelay"];
    [aCoder encodeInteger:self.currentGifIndex forKey:@"currentGifIndex"];
}

@end
