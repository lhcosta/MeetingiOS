//
//  EventManager.h
//  MeetingiOS
//
//  Created by Bernardo Nunes on 04/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EventManager : NSObject
+ (void)saveMeeting:(NSString *)theme starting: (NSDate*) startDate ending: (NSDate*) endDate;
@end

NS_ASSUME_NONNULL_END
