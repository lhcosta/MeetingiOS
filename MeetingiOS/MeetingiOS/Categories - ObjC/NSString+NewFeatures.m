//
//  NSString+NewFeatures.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 04/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "NSString+NewFeatures.h"

@implementation NSString (NewFeatures)

- (BOOL)validateEmail {
    
    NSString* emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}";
    
    NSPredicate* emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailPredicate evaluateWithObject:self];
}

@end
