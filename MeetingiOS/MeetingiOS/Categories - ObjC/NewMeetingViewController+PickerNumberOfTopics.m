//
//  NewMeetingViewController+PickerNumberOfTopics.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 07/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "NewMeetingViewController+PickerNumberOfTopics.h"


@implementation NewMeetingViewController (PickerNumberOfTopics)

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

@end
