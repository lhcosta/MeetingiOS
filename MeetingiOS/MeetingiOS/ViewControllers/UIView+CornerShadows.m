//
//  UIView+CornerShadows.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 15/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import "UIView+CornerShadows.h"

@implementation UIView (CornerShadows)

-(void) setupCornerRadiusShadow : (CACornerMask) maskedCorners {
    [self setupCornerRadiusShadow];
    self.layer.maskedCorners = maskedCorners;
}

- (void)setupCornerRadiusShadow {
    self.layer.shadowColor = UIColor.blackColor.CGColor;
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowRadius = 7;
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.cornerRadius = 7;
}

@end
