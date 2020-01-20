//
//  NewMeetingViewController+SettingPickers.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 08/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "NewMeetingViewController+SettingPickers.h"

@implementation NewMeetingViewController (SettingPickers)

- (void)setupDatePicker {
    
    self.startDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.startDatePicker.minimumDate = self.finishDatePicker.minimumDate = NSDate.now;
    
    if([self.formatter dateFromString:self.startsDateTime.text] != NSDate.now) {
        self.startDatePicker.date = [self.formatter dateFromString:self.startsDateTime.text];
    } 
    
    [self.startDatePicker addTarget:self action:@selector(modifieDateTimeLabel:) forControlEvents: UIControlEventValueChanged];
    [self.finishDatePicker addTarget:self action:@selector(modifieTimeLabel:) forControlEvents:UIControlEventValueChanged];
    
    self.finishDatePicker.datePickerMode = UIDatePickerModeTime;

}

- (void) modifieDateTimeLabel:(UIDatePicker*)datePicker {
    self.startsDateTime.text = self.endesDateTime.text = [self.formatter stringFromDate:datePicker.date];
    self.finishDatePicker.minimumDate = [self.formatter dateFromString:self.startsDateTime.text];
}

- (void) modifieTimeLabel:(UIDatePicker*)datePicker {
    self.endesDateTime.text = [self.formatter stringFromDate:datePicker.date];
}

@end
