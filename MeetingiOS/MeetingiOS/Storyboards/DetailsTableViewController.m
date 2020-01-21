//
//  DetailsTableViewController.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 14/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import "DetailsTableViewController.h"
#import "ContactCollectionView.h"
#import "UIView+CornerShadows.h"
#import <MeetingiOS-Swift.h>
#import "TopicsPerPersonPickerView.h"

@class User;

@interface DetailsTableViewController () <TopicsPerPersonPickerViewDelegate, DatePickersSetup>

@property (nonatomic) NSMutableArray<User*> *employees_user;
@property (nonatomic) NSMutableArray<Contact*> *employees_contact;
@property (nonatomic) ContactCollectionView* contactCollectionView;
@property (nonatomic) User* manager;
@property (nonatomic) BOOL isManager;
@property (nonatomic) BOOL chooseNumberOfTopics;
@property (nonatomic) BOOL chooseStartTime;
@property (nonatomic) BOOL chooseEndTime;
@property (nonatomic) TopicsPerPersonPickerView* topicsPickerView;
@property (nonatomic, nonnull) NSDateFormatter* formatter;


//MARK:- Loading View
@property (nonatomic) UIVisualEffectView *blurEffectView;
@property (nonatomic) UIActivityIndicatorView* loadingIndicator;

@end

@implementation DetailsTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(_contactCollectionView) {
        _contactCollectionView.isRemoveContact = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Nao realizar o dismiss com swipe
    [self setModalInPresentation:YES];

    [self.view setBackgroundColor:[[UIColor alloc] initWithHexString:@"#FAFAFA" alpha:1]];
    
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = NSLocalizedString(@"dateFormat", "");
    
    self.meetingName.text = self.meeting.theme;
    self.numbersOfPeople.text = self.meeting.employees.count > 0 ? [NSString stringWithFormat:@"%ld", self.meeting.employees.count] : NSLocalizedString(@"None", "") ;
    self.topicsPerPerson.text = [NSString stringWithFormat:@"%lli", self.meeting.limitTopic];
    self.startsDate.text = [_formatter stringFromDate:self.meeting.initialDate]; 
    self.endesDate.text = [_formatter stringFromDate:self.meeting.finalDate];
    
    [self setupPickersWithStartDatePicker:_startDatePicker finishDatePicker:_finishDatePicker];
    
    self.contactCollectionView = [[ContactCollectionView alloc] initWithRemoveContact:NO];
    [self.collectionParticipants setDelegate:_contactCollectionView];
    [self.collectionParticipants setDataSource:_contactCollectionView];
    [self.collectionParticipants setAllowsSelection:NO];
    [_collectionParticipants registerNib:[UINib nibWithNibName:@"ContactCollectionViewCell" bundle:Nil] forCellWithReuseIdentifier:@"ContactCollectionCell"];
    [_collectionParticipants.layer setMaskedCorners:kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
    [_collectionParticipants.layer setCornerRadius:7];
    
    [self setupViews];
    [self showLoadingView];
    self.employees_user = [[NSMutableArray alloc] init];
    self.employees_contact = [[NSMutableArray alloc] init];
    
    self.topicsPickerView = [[TopicsPerPersonPickerView alloc] init];
    [self.topicsPickerView setDelegate:self];
    _pickerView.delegate = self.topicsPickerView;

    [self loadingMeetingsParticipants:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.meetingAdmin.text = self.manager.name;
            
            [self.contactCollectionView addContacts:[self.employees_contact copy]];
            [self showCollectionViewContacts];
            
            NSString* owner_email = [NSUserDefaults.standardUserDefaults valueForKey:@"email"];
                    
            if(owner_email) {
                self.isManager = [self.manager.email isEqualToString:owner_email];
            } else {
                self.isManager = false;
            }
            
            if(!self.isManager) {
                [self.modifyName setHidden:YES];
                
                for (NSIndexPath* indexPath in self.tableView.indexPathsForVisibleRows) {
                    if(indexPath.section == 3 && indexPath.row == 1) {
                        [[self.tableView cellForRowAtIndexPath:indexPath] setUserInteractionEnabled:YES];
                    } else {
                        [[self.tableView cellForRowAtIndexPath:indexPath] setUserInteractionEnabled: NO];
                    }
                }
            }
            
            [self removeLoadingView];
        });
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showCollectionViewContacts];
}

-(IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}


/// Carregando os contatos da reunião.
- (void) loadingMeetingsParticipants: (void (^) (void)) completionHandler {
    
    NSMutableArray<CKRecordID*>* participants = [[NSMutableArray alloc]init];
    
    for (CKReference* employee in self.meeting.employees) {
        [participants addObject:employee.recordID];
    }
        
    [participants addObject:_meeting.manager.recordID];
    
    [CloudManager.shared fetchRecordsWithRecordIDs:[participants copy] desiredKeys:Nil finalCompletion:^(NSDictionary<CKRecordID *,CKRecord *> * _Nullable records, NSError * _Nullable error) {
        
        if (error == Nil) {
            
            for(CKRecord* record in records.allValues) {
                
                if ([record.recordID isEqual:self.meeting.manager.recordID]) {
                    self.manager = [[User alloc] initWithRecord:record];
                } else {
                    User* user = [[User alloc] initWithRecord:record];
                    Contact* contact = [[Contact alloc]initWithUser:user];
                    [self.employees_user addObject:user];
                    [self.employees_contact addObject:contact];
                }
            }
            
        } else {
            NSLog(@"%@", error.userInfo);
            return;
        }
        
        completionHandler();
    }];
    
}

/// Adicionando características as views.
- (void) setupViews {
    
    for(UIView* view in _views) {
        
        [view setBackgroundColor:[[UIColor alloc]initWithHexString:@"#FEFEFF" alpha:1]];
        
        switch (view.tag) {
            case 2:
                [view setupCornerRadiusShadow:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner];
                break;
            case 3:
                [view setupCornerRadiusShadow: kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
                break;
            default:
                [view setupCornerRadiusShadow];
        }
    }
}

/// Apresentar view de loading.
- (void) showLoadingView {
    
     UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]; 
    _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    
    [_loadingIndicator setHidesWhenStopped:YES];
    [_loadingIndicator startAnimating];
    
    [_blurEffectView setFrame: self.view.bounds];
    [_blurEffectView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];  
    [_blurEffectView.contentView addSubview:_loadingIndicator];
    
    [[_loadingIndicator.centerXAnchor constraintEqualToAnchor:_blurEffectView.centerXAnchor] setActive:YES];
    [[_loadingIndicator.centerYAnchor constraintEqualToAnchor:_blurEffectView.centerYAnchor] setActive:YES];
    [_loadingIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:_blurEffectView];
}


/// Remover view de loading.
- (void) removeLoadingView {
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.loadingIndicator setAlpha:0];
        [self.blurEffectView setAlpha:0];
    } completion:^(BOOL finished) {
        [self.blurEffectView removeFromSuperview];
    }];
    
    
}

//MARK:- TableView
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        return @"Created by";
    }
    
    return Nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SelectContacts"]) {
        
        ContactViewController* contactViewController = [segue destinationViewController];
        
        if(contactViewController) {
            [contactViewController setContactCollectionView:_contactCollectionView];
        }
    }
}

/// Animação para apresentar a collection view de contatos.
- (void) showCollectionViewContacts {
        
    if([_contactCollectionView.contacts count] != 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.numbersOfPeople.text = [NSString stringWithFormat:@"%ld", self.contactCollectionView.contacts.count];                   
                [self.collectionParticipants reloadData];
            }];
        });
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.numbersOfPeople.text = NSLocalizedString(@"None", "");
            [self.view layoutIfNeeded];
        }];
    }
    
    [self.tableView beginUpdates];    
    [self.tableView endUpdates];
}

//MARK:- TopicsPerPersonPickerViewDelegate 
- (void)changedNumberOfTopics:(NSInteger)amount {
    [self.topicsPerPerson setText:[NSString stringWithFormat:@"%ld", amount]];
}

//MARK:- DatePickersSetup
- (void)modifieStartDateTimeWithDatePicker:(UIDatePicker *)datePicker {
    _startsDate.text = _endesDate.text = [self.formatter stringFromDate:datePicker.date];
    _finishDatePicker.date = _finishDatePicker.minimumDate = datePicker.date;
}

- (void)modifieEndTimeWithDatePicker:(UIDatePicker *)datePicker {
    _endesDate.text = [self.formatter stringFromDate:datePicker.date];
}

- (void)setupPickersWithStartDatePicker:(UIDatePicker *)startDatePicker finishDatePicker:(UIDatePicker *)finishDatePicker {
    
    startDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
    finishDatePicker.datePickerMode = UIDatePickerModeTime;
    startDatePicker.minimumDate = NSDate.now;
    finishDatePicker.minimumDate = startDatePicker.date;

    startDatePicker.date = [self.formatter dateFromString:self.startsDate.text];
    finishDatePicker.date = [self.formatter dateFromString:self.endesDate.text];
    
    [startDatePicker addTarget:self action:@selector(modifieStartDateTimeWithDatePicker:) forControlEvents:UIControlEventValueChanged];
    [finishDatePicker addTarget:self action:@selector(modifieEndTimeWithDatePicker:) forControlEvents:UIControlEventValueChanged];
}


@end

