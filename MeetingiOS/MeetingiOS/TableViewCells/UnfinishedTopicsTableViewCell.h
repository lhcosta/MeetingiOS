//
//  UnfinishedTopicsTableViewCell.h
//  MeetingiOS
//
//  Created by Paulo Ricardo on 12/4/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnfinishedTopicsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextField *topicTextField;
@property (strong, nonatomic) IBOutlet UIButton *checkButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonLeftSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textFieldLeft;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textFieldHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textFieldRight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textFieldSecondLeft;
@property (strong, nonatomic) IBOutlet UIButton *buttonInfo;



@end

NS_ASSUME_NONNULL_END
