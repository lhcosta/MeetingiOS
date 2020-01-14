//
//  DetailsTableViewController.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 14/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import "DetailsTableViewController.h"
#import "ContactCollectionView.h"

@interface DetailsTableViewController ()

@property (nonatomic) NSMutableArray<User*> *employees_user;
@property (nonatomic) NSMutableArray<Contact*> *employees_contact;
@property (nonatomic) ContactCollectionView* contactCollectionView;

@end

@implementation DetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = NSLocalizedString(@"dateFormat", "");
    
    self.meetingName.text = _meeting.theme;
    self.meetingAdmin.text = _meeting.managerName;
    self.numbersOfPeople.text = [NSString stringWithFormat:@"%ld", _meeting.employees.count];
    self.topicsPerPerson.text = [NSString stringWithFormat:@"%lli", _meeting.limitTopic];
    self.startsDate.text = [formatter stringFromDate:_meeting.initialDate]; 
    self.endesDate.text = [formatter stringFromDate:_meeting.finalDate];
        
    [self loadingMeetingsParticipants];
    
    _contactCollectionView = [[ContactCollectionView alloc] init];
    [_contactCollectionView addContacts:[_employees_contact copy]];
    
}

/// Carregando os contatos da reunião.
- (void) loadingMeetingsParticipants {
    
    NSMutableArray<CKRecordID*>* employeesID = [[NSMutableArray alloc]init];
    
    for (CKReference* employee in self.meeting.employees) {
        [employeesID addObject:employee.recordID];
    }
    
    [CloudManager.shared fetchRecordsWithRecordIDs:@[[employeesID copy]] desiredKeys:Nil finalCompletion:^(NSDictionary<CKRecordID *,CKRecord *> * _Nullable records, NSError * _Nullable error) {
       
        if (error == Nil) {
            
            for(CKRecord* record in records.allValues) {
                
                User* user = [[User alloc] initWithRecord:record];
                Contact* contact = [[Contact alloc]initWithUser:user];
                
                [self.employees_user addObject:user];
                [self.employees_contact addObject:contact];
            }
            
        } else {
            NSLog(@"%@", error.userInfo);
            return;
        }
    }];
}


 
@end

