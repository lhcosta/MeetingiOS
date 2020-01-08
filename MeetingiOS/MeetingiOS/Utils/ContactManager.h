//
//  ContactManager.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 04/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

/// Gerenciamento dos contatos do usuário.
@interface ContactManager : NSObject

+ (instancetype) shared;
- (instancetype) init NS_UNAVAILABLE;
- (instancetype) new NS_UNAVAILABLE;

/// Buscando todos os contatos do usuário que possuem email
/// @param allContacts enviando todos os contatos por meio de um bloco
-(void) fetchContactsWithEmail:(void (^)( NSDictionary<NSString*,NSArray<Contact*>*>* _Nullable contacts, NSError* _Nullable error))allContacts;


@end

NS_ASSUME_NONNULL_END
