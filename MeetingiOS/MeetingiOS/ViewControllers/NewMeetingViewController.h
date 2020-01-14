//
//  NewMeetingViewController.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 02/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
#import "MeetingDelegate.h"


NS_ASSUME_NONNULL_BEGIN

/// View Controllers para criar uma nova reuinao
@interface NewMeetingViewController : UITableViewController<MeetingDelegate>

//MARK:- IBOutlets
@property (nonatomic, weak) IBOutlet UILabel* startsDateTime;
@property (nonatomic, weak) IBOutlet UILabel* endesDateTime;
@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;
@property (nonatomic, weak) IBOutlet UITextField* nameMetting;
@property (nonatomic, weak) IBOutlet UIButton* colorMetting;
@property (nonatomic, weak) IBOutlet UILabel* numbersOfTopics;
@property (nonatomic, weak) IBOutlet UILabel* numbersOfPeople;
@property (nonatomic, weak) IBOutlet UIPickerView* pickerView;
@property (nonatomic, weak) IBOutlet UIDatePicker* startDatePicker;
@property (nonatomic, weak) IBOutlet UIDatePicker* finishDatePicker;
@property (nonatomic, nonnull) NSDateFormatter* formatter;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *views;


///Selecionando a cor do ícone da reunião.
- (IBAction) chooseColorMeeting:(id)sender;

@end

NS_ASSUME_NONNULL_END
