//
//  TopicsPerPersonPickerView.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 20/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Delegate para mudança de número de tópicos.
@protocol TopicsPerPersonPickerViewDelegate <NSObject>

/// Número de tópicos alterado.
- (void) changedNumberOfTopics:(NSInteger) amount;

@end

@interface TopicsPerPersonPickerView : NSObject<UIPickerViewDelegate>

@property (nonatomic, weak) id <TopicsPerPersonPickerViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
