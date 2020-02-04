//
//  UIView+CornerShadows.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 15/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (CornerShadows)

/// Definindo sombra e bordas arredondadas para a view.
/// @param maskedCorners quais bordas serão arredondadas.
-(void) setupCornerRadiusShadow : (CACornerMask) maskedCorners;

/// Definindo sombra e bordas arredondadas para a view.
-(void) setupCornerRadiusShadow;

/// Definir apenas sombra.
- (void) setupShadow;

@end

NS_ASSUME_NONNULL_END
