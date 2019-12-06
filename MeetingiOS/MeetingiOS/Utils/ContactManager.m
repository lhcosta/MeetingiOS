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
@property (nonatomic) NSMutableDictionary<NSString*, NSArray<Contact*>*>* contacts;

@end

@implementation ContactManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _contacts = [[NSMutableDictionary alloc] init];
        
        NSArray<id<CNKeyDescriptor>> *keysToFetch = @[CNContactGivenNameKey, CNContactEmailAddressesKey];
        _contactsStore = [[CNContactStore alloc] init];
        _fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
    }
    return self;
}

- (void)fetchContactsWithEmail:(void (^)(NSDictionary<NSString *,NSArray<Contact *> *> * _Nullable, NSError * _Nullable))allContacts {
    
    NSError *error = [[NSError alloc] initWithDomain:@"Problem when fetching contacts" code:201 userInfo:nil];
    
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        
        if([_contactsStore enumerateContactsWithFetchRequest:_fetchRequest error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        
            if(!stop) {
                return;
            }
            
            if([contact.emailAddresses.firstObject.value length] != 0){
                
                NSMutableArray<Contact*> *contact_aux;
                Contact* newContact = [[Contact alloc] initWithContact:contact];
                NSString* key = [contact.givenName substringToIndex:1];
                                
                if([self.contacts objectForKey:key]) {
                    contact_aux = [[self.contacts valueForKey:key] mutableCopy];
                } else {
                    contact_aux = [[NSMutableArray alloc] init];
                }
                
                [contact_aux addObject:newContact];
                
                ///Sorting Contacts
                NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
                
                [contact_aux sortUsingDescriptors:@[sortDescriptor]];
                
                [self.contacts setValue:[contact_aux copy] forKey:key];
            }            
            
        }]) {
            allContacts(_contacts, Nil);
        } else {
            allContacts(Nil, error);
        }
    }
}


@end