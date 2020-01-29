//
//  ContactCollectionView.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 03/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Contact.h"
#import "ContactCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactCollectionView : NSObject <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
 
/// Inicializar com imagens de remoão de contato.
/// @param isRemoveContact imagem de remover ou não.
-(instancetype) initWithRemoveContact:(BOOL) isRemoveContact;

/// Imagens de remover contato.
@property (nonatomic) BOOL isRemoveContact;

/// Todos os contatos selecionados
@property (nonatomic, readonly) NSArray<Contact*>* contacts;

/// Adicionando um novo contato.
/// @param contact novo contato
- (void) addContact : (Contact*) contact;

/// Removendo contato.
/// @param index índice contato.
- (void) removeContactIndex : (NSInteger) index;

/// Adicionando um array de contatos.
/// @param contacts array de contatos
- (void) addContacts : (NSArray<Contact*>*) contacts;

@end

NS_ASSUME_NONNULL_END
