//
//  ContactTableViewCell.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 04/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

/// Detalhe dos contatos
@interface ContactTableViewCell : UITableViewCell

/// Contato
@property (nonatomic, nullable) Contact* contact;

@end

NS_ASSUME_NONNULL_END
