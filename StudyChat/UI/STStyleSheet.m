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
    UIFont *chatFont = [UIFont systemFontOfSize:15];
    return chatFont;
}
+(UIFont *)labelFont
{
    //used by send button
    UIFont *labelFont = [UIFont boldSystemFontOfSize:15];
    return labelFont;
}

+(UIFont *)titleFont
{
    //used by send button
    UIFont *titlefont = [UIFont fontWithName:@"Quicksand" size:24.0];
    return titlefont;
}
+(UIFont *)subtitleFont
{
    //used by send button
    UIFont *titlefont = [UIFont fontWithName:@"Quicksand" size:18.0];
    return titlefont;
}
+(UIColor*)titleColor
{
    //white
    UIColor *titleColor = [UIColor whiteColor];
    return titleColor;
}
+(UIColor*)titleShadowColor
{
    //black
    UIColor *titleShadowColor = [UIColor blackColor];
    return titleShadowColor;
}

+(void)styleRoundCorneredView:(UIView *)view
{
    view.layer.cornerRadius = 4.f;
    view.layer.masksToBounds = YES;
    view.clipsToBounds = YES;
}


@end
