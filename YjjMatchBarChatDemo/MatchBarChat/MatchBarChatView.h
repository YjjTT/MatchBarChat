//
//  MatchBarChatView.h
//  YjjMatchBarChatDemo
//
//  Created by YjjTT on 2018/3/16.
//  Copyright © 2018年 YjjTT. All rights reserved.
//

#pragma mark - UIColor宏定义

#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define UIColorFromRGB(rgbValue) UIColorFromRGBA(rgbValue, 1.0)

#import <UIKit/UIKit.h>

@protocol MatchBarChatDelegate <NSObject>

- (void)didSelectedBallAtIndex:(NSInteger)index;

@end

@interface MatchBarChatView : UIView

- (instancetype)initWithFrame:(CGRect)frame array:(NSArray *)array;

@property (nonatomic, strong) NSMutableArray *videoIdArray;

@property (nonatomic, weak)id<MatchBarChatDelegate>delegate;

@end
