//
//  DetailsTableViewController.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 14/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
#import "Contact.h"
#import "MeetingDelegate.h"

@class Meeting;

NS_ASSUME_NONNULL_BEGIN

@interface DetailsTableViewController : UITableViewController

//MARK:- IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *meetingName;
@property (weak, nonatomic) IBOutlet UILabel *meetingAdmin;
@property (weak, nonatomic) IBOutlet UILabel *startsDate;
@property (weak, nonatomic) IBOutlet UILabel *endesDate;
@property (weak, nonatomic) IBOutlet UILabel *numbersOfPeople;
@property (weak, nonatomic) IBOutlet UILabel *topicsPerPerson;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionParticipants;
@property (weak, nonatomic) IBOutlet UIButton *modifyName;
@property (nonatomic, weak) IBOutlet UIDatePicker* startDatePicker;
@property (nonatomic, weak) IBOutlet UIDatePicker* finishDatePicker;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *views;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

/// Reunião
@property (nonatomic) Meeting* meeting;


@end

NS_ASSUME_NONNULL_END
