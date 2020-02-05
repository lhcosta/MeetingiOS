//
//  UIViewController+StatusBarBackground.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 03/02/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (StatusBarBackground)

/// Adicionando cor ao background da status bar.
/// @param color cor escolhida.
/// @param view view para ser adicionado.
- (void)addColorToStatusBarBackground:(UIColor *)color inView:(UIView*)view;

@end

NS_ASSUME_NONNULL_END
