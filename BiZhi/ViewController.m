//
//  ViewController.m
//  BiZhi
//
//  Created by shangjin on 15/7/23.
//  Copyright (c) 2015年 shangjin. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (weak) IBOutlet NSTextField *tip;//提示
@property (weak) IBOutlet NSTextField *timeLabel;//时间提示
@property (weak) IBOutlet NSDatePicker *timePicker;//时间选取
@property (weak) IBOutlet NSButton *setTimeButton;//设置时间
@property (weak) IBOutlet NSTextField *filePathLabel;//设置文件路径
@property (weak) IBOutlet NSButton *findFolderButton;//打开文件按钮
@property (nonatomic, strong) AppDelegate * app;

@end

@implementation ViewController

/**
 * @author shangjin, 15-07-23 22:07:31
 *
 * @brief  根据时间获取时间字符串
 *
 * @param time 时间
 *
 * @return 返回时间字符串
 */
- (NSString*)getTimeFromAppTimer:(NSInteger)time
{
    NSInteger hours=time/3600;
    NSInteger minutes=(time-time/3600)/60;
    NSInteger seconds=time-hours*3600-minutes*60;
    NSString*hour=@"";
    NSString*minute=@"";
    NSString*second=@"";
    if (hours>0) {
        hour=[NSString stringWithFormat:@" %d %@",(int)hours,NSLocalizedString(@"hours", nil)];
    }
    if (minutes>0) {
        minute=[NSString stringWithFormat:@"%d %@",(int)minutes,NSLocalizedString(@"minutes", nil)];
    }
    if (seconds>0) {
        second=[NSString stringWithFormat:@"%d %@",(int)seconds,NSLocalizedString(@"seconds", nil)];
    }
    NSString*t=[NSString stringWithString:hour];
    if (minutes>0) {
        t=[t stringByAppendingString:[NSString stringWithFormat:@" %@",minute]];
    }
    if (seconds>0) {
        t=[t stringByAppendingString:[NSString stringWithFormat:@" %@",second]];
    }
    return t;
}

- (void)setParams
{
    NSInteger time = self.app.timerModel.time;
    self.timeLabel.stringValue=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"The time is :", nil),[self getTimeFromAppTimer:time]];
    NSDateFormatter*formatter=[[NSDateFormatter alloc] init];
    formatter.dateFormat=@"HH-mm-dd";
    NSInteger hours=time/3600;
    NSInteger minutes=(time-time/3600)/60;
    NSInteger seconds=time-hours*3600-minutes*60;
    self.timePicker.dateValue=[formatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d",(int)hours,(int)minutes,(int)seconds]];
    if (self.app.timerModel.folder.path) {
        self.filePathLabel.stringValue=self.app.timerModel.folder.path;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.app=[NSApplication sharedApplication].delegate;
    [self.app getData];
    // Do view setup here.
    self.tip.stringValue=NSLocalizedString(@"Your can open it in preference next time", nil);
    [self setParams];
}
- (IBAction)setAction:(id)sender {
    NSDate*timeDate = self.timePicker.dateValue;
    NSDateFormatter*formatter=[[NSDateFormatter alloc] init];
    formatter.dateFormat=@"HH-mm-ss";
    NSString*timeString=[formatter stringFromDate:timeDate];
    NSArray*timeArray=[timeString componentsSeparatedByString:@"-"];
    NSInteger hours = [[timeArray objectAtIndex:0] integerValue];
    NSInteger minutes = [[timeArray objectAtIndex:1] integerValue];
    NSInteger seconds = [[timeArray objectAtIndex:2] integerValue];
    NSInteger time = hours*3600 + minutes * 60 + seconds;
    self.app.timerModel.time=time;
    [self setParams];
    [self start];
}

- (IBAction)findfolderAction:(id)sender {
    // Open file.
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    panel.title = @"Choose a folder";
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    
    
    if ([panel runModal]) {
        for (NSURL *fileURL in[panel URLs]) {
            // Read dictionary file into NSData object.
            NSFileManager*manager=[NSFileManager defaultManager];
         	   NSArray*fileArray=[manager contentsOfDirectoryAtURL:fileURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];
            
            self.app.timerModel.folder=fileURL;
            [self setParams];
            if (fileArray) {
                NSArray*imageArray=[self getImagesFromFileArray:fileArray withIndex:0];
                self.app.timerModel.imageArray=[NSArray arrayWithArray:imageArray];
                [self start];
            }
        }
    }
}

- (void)start
{
    if (self.app.timerModel.imageArray.count>0&&self.app.timerModel.time>0) {
        [self.app startTimer];
    }else {
        [self.app stopTimer];
    }
}

- (NSArray*)getImagesFromFileArray:(NSArray*)fileArray withIndex:(NSInteger)index
{
    NSMutableArray*imageArray=[NSMutableArray array];
    for (NSInteger i = 0; i<fileArray.count; i++) {
        NSString*filePath=[NSString stringWithFormat:@"%@",[fileArray objectAtIndex:i]];
        
//        NSString*last = [filePath substringFromIndex:filePath.length-1];
//        if ([last isEqualToString:@"/"] && index < 3) {
//            NSFileManager*manager=[NSFileManager defaultManager];
//            NSArray*subFileArray=[manager contentsOfDirectoryAtURL:[NSURL URLWithString:filePath] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];
//            NSArray*subImageArray=[self getImagesFromFileArray:subFileArray withIndex:index+1];
//            [imageArray addObjectsFromArray:subImageArray];
//        }else {
            NSRange range=[filePath rangeOfString:@"."];
            if (range.location!=NSNotFound) {
                NSString * fileType = [filePath substringFromIndex:range.location+1];
                if ([fileType rangeOfString:@"jpg"].location!=NSNotFound || [fileType rangeOfString:@"png"].location!=NSNotFound || [fileType rangeOfString:@"jpeg"].location!=NSNotFound || [fileType rangeOfString:@"svg"].location!=NSNotFound || [fileType rangeOfString:@"gif"].location!=NSNotFound ) {
                    [imageArray addObject:[NSURL URLWithString:filePath]];
                }
            }
//        }
    }
    return imageArray;
}

@end
