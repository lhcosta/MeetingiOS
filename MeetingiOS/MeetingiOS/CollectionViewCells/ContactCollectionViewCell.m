//
//  ContactCollectionViewCell.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 03/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "ContactCollectionViewCell.h"

@implementation ContactCollectionViewCell

- (void)setContact:(Contact *)contact {
    [_email setText:contact.email];
}

@end
