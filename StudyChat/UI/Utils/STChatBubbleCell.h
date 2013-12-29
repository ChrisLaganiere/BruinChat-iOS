//
//  STChatBubbleCell.h
//  BruinChat
//
//  Created by Christopher Laganiere on 12/28/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STChatBubbleCell : UITableViewCell
@property (nonatomic, strong) UILabel *senderAndTimeLabel;
@property (nonatomic, strong) UITextView *messageContentView;
@property (nonatomic, strong) UIImageView *bgImageView;
@end
