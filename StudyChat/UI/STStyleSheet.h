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

+(void)styleRoundCorneredView:(UIView *)view;

@end
