//
//  ContactCollectionView.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 03/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ContactCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactCollectionView : NSObject 

/// Todos os contatos selecionados
@property (nonatomic) NSMutableArray* contacts;

@end

NS_ASSUME_NONNULL_END
