//
//  STStyleSheet.m
//  BruinChat
//
//  Created by Christopher Laganiere on 12/18/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STStyleSheet.h"

@implementation STStyleSheet

+(UIColor*)navigationColor
{
    //light blue
    UIColor *navColor = [UIColor colorWithRed:.59 green:.70 blue:1.0 alpha:1];
    return navColor;
}
+(UIColor*)tintColor
{
    //light blue
    UIColor *navColor = [UIColor whiteColor];
    return navColor;
}
+(UIFont *)chatFont
{
    UIFont *chatFont = [UIFont boldSystemFontOfSize:13];
    return chatFont;
}

@end
