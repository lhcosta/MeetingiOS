//
//  NewMeetingViewController+SettingPickers.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 08/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "NewMeetingViewController+SettingPickers.h"

@implementation NewMeetingViewController (SettingPickers)

- (void)pickerForNumberOfTopics {
    
    self.pickerView = [[UIPickerView alloc] init];
        
    [self.view addSubview:self.pickerView];  

    [self.pickerView setDataSource:self];
    [self.pickerView setDelegate:self];
    [self.pickerView setBackgroundColor: UIColor.opaqueSeparatorColor];
        
    [[self.pickerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
    [[self.pickerView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
    [[self.pickerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    [[self.pickerView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.175] setActive:YES];
        
    [self.pickerView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)setupDatePicker: (Time)time{
    
    self.datePicker = [[UIDatePicker alloc] init];
    
    self.datePicker.backgroundColor = UIColor.opaqueSeparatorColor;
    
    [self.view addSubview:self.datePicker];
    
    [[self.datePicker.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
    [[self.datePicker.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
    [[self.datePicker.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
        
    [self.datePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    if(time == Start) {
        
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        self.datePicker.minimumDate = NSDate.now;
        
        if([self.formatter dateFromString:self.startsDateTime.text] != NSDate.now) {
           self.datePicker.date = [self.formatter dateFromString:self.startsDateTime.text];
        } 
        
        [self.datePicker addTarget:self action:@selector(modifieDateTimeLabel:) forControlEvents: UIControlEventValueChanged];
        
    } else {
        
        self.datePicker.datePickerMode = UIDatePickerModeTime;
        self.datePicker.minimumDate = [self.formatter dateFromString:self.startsDateTime.text];
        
        [self.datePicker addTarget:self action:@selector(modifieTimeLabel:) forControlEvents:UIControlEventValueChanged];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 10;
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

- (void) dismissPicker {
    
}

@end
