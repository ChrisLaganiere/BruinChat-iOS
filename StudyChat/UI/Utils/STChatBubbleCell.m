//
//  STChatBubbleCell.m
//  BruinChat
//
//  Created by Christopher Laganiere on 12/28/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STChatBubbleCell.h"
#import "STStyleSheet.h"

@implementation STChatBubbleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.senderAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
        [self.senderAndTimeLabel setTextAlignment:NSTextAlignmentCenter];
        self.senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
        self.senderAndTimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.senderAndTimeLabel];
        self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.bgImageView];
        self.messageContentView = [[UITextView alloc] init];
        self.messageContentView.backgroundColor = [UIColor clearColor];
        self.messageContentView.editable = NO;
        self.messageContentView.scrollEnabled = NO;
        self.messageContentView.font = [STStyleSheet chatFont];
        [self.messageContentView sizeToFit];
        [self.contentView addSubview:self.messageContentView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
