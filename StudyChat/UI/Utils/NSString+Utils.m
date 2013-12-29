//
//  NSString+Utils.m
//  BruinChat
//
//  Created by Christopher Laganiere on 12/28/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)
+ (NSString *) getCurrentTime {
    NSDate *nowUTC = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:nowUTC];
}
@end
