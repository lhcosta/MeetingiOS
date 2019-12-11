//
//  NewMeetingViewController.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 02/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+SetupBounds.h"
#import "ContactCollectionView.h"
#import <CloudKit/CloudKit.h>
#import "MeetingDelegate.h"


NS_ASSUME_NONNULL_BEGIN

/// View Controllers para criar uma nova reuinao
@interface NewMeetingViewController : UITableViewController<MeetingDelegate>

/// Definir o tempo inicial ou final da reuniao
typedef enum Time {
    Start,
    Finish,
} Time;

//MARK:- IBOutlets
@property (nonatomic, weak) IBOutlet UILabel* startsDateTime;
@property (nonatomic, weak) IBOutlet UILabel* endesDateTime;
@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;
@property (nonatomic, weak) IBOutlet UITextField* nameMetting;
@property (nonatomic, weak) IBOutlet UIButton* colorMetting;
@property (nonatomic, weak) IBOutlet UILabel* numbersOfTopics;
@property (nonatomic, weak) IBOutlet UIPickerView* pickerView;
@property (nonatomic, nullable) UIDatePicker* datePicker;
@property (nonatomic, nonnull) NSDateFormatter* formatter;

///Selecionando a cor do ícone da reunião.
- (IBAction) chooseColorMeeting:(id)sender;

@end

NS_ASSUME_NONNULL_END
