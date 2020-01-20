//
//  TopicsPerPersonPickerView.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 20/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import "TopicsPerPersonPickerView.h"

@implementation TopicsPerPersonPickerView

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
    [self.delegate changedNumberOfTopics:row+1];
}

@end
