//
//  ContactCollectionViewCell.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 03/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

/// Contato selecionado
@interface ContactCollectionViewCell : UICollectionViewCell

/// Email do contato
@property (nonatomic, weak) IBOutlet UILabel* name;

//Imagem de remoção ou não de contato.
@property (nonatomic, weak) IBOutlet UIImageView* contactImage;

/// Contato
@property (nonatomic) Contact* contact;

@end

NS_ASSUME_NONNULL_END
