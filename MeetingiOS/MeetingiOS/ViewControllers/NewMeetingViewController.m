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

@interface NewMeetingViewController ()

@property (nonatomic, nonnull) NSDateFormatter* formatter;
@property (nonatomic, nullable) UIDatePicker* datePicker;
@property (nonatomic, nullable) ContactCollectionView* contactCollectionView;
@property (nonatomic, nonnull) Meeting* meeting;
@property (nonatomic, nonnull) CKRecord* record;
@property (nonatomic, nonnull) NSMutableArray<CKReference*>* participants;

- (void) setupDatePicker;
- (void) createMeetingInCloud;

@end

@implementation NewMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];    
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"MMM, dd yyyy  h:mm a";
    _dateTime.text = [_formatter stringFromDate:NSDate.now];
    
    _contactCollectionView = [[ContactCollectionView alloc] init];
    _collectionView.allowsSelection = NO;
    _collectionView.delegate = _contactCollectionView;
    _collectionView.dataSource = _contactCollectionView;
    
    _record = [[CKRecord alloc] initWithRecordType:@"Meeting"];
    _meeting = [[Meeting alloc] initWithRecord:_record];
    
    _participants = [[NSMutableArray alloc] init];
    
    _nameMetting.delegate = self;
        
}

/// Atribuindo o delegate da view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        
    if ([segue.identifier isEqualToString:@"SelectContacts"]) {
                
        ContactViewController* nextViewController = [segue destinationViewController];
        
        if(nextViewController) {
            [nextViewController setContactDelegate:self];
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
    
    [_firstView setupBounds:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner];
    [_secondView setupBounds:kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
    [_thirdView setupBounds:kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMinYCorner | kCALayerMaxXMaxYCorner];
    [_fourthView setupBounds:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner];
    [_fifthView setupBounds:kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch* touch = [touches anyObject];
    
    if(CGRectContainsPoint(_thirdView.bounds, [touch locationInView:_thirdView])) {
        
        if([self.view.subviews containsObject:_datePicker]) {
            [_datePicker removeFromSuperview];
        } else {
            [self setupDatePicker];   
        }
        
    } else if (CGRectContainsPoint(_fourthView.bounds, [touch locationInView:_fourthView])) { 
        [self performSegueWithIdentifier:@"SelectContacts" sender:nil];
    }
}


/// Modificando o label de data e hora da reuniao
/// @param datePicker objeto date picker
- (void) modifieDateTimeLabel:(UIDatePicker*)datePicker {
    _dateTime.text = [_formatter stringFromDate:datePicker.date];
} 

/// Criando e inicializando o date picker
- (void)setupDatePicker {
    
    _datePicker = [[UIDatePicker alloc] init];
    
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    _datePicker.minimumDate = NSDate.now;
    
    if([_formatter dateFromString:_dateTime.text] != NSDate.now) {
        _datePicker.date = [_formatter dateFromString:_dateTime.text];
    } 
    
    _datePicker.backgroundColor = UIColor.opaqueSeparatorColor;
    
    [self.view addSubview:_datePicker];
    
    [[_datePicker.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
    [[_datePicker.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
    [[_datePicker.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
        
    [_datePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [_datePicker addTarget:self action:@selector(modifieDateTimeLabel:) forControlEvents:UIControlEventValueChanged];    
    
}

///Criando a reunião no Cloud Kit.
-(void) createMeetingInCloud {
    
    NSString* name =  [_nameMetting.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    
    if(name.length == 0) {
        return;
    }
    
}

- (void)chooseColorMeeting:(id)sender {
    [self performSegueWithIdentifier:@"SelectColor" sender:Nil];
}

- (void)selectedColor:(NSString *)hex {
    _colorMetting.backgroundColor = [UIColor colorNamed:hex];
}

- (void)selectedContacts:(NSArray<Contact *> *)contacts {
    
    NSMutableArray<NSString*>* allEmails = [[NSMutableArray alloc] init];
    NSPredicate* predicate;
    
    for (Contact* contact in contacts) {
        [allEmails addObject:contact.email];
    }
    
    predicate = [NSPredicate predicateWithFormat:@"@email IN %@", allEmails];

    [CloudManager.shared readRecordsWithRecorType:@"User" predicate:predicate desiredKeys:@[@"recordName"] perRecordCompletion:^(CKRecord * _Nonnull record) {
        
        CKReference* reference = [[CKReference alloc]initWithRecord:record action:CKReferenceActionNone];
        
        [self.participants addObject:reference];
        
    } finalCompletion:^{
        
        [self.contactCollectionView setContacts:contacts];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self.collectionView setHidden:NO];
        });
    }];
}

@end

