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

@property (nonatomic) NSDateFormatter* formatter;
@property (nonatomic, nullable) UIDatePicker* datePicker;

- (void) setupDatePicker;

@end

@implementation NewMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];    
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"MMM, dd yyyy  h:mm a";
    
    _dateTime.text = [_formatter stringFromDate:NSDate.now];
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


- (void)selectedColor:(NSString *)hex {
    
}

- (void)selectedContacts:(NSArray<Contact *> *)contacts {
    
}

@end

