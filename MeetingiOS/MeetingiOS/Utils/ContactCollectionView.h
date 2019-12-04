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

/// Todos os contatos selecionados
@property (nonatomic) NSArray<Contact*>* contacts;


@end

NS_ASSUME_NONNULL_END
