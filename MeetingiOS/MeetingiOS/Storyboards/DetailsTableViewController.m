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
@property (nonatomic) User* manager;
@property (nonatomic) BOOL isManager;
@property (nonatomic) BOOL chooseNumberOfTopics;
@property (nonatomic) BOOL chooseStartTime;
@property (nonatomic) BOOL chooseEndTime;

@end

@implementation DetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = NSLocalizedString(@"dateFormat", "");
    
    [self loadingMeetingsParticipants];
    [self fetchManager];
    
    self.meetingName.text = _meeting.theme;
    self.meetingAdmin.text = _manager.name;
    self.numbersOfPeople.text = [NSString stringWithFormat:@"%ld", _meeting.employees.count];
    self.topicsPerPerson.text = [NSString stringWithFormat:@"%lli", _meeting.limitTopic];
    self.startsDate.text = [formatter stringFromDate:_meeting.initialDate]; 
    self.endesDate.text = [formatter stringFromDate:_meeting.finalDate];
    
    _contactCollectionView = [[ContactCollectionView alloc] init];
    [_contactCollectionView addContacts:[_employees_contact copy]];
    
    [self setupNavigationController];
    
    NSString* owner_email = [NSUserDefaults.standardUserDefaults valueForKey:@"email"];
            
    if(owner_email) {
        _isManager = [_manager.email isEqualToString:owner_email];
    } else {
        _isManager = false;
    }
    
    if(!_isManager) {
        [self.modifyName setHidden:YES];
        [self.tableView setAllowsSelection:NO];
    }
    
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
                Contact* contact = [[Contact alloc]initWithName:user.name andEmail:user.email];
                
                [self.employees_user addObject:user];
                [self.employees_contact addObject:contact];
            }
            
        } else {
            NSLog(@"%@", error.userInfo);
            return;
        }
    }];
}

/// Buscando o criador do reunião
- (void) fetchManager {
    
    [CloudManager.shared fetchRecordsWithRecordIDs:@[_meeting.manager.recordID] desiredKeys:Nil finalCompletion:^(NSDictionary<CKRecordID *,CKRecord *> * _Nullable records, NSError * _Nullable error) {
        
        if (error == Nil) {
            self.manager = [[User alloc] initWithRecord:records.allValues.firstObject];
        } else {
            NSLog(@"%@", error.userInfo);
            return;
        }
    }];
}

/// Adicionando as configurações da navigation controller.
- (void) setupNavigationController {
    [self.navigationController setTitle:@"Details"];
    [self.navigationController.navigationBar setPrefersLargeTitles:NO];
    [self.navigationController.navigationItem setHidesBackButton:YES];
    self.navigationController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action: @selector(popViewControllerAnimated:)];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
      
    switch (indexPath.section) {
          case 2:
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
                          
                          UIView* view = [_views objectAtIndex:3];
                          [view.layer setCornerRadius:5];
                          view.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMinXMaxYCorner;
                          
                          [UIView animateWithDuration:0.5 animations:^{
                              [self.finishDatePicker setHidden:YES];
                          }];
                          
                          return 0;
                      } else {                        
                          UIView* view = [_views objectAtIndex:3];
                          [view.layer setCornerRadius:0];
                          [self.finishDatePicker setHidden:NO];
                      }
                  default:
                      break;
              }
              break;
          case 3:
              if(indexPath.row == 1 && _contactCollectionView.contacts.count == 0) {
                  UIView* view = [self.views objectAtIndex:3];
                  view.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner | kCALayerMaxXMaxYCorner | kCALayerMinXMaxYCorner;
                  return 0;
                  
              } else if (_contactCollectionView.contacts.count != 0) {
                  UIView* view = [self.views objectAtIndex:3];
                  view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
              }
              break;
          case 4:
              switch (indexPath.row) {
                  case 0:
                      if(_chooseNumberOfTopics) {
                          UIView* view = [self.views objectAtIndex:5];
                          view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                      } else {
                          UIView* view = [self.views objectAtIndex:5];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 2:
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
        case 3:
            if(indexPath.row == 0) {
                [self performSegueWithIdentifier:@"SelectContacts" sender:nil];
            }
            break;
        case 4:
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SelectContacts"]) {
        
        ContactViewController* contactViewController = [segue destinationViewController];
        
        if(contactViewController) {
            [contactViewController setContactCollectionView:_contactCollectionView];
        }
    }
}


@end

