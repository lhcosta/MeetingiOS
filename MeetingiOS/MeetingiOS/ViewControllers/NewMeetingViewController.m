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
#import "NewMeetingViewController+PickerNumberOfTopics.h"
#import "Contact.h"

@interface NewMeetingViewController ()

@property (nonatomic, nonnull) NSDateFormatter* formatter;
@property (nonatomic, nullable) UIDatePicker* datePicker;
@property (nonatomic, nullable) ContactCollectionView* contactCollectionView;
@property (nonatomic, nonnull) Meeting* meeting;
@property (nonatomic, nonnull) CKRecord* record;
@property (nonatomic, nonnull) NSMutableArray<CKReference*>* participants;
@property (nonatomic, nonnull, copy) NSString* nameColor;
@property (nonatomic, nullable) UIPickerView* pickerView;


/// Criando e inicializando o date picker.
- (void) setupDatePicker;

///Criando a reunião no Cloud Kit.
- (void) createMeetingInCloud;

/// Criando picker para selecionar o número de tópicos por pessoa.
- (void) pickerForNumberOfTopics;

@end

@implementation NewMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];    
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"MMM, dd yyyy  h:mm a";
    _startsDateTime.text = [_formatter stringFromDate:NSDate.now];
    
    _contactCollectionView = [[ContactCollectionView alloc] init];
    _collectionView.allowsSelection = NO;
    _collectionView.delegate = _contactCollectionView;
    _collectionView.dataSource = _contactCollectionView;
    
    _record = [[CKRecord alloc] initWithRecordType:@"Meeting"];
    _meeting = [[Meeting alloc] initWithRecord:_record];
    
    _participants = [[NSMutableArray alloc] init];
    
    _nameMetting.delegate = self;
    
    [self.navigationItem setTitle:@"New meeting"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(createMeetingInCloud)];
        
    
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
    
    [_firstView setupBounds:kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMinYCorner | kCALayerMaxXMaxYCorner];
    [_secondView setupBounds:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner];
    [_thirdView setupBounds: kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
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
        
    } else if (CGRectContainsPoint(_fifthView.bounds, [touch locationInView:_fifthView])) {
        
        if([self.view.subviews containsObject:_pickerView]) {
            [_pickerView removeFromSuperview];
        } else {
            [self pickerForNumberOfTopics];
        }
    }
}


/// Modificando o label de data e hora da reuniao
/// @param datePicker objeto date picker
- (void) modifieDateTimeLabel:(UIDatePicker*)datePicker {
    _startsDateTime.text = [_formatter stringFromDate:datePicker.date];
} 

- (void)setupDatePicker {
    
    _datePicker = [[UIDatePicker alloc] init];
    
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    _datePicker.minimumDate = NSDate.now;
    
    if([_formatter dateFromString:_startsDateTime.text] != NSDate.now) {
        _datePicker.date = [_formatter dateFromString:_startsDateTime.text];
    } 
    
    _datePicker.backgroundColor = UIColor.opaqueSeparatorColor;
    
    [self.view addSubview:_datePicker];
    
    [[_datePicker.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
    [[_datePicker.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
    [[_datePicker.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
        
    [_datePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [_datePicker addTarget:self action:@selector(modifieDateTimeLabel:) forControlEvents:UIControlEventValueChanged];    
    
}

-(void) createMeetingInCloud {
    
    NSString* theme =  [_nameMetting.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    
    if(theme.length == 0) {
        return;
    }
    
    [_meeting setTheme:theme];
    [_meeting setEmployees:[_participants copy]];
    [_meeting setInitialDate:[_formatter dateFromString:_startsDateTime.text]];
    [_meeting setFinalDate:[_formatter dateFromString:_endesDateTime.text]];
    [_meeting setColor:_nameColor];
    
}

- (void)chooseColorMeeting:(id)sender{
    [self performSegueWithIdentifier:@"SelectColor" sender:Nil];
}

- (void)selectedColor:(NSString *)hex {
    
    //Pegar cor de acordo com o hex
    _nameColor = hex;
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

- (void)pickerForNumberOfTopics {
    
    _pickerView = [[UIPickerView alloc] init];
    
    [_pickerView setDataSource:self];
    [_pickerView setDelegate:self];
    [_pickerView setBackgroundColor: UIColor.opaqueSeparatorColor];
    
    [self.view addSubview:_pickerView];
    
    [[_pickerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
    [[_pickerView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
    [[_pickerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    
    [[_pickerView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.2] setActive:YES];
    
    [_pickerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
}

@end

