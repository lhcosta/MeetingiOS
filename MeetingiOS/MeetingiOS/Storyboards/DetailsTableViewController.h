//
//  DetailsTableViewController.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 14/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
#import <MeetingiOS-Swift.h>
#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailsTableViewController : UITableViewController

//MARK:- IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *meetingName;
@property (weak, nonatomic) IBOutlet UILabel *meetingAdmin;
@property (weak, nonatomic) IBOutlet UILabel *startsDate;
@property (weak, nonatomic) IBOutlet UILabel *endesDate;
@property (weak, nonatomic) IBOutlet UILabel *numbersOfPeople;
@property (weak, nonatomic) IBOutlet UILabel *topicsPerPerson;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionParticipants;

/// Reunião
@property (nonatomic) Meeting* meeting;

@end

NS_ASSUME_NONNULL_END
