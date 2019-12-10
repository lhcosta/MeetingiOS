//
//  MeetingDelegate.h
//  MeetingiOS
//
//  Created by Caio Azevedo on 05/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "Contact.h"
#import <CloudKit/CloudKit.h>

@protocol MeetingDelegate <NSObject>

@required
/// Enviando a cor selecionado.
- (void) selectedColor:(NSString*)hex;

- (void)getRecordForSelectedUsers;

@end
