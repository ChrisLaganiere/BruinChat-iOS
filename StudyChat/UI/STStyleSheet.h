//
//  STStyleSheet.h
//  BruinChat
//
//  Created by Christopher Laganiere on 12/18/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STStyleSheet : NSObject

+(UIColor*)navigationColor;
+(UIColor*)tintColor;
+(UIColor*)textFieldColor;
+(UIFont *)chatFont;
+(UIFont *)labelFont;
+(UIFont *)titleFont;
+(UIFont *)subtitleFont;
+(UIColor *)titleColor;
+(UIColor *)titleShadowColor;

+(UIView*)titleViewWithTitle:(NSString *)title;
+(void)styleRoundCorneredView:(UIView *)view;
+(void)styleNavButtonsForNavBar:(UINavigationBar *)navBar;
+(void)styleNavButtonsForToolbar:(UIToolbar *)toolbar;

@end
