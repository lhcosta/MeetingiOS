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
    self.startDatePicker.minimumDate = NSDate.now;
    
    if([self.formatter dateFromString:self.startsDateTime.text] != NSDate.now) {
        self.startDatePicker.date = [self.formatter dateFromString:self.startsDateTime.text];
    } 
    
    [self.startDatePicker addTarget:self action:@selector(modifieDateTimeLabel:) forControlEvents: UIControlEventValueChanged];
    
    
    self.finishDatePicker.datePickerMode = UIDatePickerModeTime;
    self.finishDatePicker.minimumDate = [self.formatter dateFromString:self.startsDateTime.text];
    [self.finishDatePicker addTarget:self action:@selector(modifieTimeLabel:) forControlEvents:UIControlEventValueChanged];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 5;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld", row + 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.numbersOfTopics setText:[NSString stringWithFormat:@"%ld", row + 1]];
}

- (void) modifieDateTimeLabel:(UIDatePicker*)datePicker {
    self.startsDateTime.text = self.endesDateTime.text = [self.formatter stringFromDate:datePicker.date];
}

- (void) modifieTimeLabel:(UIDatePicker*)datePicker {
    self.endesDateTime.text = [self.formatter stringFromDate:datePicker.date];
}

@end
