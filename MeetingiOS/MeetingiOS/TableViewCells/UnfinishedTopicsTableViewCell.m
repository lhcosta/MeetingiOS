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
//    [_topicTextField becomeFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}


- (BOOL)becomeFirstResponder {
    return self.topicTextField.becomeFirstResponder;
}

@end
