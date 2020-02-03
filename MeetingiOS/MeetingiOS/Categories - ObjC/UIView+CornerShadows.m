//
//  UIView+CornerShadows.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 15/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import "UIView+CornerShadows.h"
#import <MeetingiOS-Swift.h>

@implementation UIView (CornerShadows)

-(void) setupCornerRadiusShadow : (CACornerMask) maskedCorners {
    [self setupCornerRadiusShadow];
    self.layer.maskedCorners = maskedCorners;
}

- (void)setupCornerRadiusShadow {
    self.layer.shadowColor = [[UIColor alloc] initWithHexString:@"#00000029" alpha:1].CGColor;
    self.layer.masksToBounds = YES;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowRadius = 1;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.clipsToBounds = false;
    
    self.layer.cornerRadius = 5;
}

@end
