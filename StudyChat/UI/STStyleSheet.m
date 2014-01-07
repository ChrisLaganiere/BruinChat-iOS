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
+(UIColor*)textFieldColor
{
    //light blue
    UIColor *navColor = [UIColor colorWithRed:0.835 green:0.882 blue:1 alpha:1]; /*#d5e1ff*/
    return navColor;
}
+(UIFont *)chatFont
{
    UIFont *chatFont = [UIFont boldSystemFontOfSize:13];
    return chatFont;
}
+(UIFont *)labelFont
{
    UIFont *labelFont = [UIFont boldSystemFontOfSize:15];
    return labelFont;
}

@end
