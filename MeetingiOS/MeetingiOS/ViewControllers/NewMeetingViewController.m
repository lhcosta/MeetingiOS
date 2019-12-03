//
//  NewMeetingViewController.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 02/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "NewMeetingViewController.h"
#import "UIView+SetupBounds.h"

@interface NewMeetingViewController ()

@property (nonatomic, weak) IBOutlet UIView* firstView;
@property (nonatomic, weak) IBOutlet UIView* secondView;
@property (nonatomic, weak) IBOutlet UIView* thirdView;
@property (nonatomic, weak) IBOutlet UIView* fourthView;
@property (nonatomic, weak) IBOutlet UIView* fifthView;

@end

@implementation NewMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
   
}

- (void) setupView {
    
    [_firstView setupBounds:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner];
    [_secondView setupBounds:kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
    [_thirdView setupBounds:kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMinYCorner | kCALayerMaxXMaxYCorner];
    [_fourthView setupBounds:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner];
    [_fifthView setupBounds:kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
}


@end

