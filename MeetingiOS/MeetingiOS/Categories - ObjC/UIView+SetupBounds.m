//
//  UIView+SetupBounds.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 02/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "UIView+SetupBounds.h"

@implementation UIView (SetupBounds)

- (void)setupBounds:(CACornerMask)maskCorners {

    self.layer.maskedCorners = maskCorners;
    self.layer.masksToBounds = true;
    self.layer.cornerRadius = 15;
    
}


@end
