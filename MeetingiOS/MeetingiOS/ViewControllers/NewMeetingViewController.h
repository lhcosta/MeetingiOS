//
//  NewMeetingViewController.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 02/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+SetupBounds.h"
#import "ContactCollectionView.h"
#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN


/// View Controllers para criar uma nova reuinao
@interface NewMeetingViewController : UIViewController

//MARK:- IBOutlets
@property (nonatomic, weak) IBOutlet UIView* firstView;
@property (nonatomic, weak) IBOutlet UIView* secondView;
@property (nonatomic, weak) IBOutlet UIView* thirdView;
@property (nonatomic, weak) IBOutlet UIView* fourthView;
@property (nonatomic, weak) IBOutlet UIView* fifthView;
@property (nonatomic, weak) IBOutlet UILabel* dateTime;
@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;
@property (nonatomic, weak) IBOutlet UITextField* nameMetting;

@end

NS_ASSUME_NONNULL_END
