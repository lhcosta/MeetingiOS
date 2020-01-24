//
//  ContactManager.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 04/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "ContactManager.h"

@interface ContactManager ()

@property (nonatomic) CNContactStore* contactsStore;
@property (nonatomic) CNContactFetchRequest* fetchRequest;
@property (nonatomic) NSPredicate* predicate;

@end

@implementation ContactManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSArray<id<CNKeyDescriptor>> *keysToFetch = @[CNContactGivenNameKey, CNContactEmailAddressesKey];
        _contactsStore = [[CNContactStore alloc] init];
        _fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
        
        [_fetchRequest setUnifyResults:YES];
        [_fetchRequest setSortOrder:CNContactSortOrderGivenName];
    }
    
    return self;
}

- (void)fetchContactsWithEmail:(void (^)(NSDictionary<NSString *,NSArray<Contact *> *> * _Nullable, NSError * _Nullable))allContacts {
    
    NSError *error = [[NSError alloc] initWithDomain:@"Problem when fetching contacts" code:201 userInfo:nil];
    NSMutableDictionary<NSString*, NSArray<Contact*>*>* contacts = [[NSMutableDictionary alloc] init];
    
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        
        if([_contactsStore enumerateContactsWithFetchRequest:_fetchRequest error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
         
            if([contact.givenName length] > 0 && [contact.emailAddresses.firstObject.value length] != 0 && ![contact.emailAddresses.firstObject.value isEqualToString:[NSUserDefaults.standardUserDefaults valueForKey:@"email"]]){
                
                NSMutableArray<Contact*> *contact_aux;
                Contact* newContact = [[Contact alloc] initWithContact:contact];
                NSString* key = [contact.givenName substringToIndex:1].uppercaseString;
                
                if ([key integerValue])
                    key = @"#";
                
                if([contacts objectForKey:key]) {
                    contact_aux = [[contacts valueForKey:key] mutableCopy];
                } else {
                    contact_aux = [[NSMutableArray alloc] init];
                }
                
                [contact_aux addObject:newContact];
                
                [contacts setValue:[contact_aux copy] forKey:key];                
            }            
            
        }]) {
            allContacts(contacts, Nil);            
        } else {
            allContacts(Nil, error);
        }
    }
}

@end
