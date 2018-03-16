//
//  CustomTextLayer.m
//  YjjMatchBarChatDemo
//
//  Created by YjjTT on 2018/3/16.
//  Copyright © 2018年 YjjTT. All rights reserved.
//

#import "CustomTextLayer.h"

@interface CustomTextLayer (){
    int count;
}
@property (nonatomic, assign)NSInteger interval;
@property (nonatomic, strong)NSTimer *timer;

@end

@implementation CustomTextLayer

- (void)startTime:(NSInteger)interval{
    count = 0;
    _interval = interval;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

- (void)timerFired{
    self.string = [NSString stringWithFormat:@"%d", count];
    if (count == _interval) {
        [_timer invalidate];
    }
    count++;
}

@end
