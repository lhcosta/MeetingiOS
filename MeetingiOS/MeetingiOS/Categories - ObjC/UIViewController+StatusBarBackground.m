//
//  UIViewController+StatusBarBackground.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 03/02/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import "UIViewController+StatusBarBackground.h"

@implementation UIViewController (StatusBarBackground)

- (void)addColorToStatusBarBackground:(UIColor *)color inView:(UIView *)view {
    
    if(view.window) {
        CGRect statusBarFrame = [self.view.window.windowScene.statusBarManager statusBarFrame];
        UIView* statusBarView = [[UIView alloc] initWithFrame:statusBarFrame];
        [statusBarView setBackgroundColor:color];
        [view addSubview:statusBarView];
    }  
}

@end
