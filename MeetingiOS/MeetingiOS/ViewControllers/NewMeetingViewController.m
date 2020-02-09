//
//  NewMeetingViewController.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 02/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "NewMeetingViewController.h"
#import <MeetingiOS-Swift.h>
#import "NewMeetingViewController+NameMeetingValidation.h"
#import "Contact.h"
#import "ContactCollectionView.h"
#import "TopicsPerPersonPickerView.h"
#import "TypeUpdateUser.h"
#import "UIViewController+StatusBarBackground.h"
#import "UIView+CornerShadows.h"

@interface NewMeetingViewController () <TopicsPerPersonPickerViewDelegate, DatePickersSetup>

//MARK:- Properties
@property (nonatomic, nullable) ContactCollectionView* contactCollectionView;
@property (nonatomic, nonnull) Meeting* meeting;
@property (nonatomic) BOOL chooseNumberOfTopics;
@property (nonatomic) BOOL chooseStartTime;
@property (nonatomic) BOOL chooseEndTime;
@property (nonatomic) TopicsPerPersonPickerView* topicsPickerView; 
@property (nonatomic, nonnull) NSDateFormatter* formatter;
@property (nonatomic) DetailsNewMeetingManager* managerController;
@property (nonatomic) NSInteger index_color;
@property (nonatomic) NSInteger numbersOfMeetings;

//MARK:- Methods
///Criando a reunião no Cloud Kit.
- (void) createMeetingInCloud;
- (void) saveMeeting;

@end

@implementation NewMeetingViewController

//MARK:- Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(_contactCollectionView)
        _contactCollectionView.isRemoveContact = NO;    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Construtores
    //Cor do Background
    [self.view setBackgroundColor:UIColor.clearColor];
    self.tableView.backgroundColor = [UIColor colorNamed:@"BackgroundColor"];
    
    _index_color = 1;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    //Iniciando nova reunião.
    CKRecord* record = [[CKRecord alloc] initWithRecordType:@"Meeting"];
    
    _formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:NSLocalizedString(@"dateFormat", "")];
    
    // 30 min a mais do horário atual stado no datePicker
    NSDateComponents *components= [[NSDateComponents alloc] init];
    [components setMinute:30];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *newDateStarts = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
    _startsDateTime.text = [_formatter stringFromDate:newDateStarts];
    
    // 10 min a mais do horário atual stado no datePicker
    [components setMinute:40];
    NSDate *newDateEnds = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
    _endesDateTime.text = [_formatter stringFromDate:newDateEnds];
    
    _startDatePicker.date = newDateStarts;
    _finishDatePicker.date = newDateEnds;
    
    
    [self setupPickersWithStartDatePicker:_startDatePicker finishDatePicker:_finishDatePicker];
    
    _meeting = [[Meeting alloc] initWithRecord:record];
    _topicsPickerView = [[TopicsPerPersonPickerView alloc] init];
    
    self.numbersOfPeople.text = NSLocalizedString(@"None", "");
    
    _nameMetting.delegate = self;
    _pickerView.delegate = _topicsPickerView;
    [_topicsPickerView setDelegate:self];
    
    _chooseNumberOfTopics = NO;
    _chooseStartTime = NO;
    _chooseEndTime = NO;
    
    _colorMetting.backgroundColor = [UIColor colorNamed: [NSString stringWithFormat:@"ColorMeeting_%i", 1]];
    
    _managerController = [[DetailsNewMeetingManager alloc] init];
    _contactCollectionView = [_managerController setupCollectionViewContacts:_collectionView];
    [_collectionView setBackgroundColor:UIColor.clearColor];
    [_contentViewCollection setupCornerRadiusShadow:kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
    [_contentViewCollection setBackgroundColor:[UIColor colorNamed:@"ContactCollectionColor"]];
    
    [self setupViews];
    
    [self.navigationItem setTitle:NSLocalizedString(@"New meeting", "")];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveMeeting)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([_contactCollectionView.contacts count] != 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
                self.numbersOfPeople.text = [NSString stringWithFormat:@"%ld", self.contactCollectionView.contacts.count];                   
                [self.collectionView reloadData];
            }];
        });
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
            self.numbersOfPeople.text = NSLocalizedString(@"None", "");
            [self.view layoutIfNeeded];
        }];
    }
}

//MARK:- UIViews
- (void) setupViews {
    
    for (UIView* view in self.views) {
        
        [view setBackgroundColor:[UIColor colorNamed:@"ColorTableViewCell"]];
        
        switch (view.tag) {
            case 1:
                [view setupCornerRadiusShadow:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner];
                break;
            case 2:
                [view setupCornerRadiusShadow:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner];
                break;
            default:
                [view setupCornerRadiusShadow];
        }
    }
}

//MARK:- Table View Config
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 1:
            switch (indexPath.row) {
                case 0:
                    _chooseStartTime = !_chooseStartTime;
                    break;
                case 2:
                    _chooseEndTime = !_chooseEndTime;
                default:
                    break;
            }
            
            break;
        case 2:
            if(indexPath.row == 0) {
                [self performSegueWithIdentifier:@"SelectContacts" sender:nil];
            }
            break;
        case 3:
            if(indexPath.row == 0) {
                _chooseNumberOfTopics = !_chooseNumberOfTopics;      
            }
            break;
        default:
            break;
    }
    
    [tableView beginUpdates];
    [tableView endUpdates];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 1:
            switch (indexPath.row) {
                case 1:
                    if(!_chooseStartTime) {
                        
                        [UIView animateWithDuration:0.5 animations:^{
                            [self.startDatePicker setHidden:YES];
                        }];
                        
                        return 0;
                    } else {
                        [self.startDatePicker setHidden:NO];
                    }
                    break;
                case 3:
                    if(!_chooseEndTime) {
                        
                        UIView* view = [_views objectAtIndex:2];
                        [view.layer setCornerRadius:5];
                        view.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMinXMaxYCorner;
                        
                        [UIView animateWithDuration:0.5 animations:^{
                            [self.finishDatePicker setHidden:YES];
                        }];
                        
                        return 0;
                    } else {                        
                        UIView* view = [_views objectAtIndex:2];
                        [view.layer setCornerRadius:0];
                        [self.finishDatePicker setHidden:NO];
                    }
                default:
                    break;
            }
            break;
        case 2:
            if(indexPath.row == 1 && _contactCollectionView.contacts.count == 0) {
                UIView* view = [self.views objectAtIndex:3];
                view.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner | kCALayerMaxXMaxYCorner | kCALayerMinXMaxYCorner;
                return 0;
                
            } else if (_contactCollectionView.contacts.count != 0) {
                UIView* view = [self.views objectAtIndex:3];
                view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    if(_chooseNumberOfTopics) {
                        UIView* view = [self.views objectAtIndex:4];
                        view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                    } else {
                        UIView* view = [self.views objectAtIndex:4];
                        view.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner | kCALayerMaxXMaxYCorner | kCALayerMinXMaxYCorner;
                    }
                    break;
                case 1:
                    if(!_chooseNumberOfTopics) {
                        return 0;
                    }
                    break;
                default:
                    break;
            }
        default:
            break;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

//MARK:- Methods
/// Atribuindo o delegate da view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SelectContacts"]) {
        
        ContactViewController* contactViewController = [segue destinationViewController];
        
        if(contactViewController) {
            [contactViewController setContactCollectionView:_contactCollectionView];
        }
        
    } else if ([segue.identifier isEqualToString:@"SelectColor"]) {
        
        UINavigationController* navigationController = [segue destinationViewController];
        SelectColorViewController* viewController = [navigationController.viewControllers firstObject];
        
        if(viewController) {
            [viewController setDelegate:self];
            [viewController setSelectedColor: _index_color];
        }
    }
}

-(bool) isLoggedIn {
    NSString* recordName = [NSUserDefaults.standardUserDefaults stringForKey:@"recordName"];
    
    if (!recordName || [recordName isEqualToString:@""]) {
        return false;
    } else {
        return true;
    }
}

-(void) saveMeeting {
    
    NSString* recordName = [NSUserDefaults.standardUserDefaults stringForKey:@"recordName"];
    
    //Usuário não cadastrado.
    if (!recordName || [recordName isEqualToString:@""]) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        UIViewController* loginVC = [storyboard instantiateInitialViewController];
        [self presentViewController:loginVC animated:true completion:nil];
        return;
    }
    
    //Methods to implement subscription here.
    
    [self createMeetingInCloud];
}

-(void) createMeetingInCloud {
    
    NSString* theme =  [_nameMetting.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    
    //Nome não definido
    if(theme.length == 0) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Meeting", "") message:NSLocalizedString(@"Choose a name for create a meeting.", "") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        
        [alert addAction:action];                    
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    UIAlertController* alertLoading = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Creating Meeting...", "") preferredStyle:UIAlertControllerStyleAlert];
    [alertLoading addUIActivityIndicatorView];
    
    [self presentViewController:alertLoading animated:true completion:nil];
    
    CKRecordID* recordID = [[CKRecordID alloc] initWithRecordName:[NSUserDefaults.standardUserDefaults valueForKey:@"recordName"]];
    CKReference* manager = [[CKReference alloc] initWithRecordID:recordID action:CKReferenceActionNone];
    
    [_meeting setManager:manager];
    [_meeting setTheme:theme];
    [_meeting setColor: [NSString stringWithFormat:@"%li", _index_color]];
    [_meeting setInitialDate:[_formatter dateFromString:_startsDateTime.text]];
    [_meeting setFinalDate:[_formatter dateFromString:_endesDateTime.text]];
    [_meeting setLimitTopic:_numbersOfTopics.text.integerValue];
    
    [self.managerController getUsersFromSelectedContactWithContacts:_contactCollectionView.contacts completionHandler:^(NSArray<User *> * _Nonnull users) {
        
        NSMutableArray<CKReference*>* references_users = [[NSMutableArray alloc] init];
        
        for(User* user in users) {
            [references_users addObject: [[CKReference alloc] initWithRecord:user.record action:CKReferenceActionNone]];
        }
        
        [self.meeting setEmployees:references_users.copy];
        
        [CloudManager.shared createRecordsWithRecords:@[self.meeting.record] perRecordCompletion:^(CKRecord * _Nonnull record, NSError * _Nullable error) {
            
            if(error) {
                NSLog(@"Create Record -> %@", [error userInfo]);
            }
            
        } finalCompletion:^{
            
            NSLog(@"Create Record");
            [self.managerController updateUsersWithUsers:users meeting:self.meeting typeUpdate:(TypeUpdateUser)insertUser];
            [EventManager saveMeeting:theme starting:self.meeting.initialDate ending:self.meeting.finalDate];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray<UIViewController *>* viewControllers = self.navigationController.viewControllers;
                NSUInteger vcCount = [self.navigationController.viewControllers count];
                MyMeetingsViewController* previousVC = (MyMeetingsViewController *)[viewControllers objectAtIndex:vcCount -2];
                previousVC.newMeeting = self->_meeting;
                
                [alertLoading dismissViewControllerAnimated:YES completion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            });
        }];
    }];
}

//MARK:- IBActions
- (void)chooseColorMeeting:(id)sender{
    [self performSegueWithIdentifier:@"SelectColor" sender:Nil];
}

//MARK:- Meeting Delegate
- (void)selectedColor:(NSInteger)index_color {
    NSString *color = [NSString stringWithFormat:@"ColorMeeting_%li", index_color];
    _colorMetting.backgroundColor = [UIColor colorNamed: color];
    _index_color = index_color;
}


//MARK:- TopicsPerPersonPickerViewDelegate 
- (void)changedNumberOfTopics:(NSInteger)amount {
    [self.numbersOfTopics setText:[NSString stringWithFormat:@"%ld", amount]];
}

//MARK:- DatePickersSetup
- (void)modifieStartDateTimeWithDatePicker:(UIDatePicker *)datePicker {
    _startsDateTime.text = _endesDateTime.text = [self.formatter stringFromDate:datePicker.date];
    _finishDatePicker.minimumDate = _finishDatePicker.date = datePicker.date;
}

- (void)modifieEndTimeWithDatePicker:(UIDatePicker *)datePicker {
    _endesDateTime.text = [self.formatter stringFromDate:datePicker.date];
}

- (void)setupPickersWithStartDatePicker:(UIDatePicker *)startDatePicker finishDatePicker:(UIDatePicker *)finishDatePicker {
    
    startDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
    finishDatePicker.datePickerMode = UIDatePickerModeTime;
    startDatePicker.minimumDate = finishDatePicker.minimumDate = NSDate.now;
    
    [startDatePicker addTarget:self action:@selector(modifieStartDateTimeWithDatePicker:) forControlEvents:UIControlEventValueChanged];
    
    [finishDatePicker addTarget:self action:@selector(modifieEndTimeWithDatePicker:) forControlEvents:UIControlEventValueChanged];
}

/// Pode criar tres reunioes gratis.
/// @param completionHandler possibilidade de criar ou nao.
-(void) userCreateMeeting:(void(^) (BOOL))completionHandler {
    
    NSString* recordName = [NSUserDefaults.standardUserDefaults valueForKey:@"recordName"];
    CKRecord* record = [[CKRecord alloc] initWithRecordType:@"User" recordID:[[CKRecordID alloc]initWithRecordName:recordName]];
    
    self.numbersOfMeetings = 0;
    
    [CloudManager.shared fetchRecordsWithRecordIDs:@[record.recordID] desiredKeys:@[@"recordName"] finalCompletion:^(NSDictionary<CKRecordID *,CKRecord *> * _Nullable records, NSError * _Nullable error) {
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"manager = %@", records.allValues.firstObject.recordID];        
        
        if(!error) {
            [CloudManager.shared readRecordsWithRecorType:@"Meeting" predicate:predicate desiredKeys:@[@"meetings"] perRecordCompletion:^(CKRecord * _Nonnull record) {
                if (record) {
                    self.numbersOfMeetings += 1;
                }
            } finalCompletion:^{
                
                if (self.numbersOfMeetings >= 3) {
                    completionHandler(NO);
                }  else {
                    completionHandler(YES);
                }
            }];
        }
    }];
    
    
} 

//MARK:- Version 1.1 -> Subscription
- (void) methodsToImplementInSubscription {
    
    [self userCreateMeeting:^(BOOL isPossible) {
        if (isPossible) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createMeetingInCloud]; 
            });
        } else {
            [StoreManager.shared receiptValidationWithCompletionHandler:^(NSDate * _Nullable date) {
                if (date > NSDate.now){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self createMeetingInCloud]; 
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performSegueWithIdentifier:@"Premium" sender:Nil];
                        return;
                    });
                }
            }];
        }        
    }];
}


@end
