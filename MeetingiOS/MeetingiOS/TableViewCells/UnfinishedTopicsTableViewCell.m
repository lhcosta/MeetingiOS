//
//  UnfinishedTopicsTableViewCell.m
//  MeetingiOS
//
//  Created by Paulo Ricardo on 12/4/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "UnfinishedTopicsTableViewCell.h"

@implementation UnfinishedTopicsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = UIColor.clearColor;
    self.layer.masksToBounds = YES;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowRadius = 1;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.clipsToBounds = false;
    
    self.contentView.backgroundColor = [UIColor colorNamed:@"ColorTableViewCell"];
    self.contentView.layer.cornerRadius = 5;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
