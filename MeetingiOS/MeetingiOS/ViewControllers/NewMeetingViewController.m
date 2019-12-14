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
#import "NewMeetingViewController+SettingPickers.h"

#define TITLE_NAV @"New meeting"

@interface NewMeetingViewController ()

//MARK:- Properties
@property (nonatomic, nullable) ContactCollectionView* contactCollectionView;
@property (nonatomic, nonnull) Meeting* meeting;
@property (nonatomic, nonnull) NSArray<CKRecord*>* participants;
@property (nonatomic) BOOL chooseNumberOfTopics;
@property (nonatomic) BOOL chooseStartTime;
@property (nonatomic) BOOL chooseEndTime;

//MARK:- Methods
///Criando a reunião no Cloud Kit.
- (void) createMeetingInCloud;

@end

@implementation NewMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"MMM, dd yyyy  h:mm a";
    _startsDateTime.text = _endesDateTime.text = [_formatter stringFromDate:NSDate.now];

    _contactCollectionView = [[ContactCollectionView alloc] init];
    _collectionView.allowsSelection = NO;
    _collectionView.delegate = _contactCollectionView;
    _collectionView.dataSource = _contactCollectionView;
    
    CKRecord* record = [[CKRecord alloc] initWithRecordType:@"Meeting"];
    _meeting = [[Meeting alloc] initWithRecord:record];
    
    _participants = [[NSMutableArray alloc] init];
    
    _nameMetting.delegate = self;
    _pickerView.delegate = self;
    
    _colorMetting.backgroundColor = [[UIColor alloc] initWithHexString:@"#88A896" alpha:1];
    _chooseNumberOfTopics = NO;
    _chooseStartTime = NO;
    _chooseEndTime = NO;
    
    [self setupDatePicker];
    
    [self.navigationItem setTitle:TITLE_NAV];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(createMeetingInCloud)];
    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([_contactCollectionView.contacts count] != 0) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [UIView animateWithDuration:0.5 animations:^{
                 [self.tableView beginUpdates];
                 [self.tableView endUpdates];
                 [self.collectionView reloadData];
             }];
         });
     } else {
         [UIView animateWithDuration:0.5 animations:^{
             [self.tableView beginUpdates];
             [self.tableView endUpdates];
             [self.view layoutIfNeeded];
         }];
     }

}

- (void)dealloc
{
    //Deselecionando todos os contatos que foram selecionados, pois está sendo usado
    //uma classe singleton para realizar o fetch dos contatos. 
    for (Contact* contact in _contactCollectionView.contacts) {
        contact.isSelected = false;
    }
}


//MARK:- TableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
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
                        
                        [UIView animateWithDuration:0.5 animations:^{
                            [self.finishDatePicker setHidden:YES];
                        }];
                        
                        return 0;
                    } else {
                        [self.finishDatePicker setHidden:NO];
                    }
                default:
                    break;
            }
            break;
        case 2:
            if(indexPath.row == 1 && _contactCollectionView.contacts.count == 0) {
                return 0;
            }
            break;
        case 3:
            if(indexPath.row == 1 && !_chooseNumberOfTopics) {
                return 0;
            }
            break;
        default:
            break;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


/// Atribuindo o delegate da view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        
    if ([segue.identifier isEqualToString:@"SelectContacts"]) {
                
        ContactTableViewController* contactViewController = [segue destinationViewController];
        
        if(contactViewController) {
            [contactViewController setContactDelegate:self];
            [contactViewController setContactCollectionView:_contactCollectionView];
        }
        
    } else if ([segue.identifier isEqualToString:@"SelectColor"]) {
        
        SelectColorViewController* nextViewController = [segue destinationViewController];
        
        if(nextViewController) {
            [nextViewController setDelegate:self];
        }
    }
}

-(void) createMeetingInCloud {
    
    NSString* theme =  [_nameMetting.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    
    if(theme.length == 0) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Meeting" message:@"Choose a name for create a meeting." preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        
        [alert addAction:action];                    
    
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    CKRecordID* recordID = [[CKRecordID alloc] initWithRecordName:[NSUserDefaults.standardUserDefaults valueForKey:@"recordName"]];
    CKReference* manager = [[CKReference alloc] initWithRecordID:recordID action:CKReferenceActionNone];
        
    [_meeting setManager:manager];
    [_meeting setTheme:theme];
    [_meeting setColor: _colorMetting.backgroundColor.toHexString];
    [_meeting setInitialDate:[_formatter dateFromString:_startsDateTime.text]];
    [_meeting setFinalDate:[_formatter dateFromString:_endesDateTime.text]];
    [_meeting setLimitTopic:_numbersOfTopics.text.integerValue];
    
    for(CKRecord* record in _participants) {
        
        User* user = [[User alloc] initWithRecord:record];
        [user registerMeetingWithMeeting:[[CKReference alloc] initWithRecord:_meeting.record action:CKReferenceActionNone]];
        [_meeting addingNewEmployee:[[CKReference alloc]initWithRecord:record action:CKReferenceActionNone]];
    }
    
    [CloudManager.shared createRecordsWithRecords:@[_meeting.record] perRecordCompletion:^(CKRecord * _Nonnull record, NSError * _Nullable error) {
        if(error) {
            NSLog(@"Create -> %@", [error userInfo]);
        }
    } finalCompletion:^{
        NSLog(@"Create Record");
        
        [CloudManager.shared updateRecordsWithRecords:self.participants perRecordCompletion:^(CKRecord * _Nonnull record, NSError * _Nullable error) {
            if(error) {
                NSLog(@"Update -> %@", [error userInfo]);
            }
        } finalCompletion:^{
            NSLog(@"Update Users");
            
           
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray<UIViewController *>* viewControllers = self.navigationController.viewControllers;
                NSUInteger vcCount = [self.navigationController.viewControllers count];
                MyMeetingsViewController* previousVC = (MyMeetingsViewController *)[viewControllers objectAtIndex:vcCount -2];
                previousVC.newMeeting = self->_meeting;
                [self.navigationController popViewControllerAnimated:YES];
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

- (void)getRecordForSelectedUsers {
    
    NSMutableArray<NSString*>* allEmails = [[NSMutableArray alloc] init];
    NSMutableArray<CKRecord*>* participants_aux = [[NSMutableArray alloc] init];
    NSPredicate* predicate;
    
    for (Contact* contact in [_contactCollectionView contacts]) {
        [allEmails addObject:contact.email];
    }
        
    predicate = [NSPredicate predicateWithFormat:@"email IN %@", allEmails];

    [CloudManager.shared readRecordsWithRecorType:@"User" predicate:predicate desiredKeys:@[@"recordName"] perRecordCompletion:^(CKRecord * _Nonnull record) {
                    
        [participants_aux addObject:record];
        
    } finalCompletion:^{
        self.participants = [participants_aux copy];
    }];
}

@end

