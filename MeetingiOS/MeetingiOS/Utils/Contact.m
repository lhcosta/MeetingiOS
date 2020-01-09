//
//  Contact.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 03/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "Contact.h"

@implementation Contact

//MARK:- Initializer
- (instancetype)initWithContact:(CNContact *)contact {
    self = [super init];
    
    if(self) {
        _name = [contact givenName];
        _email = [contact.emailAddresses.firstObject value];
    }
    
    return self;
}

@end
