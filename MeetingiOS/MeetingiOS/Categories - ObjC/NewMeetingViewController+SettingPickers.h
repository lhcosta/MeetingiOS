//
//  NewMeetingViewController+SettingPickers.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 08/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "NewMeetingViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewMeetingViewController (SettingPickers)<UIPickerViewDataSource, UIPickerViewDelegate>

/// Criar date picker para selecionar datas da reunião.
/// @param time inicial ou final.
- (void)setupDatePicker: (Time)time;

/// Modificando o label de data e hora da reunião.
/// @param datePicker objeto date picker
- (void) modifieDateTimeLabel:(UIDatePicker*)datePicker;

/// Modificando o label de hora final da reunião.
/// @param datePicker objeto date picker
- (void) modifieTimeLabel:(UIDatePicker*)datePicker;

@end

NS_ASSUME_NONNULL_END
