//
//  ContactTableViewCell.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 04/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "ContactTableViewCell.h"

@implementation ContactTableViewCell

- (void)setContact:(Contact *)contact {
    _contact = contact;
    [self.textLabel setText:contact.name];
    [self.detailTextLabel setText:contact.email];
}

@end
