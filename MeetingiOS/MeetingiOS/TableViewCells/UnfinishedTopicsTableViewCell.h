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


@end

NS_ASSUME_NONNULL_END
