//
//  EventManager.m
//  MeetingiOS
//
//  Created by Bernardo Nunes on 04/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "EventManager.h"

@interface EventManager()
+ (void)insertMeeting: (EKEventStore *) store :(NSString *)theme starting: (NSDate*) startDate ending: (NSDate*) endDate;
+ (void)requireAccess: (EKEventStore *) store :(NSString *)theme starting: (NSDate*) startDate ending: (NSDate*) endDate;
@end

@implementation EventManager

/// Método público para salvar reunioes no calendario
/// @param theme Tema da reuniao
/// @param startDate data de começo
/// @param endDate data de fim
+ (void)saveMeeting:(NSString *)theme starting: (NSDate*) startDate ending: (NSDate*) endDate{
    EKEventStore *store = [[EKEventStore alloc] init];
    
    switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent]) {
        case EKAuthorizationStatusAuthorized:
            [self insertMeeting:store :theme starting:startDate ending:endDate];
            break;
        case EKAuthorizationStatusNotDetermined:
            [self requireAccess:store :theme starting:startDate ending:endDate];
            break;
        default:
            NSLog(@"Negado ou restrito");
            break;
    }
}

/// Método utilizado para pedir acesso ao calendario do usuario
/// @param store Objeto utilizado para acessar calendário do usuário
/// @param theme Tema da reuniao
/// @param startDate data de começo
/// @param endDate data de fim
+ (void)requireAccess: (EKEventStore *) store :(NSString *)theme starting: (NSDate*) startDate ending: (NSDate*) endDate {
    [store requestAccessToEntityType:EKEntityTypeEvent completion: ^(BOOL granted, NSError * _Nullable __strong error) {
        if (granted) {
            [self insertMeeting:store :theme starting:startDate ending:endDate];
        }
    }];
}

/// Método utilizado para salvar reunião
/// @param store Objeto utilizado para acessar calendário do usuário
/// @param theme Tema da reuniao
/// @param startDate data de começo
/// @param endDate data de fim
+ (void)insertMeeting: (EKEventStore *) store :(NSString *)theme starting: (NSDate*) startDate ending: (NSDate*) endDate {
        EKCalendar *calendar = [store defaultCalendarForNewEvents];
        EKEvent *meeting = [EKEvent eventWithEventStore:store];
        
        [meeting setCalendar:calendar];
        meeting.title = theme;
        meeting.startDate = startDate;
        meeting.endDate = endDate;
        
        @try {
            NSError *err;
            [store saveEvent:meeting span:EKSpanThisEvent error:&err];
            NSLog(@"%@", err);
        } @catch (NSException *exception) {
            NSLog(@"%@", exception);
        } @finally {
            NSLog(@"Finished");
        }
}

@end
