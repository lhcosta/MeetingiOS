//
//  UIView+CornerShadows.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 15/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import "UIView+CornerShadows.h"
#import <Meeting-Swift.h>

@implementation UIView (CornerShadows)

-(void) setupCornerRadiusShadow : (CACornerMask) maskedCorners {
    [self setupCornerRadiusShadow];
    self.layer.maskedCorners = maskedCorners;
}

- (void)setupCornerRadiusShadow {
    [self setupShadow];
    [self setupCorners];
}

- (void) setupShadow {
    self.layer.shadowColor = [[UIColor alloc] initWithHexString:@"#00000029" alpha:1].CGColor;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowRadius = 1;
    self.layer.masksToBounds = YES;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.clipsToBounds = false;
}

- (void) setupCorners {
    self.layer.cornerRadius = 5;
}

@end
