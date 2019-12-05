//
//  MeetingDelegate.h
//  MeetingiOS
//
//  Created by Caio Azevedo on 05/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "Contact.h"

@protocol MeetingDelegate <NSObject>

@required
- (void) selectedColor:(NSString*)hex;
- (void) selectedContacts:(NSArray<Contact*>*)contacts;

@end
