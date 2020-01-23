//
//  Contact.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 03/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import "Contact.h"

@class User;

NS_ASSUME_NONNULL_BEGIN

/// Contato para serem escolhidos para reunião

@interface Contact : NSObject

/// Contato selecionada para reunião
@property (nonatomic) BOOL isSelected;

/// Nome do Contato
@property (nonatomic, copy, nullable, readonly) NSString* name;

/// Email do Contato
@property (nonatomic, copy, nullable, readonly) NSString* email;

/// Inicializar com o CNContact
-(instancetype) initWithContact:(CNContact*)contact;

/// Criando contato com nome e email.
/// @param user usuário.
- (instancetype)initWithUser:(User*)user;

@end

NS_ASSUME_NONNULL_END
