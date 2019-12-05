//
//  UIView+SetupBounds.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 02/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SetupBounds)

///  Arrendondado as bordas de uma view.
/// @param maskCorners quais são as bordas.
- (void)setupBounds:(CACornerMask)maskCorners;

@end

NS_ASSUME_NONNULL_END
