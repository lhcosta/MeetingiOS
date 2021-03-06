//
//  Contact.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 03/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "Contact.h"
#import <MeetingiOS-Swift.h>

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

- (instancetype)initWithUser:(User *)user {
    
    self = [super init];
    
    if(self) {
        _name = [user name];
        _email = [user email];
    }
    
    return self;
}

//Debug
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ -> %@", self.name, self.email];
}

@end
