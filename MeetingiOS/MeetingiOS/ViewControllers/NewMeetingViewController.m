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

//MARK:- Methods
///Criando a reunião no Cloud Kit.
- (void) createMeetingInCloud;

@end

@implementation NewMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];    

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
    
    _colorMetting.backgroundColor = [[UIColor alloc] initWithHexString:@"#88A896" alpha:1];
    
    [self.navigationItem setTitle:TITLE_NAV];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(createMeetingInCloud)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([_contactCollectionView.contacts count] != 0) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [UIView animateWithDuration:0.5 animations:^{
                 [self.collectionView setHidden:NO];
                 [self.collectionView reloadData];
                 [self.view layoutIfNeeded];
             }];
         });
     } else {
         [UIView animateWithDuration:0.5 animations:^{
             [self.collectionView setHidden:YES];
             [self.view layoutIfNeeded];
         }];
     }

}

/// Atribuindo o delegate da view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        
    if ([segue.identifier isEqualToString:@"SelectContacts"]) {
                
        ContactViewController* contactViewController = [segue destinationViewController];
        
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

/// Modificando todas as views presentes na view controller
- (void) setupView {
    
    [_firstView setupBounds:kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMinYCorner | kCALayerMaxXMaxYCorner];
    [_secondView setupBounds:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner];
    [_thirdView setupBounds: kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
    [_fourthView setupBounds:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner];
    [_fifthView setupBounds:kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch* touch = [touches anyObject];
    
    if(CGRectContainsPoint(_secondView.bounds, [touch locationInView:_secondView])) {
        
        if([self.view.subviews containsObject:_datePicker]) {
            [_datePicker removeFromSuperview];
        } else {
            [self setupDatePicker:Start];   
        }
        
    } else if(CGRectContainsPoint(_thirdView.bounds, [touch locationInView:_thirdView])) {
        
        if([self.view.subviews containsObject:_datePicker]) {
            [_datePicker removeFromSuperview];
        } else {
            [self setupDatePicker:Finish];   
        }
        
    } else if (CGRectContainsPoint(_fourthView.bounds, [touch locationInView:_fourthView])) { 
        [self performSegueWithIdentifier:@"SelectContacts" sender:nil];
        
    } else if (CGRectContainsPoint(_fifthView.bounds, [touch locationInView:_fifthView])) {
        
        if([self.view.subviews containsObject:_pickerView]) {
            [_pickerView removeFromSuperview];
        } else {
            [self pickerForNumberOfTopics];
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
    
    [_meeting setTheme:theme];
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

- (void)selectedContacts:(NSArray<Contact *> *)contacts {
    
    NSMutableArray<NSString*>* allEmails = [[NSMutableArray alloc] init];
    NSMutableArray<CKRecord*>* participants_aux = [[NSMutableArray alloc] init];
    NSPredicate* predicate;
    
    for (Contact* contact in contacts) {
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

