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
    
    NSUInteger lenght = 20;
    NSString* currenText = textField.text;
    
    NSRange nameRange = NSRangeFromString(currenText);
    
    NSString* updateText = [currenText stringByReplacingCharactersInRange:nameRange withString:string];
    
    return updateText.length <= lenght;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

@end
