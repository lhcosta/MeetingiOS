//
//  NewMeetingViewController+NameMeetingValidation.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 05/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "NewMeetingViewController+NameMeetingValidation.h"

@implementation NewMeetingViewController (NameMeetingValidation)

/// Validando o número de caracteres do nome da reunião.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(newString.length > 20)
        return NO;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

@end
