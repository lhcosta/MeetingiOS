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
#import "UIView+CornerShadows.h"
#import "TopicsPerPersonPickerView.h"

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

//MARK:- Methods
///Criando a reunião no Cloud Kit.
- (void) createMeetingInCloud;

@end

@implementation NewMeetingViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(_contactCollectionView)
        _contactCollectionView.isRemoveContact = NO;
    
    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Construtores
    //Cor do Background
    [self.view setBackgroundColor:[[UIColor alloc] initWithHexString:@"#FAFAFA" alpha:1]];
    
    //Iniciando nova reunião.
    CKRecord* record = [[CKRecord alloc] initWithRecordType:@"Meeting"];
    
    _formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:NSLocalizedString(@"dateFormat", "")];
    _startsDateTime.text = _endesDateTime.text = [_formatter stringFromDate:NSDate.now];
    [self setupPickersWithStartDatePicker:_startDatePicker finishDatePicker:_finishDatePicker];
    
    _meeting = [[Meeting alloc] initWithRecord:record];
    _topicsPickerView = [[TopicsPerPersonPickerView alloc] init];
    _colorMetting.backgroundColor = [[UIColor alloc] initWithHexString:@"#93CCB2" alpha:1];
    
    self.numbersOfPeople.text = NSLocalizedString(@"None", "");
    
    _nameMetting.delegate = self;
    _pickerView.delegate = _topicsPickerView;
    [_topicsPickerView setDelegate:self];
    
    _chooseNumberOfTopics = NO;
    _chooseStartTime = NO;
    _chooseEndTime = NO;
    
    _managerController = [[DetailsNewMeetingManager alloc] init];
    _contactCollectionView = [_managerController setupCollectionViewContacts:_collectionView];
    
    [self setupViews];
    
    NSString* title = NSLocalizedString(@"New meeting", "");
    
    [self.navigationItem setTitle:title];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(createMeetingInCloud)];
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
        
        [view setBackgroundColor:[[UIColor alloc]initWithHexString:@"#FEFEFF" alpha:1]];
        
        switch (view.tag) {
            case 1:
                [view setupCornerRadiusShadow:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner]; 
                break;
            case 2:
                [view setupCornerRadiusShadow:kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
                break;
            default:
                [view setupCornerRadiusShadow];
        }
    }
}

//MARK:- TableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 15;
    }
    
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* view = [[UIView alloc] init];
    [view setBackgroundColor:UIColor.clearColor];
    return view;
}


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


/// Atribuindo o delegate da view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SelectContacts"]) {
        
        ContactViewController* contactViewController = [segue destinationViewController];
        
        if(contactViewController) {
            [contactViewController setContactCollectionView:_contactCollectionView];
        }
        
    } else if ([segue.identifier isEqualToString:@"SelectColor"]) {
        
        SelectColorViewController* nextViewController = [segue destinationViewController];
        
        if(nextViewController) {
            [nextViewController setDelegate:self];
            [nextViewController setSelectedColor: self.colorMetting.backgroundColor.toHexString];
        }
    }
}

//private func isLoggedIn() -> Bool{
//    if let _ = defaults.value(forKey: "recordName") as? String {
//        return true
//    } else {
//       return false
//    }
//}

-(bool) isLoggedIn {
    NSString* recordName = [NSUserDefaults.standardUserDefaults stringForKey:@"recordName"];
    
    if (!recordName || [recordName isEqualToString:@""]) {
        return false;
    } else {
        return true;
    }
}

-(void) createMeetingInCloud {
    
    NSString* recordName = [NSUserDefaults.standardUserDefaults stringForKey:@"recordName"];
    
    if (!recordName || [recordName isEqualToString:@""]) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        UIViewController* loginVC = [storyboard instantiateInitialViewController];
        [self presentViewController:loginVC animated:true completion:nil];
        return;
    }
    
    NSString* theme =  [_nameMetting.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    UIAlertController* alertLoading = [_managerController createAlertLoadingIndicatorWithMessage:NSLocalizedString(@"Creating Meeting", "")];
    
    if(theme.length == 0) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Meeting", "") message:NSLocalizedString(@"Choose a name for create a meeting.", "") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        
        [alert addAction:action];                    
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];    
    [self presentViewController:alertLoading animated:true completion:nil];
    
    CKRecordID* recordID = [[CKRecordID alloc] initWithRecordName:[NSUserDefaults.standardUserDefaults valueForKey:@"recordName"]];
    CKReference* manager = [[CKReference alloc] initWithRecordID:recordID action:CKReferenceActionNone];
    
    [_meeting setManager:manager];
    [_meeting setTheme:theme];
    [_meeting setColor: _colorMetting.backgroundColor.toHexString];
    [_meeting setInitialDate:[_formatter dateFromString:_startsDateTime.text]];
    [_meeting setFinalDate:[_formatter dateFromString:_endesDateTime.text]];
    [_meeting setLimitTopic:_numbersOfTopics.text.integerValue];
    
    [self.managerController getUsersFromSelectedContactWithContacts:self.contactCollectionView.contacts completionHandler:^(NSArray<User *> * _Nonnull users) {
        
        NSMutableArray<CKReference*>* references_users = [[NSMutableArray alloc] init];
        
        for(User* user in users) {
            [user registerMeetingWithMeeting:[[CKReference alloc] initWithRecord:self.meeting.record action:CKReferenceActionNone]];
            [references_users addObject: [[CKReference alloc] initWithRecord:user.record action:CKReferenceActionNone]];
        }
        
        [self.meeting setEmployees:references_users.copy];
        
        [CloudManager.shared createRecordsWithRecords:@[self.meeting.record] perRecordCompletion:^(CKRecord * _Nonnull record, NSError * _Nullable error) {
            
            if(error) {
                NSLog(@"Create -> %@", [error userInfo]);
            }
            
        } finalCompletion:^{
            
            NSLog(@"Create Record");
            
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

- (void)chooseColorMeeting:(id)sender{
    [self performSegueWithIdentifier:@"SelectColor" sender:Nil];
}

- (void)selectedColor:(NSString *)hex {
    //Pegar cor de acordo com o hex    
    _colorMetting.backgroundColor = [[UIColor alloc] initWithHexString:hex alpha:1];
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

@end
