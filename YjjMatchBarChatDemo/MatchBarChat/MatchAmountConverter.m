//
//  MatchAmountConverter.m
//  YjjMatchBarChatDemo
//
//  Created by YjjTT on 2018/3/16.
//  Copyright © 2018年 YjjTT. All rights reserved.
//

#import "MatchAmountConverter.h"

NSString * subConvert (NSString*str){
    if (!str) return nil;
    int len=[str length];
    if (len>4)return nil;
    NSMutableString*newStr=[[NSMutableString alloc]initWithString:str];
    while ([newStr hasPrefix:@"0"]){
        [newStr deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    if (!newStr||newStr==@"") return nil;
    int isZero=0;
    NSMutableString*result=[[NSMutableString alloc]initWithCapacity:1];
    NSString*referenceStr=@"零一二三四五六七八九";
    NSString*positionRef=@"个十百千";
    len=[newStr length];
    for (int i=0; i<len; i++){
        int ch=[[newStr substringWithRange:NSMakeRange(i, 1)]intValue];
        if (ch){
            if (isZero){
                [result appendFormat:@"零"];
            }
            [result appendString:[referenceStr substringWithRange:NSMakeRange(ch, 1)]];
            
            if (i!=len-1){
                [result appendString:[positionRef substringWithRange:NSMakeRange(len-1-i, 1)]];
            }
        }else{
            isZero=1;
        }
    }
    
    return result;
}

NSString* convert(NSString*str){
    if (!str||str==@"") return nil;
    NSMutableString*newStr=[[NSMutableString alloc]initWithString:str];
    while ([newStr hasPrefix:@"0"]){
        [newStr deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    if (!newStr||newStr==@"") return nil;
    if ([newStr length]>12)return nil;
    NSString*string;
    NSMutableString*result=[[NSMutableString alloc]initWithCapacity:1];
    if ([newStr length]>8){
        string=[newStr substringToIndex:[newStr length]-8];
        [result appendString:subConvert(string)];
        [result appendFormat:@"亿"];
        [newStr deleteCharactersInRange:NSMakeRange(0, [newStr length]-8)];
    }
    if ([newStr length]>4){
        string=[newStr substringToIndex:[newStr length]-4];
        if (![string isEqual:@"0000"]){
            if ([string hasPrefix:@"0"]){
                [result appendFormat:@"零"];
            }
            [result appendString:subConvert(string)];
            [result appendFormat:@"万"];
        }
        [newStr deleteCharactersInRange:NSMakeRange(0, [newStr length]-4)];
    }
    string=newStr;
    if (![string isEqual:@"0000"]){
        if ([string hasPrefix:@"0"]){
            [result appendFormat:@"零"];
        }
        [result appendString:subConvert(string)];
    }
    return result;
}
