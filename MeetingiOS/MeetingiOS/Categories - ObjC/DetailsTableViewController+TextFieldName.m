//
//  DetailsTableViewController+TextFieldName.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 22/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import "DetailsTableViewController+TextFieldName.h"
#import <MeetingiOS-Swift.h>

@class Meeting;

@implementation DetailsTableViewController (TextFieldName)

/// Realizando algumas configuracoes quando o botao de return for apertado.
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [textField setUserInteractionEnabled:NO];
    [self.modifyName setHidden:NO];
    
    //Retornando ao ultimo nome caso não seja preenchido
    if(textField.text.length == 0) {
        [textField setText:self.meeting.theme];
    }
    
    return YES;
}

/// Validando o número de caracteres do nome da reunião.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(newString.length > 30)
        return NO;
    
    return YES;
}


@end
