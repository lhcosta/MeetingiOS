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
#import "ContactCollectionView.h"

@class Meeting;
@class DetailsNewMeetingManager;

NS_ASSUME_NONNULL_BEGIN

@interface DetailsTableViewController : UITableViewController

//MARK:- IBOutlets
@property (weak, nonatomic) IBOutlet UITextField *meetingName;
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
@property (nonatomic, weak) IBOutlet UIView* contentViewCollection;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* updateMeeting;

/// Contatos selecionados.
@property (nonatomic) ContactCollectionView* contactCollectionView;

/// Reunião
@property (nonatomic) Meeting* meeting;

/// Usuários da reunião que possuem record.
@property (nonatomic) NSMutableArray<User*> *employees_user;

@property (nonatomic, nonnull) NSDateFormatter* formatter;

@property (nonatomic) DetailsNewMeetingManager* detailsManagerController;

/// Monitorando se a reunião foi modificada.
@property (nonatomic) BOOL isMeetingModified;


/// Alterando o nome da reunião.
/// @param sender botão clicado.
-(IBAction)changeMeetingName:(id)sender;

@end

NS_ASSUME_NONNULL_END
