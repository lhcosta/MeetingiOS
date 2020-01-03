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
@property (nonatomic) NSPredicate* predicate;

@end

@implementation ContactManager

+ (instancetype)shared {
    
    static ContactManager* shared = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _contacts = [[NSMutableDictionary alloc] init];
        
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
    
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        
        if(_contacts.count) {
            allContacts(_contacts, Nil);
        
        } else if([_contactsStore enumerateContactsWithFetchRequest:_fetchRequest error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            
            if(!stop) {
                return;
            }
            
            if([contact.emailAddresses.firstObject.value length] != 0 && ![contact.emailAddresses.firstObject.value isEqualToString:[NSUserDefaults.standardUserDefaults valueForKey:@"email"]]){
                        
                NSMutableArray<Contact*> *contact_aux;
                Contact* newContact = [[Contact alloc] initWithContact:contact];
                NSString* key = [contact.givenName substringToIndex:1];
                
                if([self.contacts objectForKey:key]) {
                    contact_aux = [[self.contacts valueForKey:key] mutableCopy];
                } else {
                    contact_aux = [[NSMutableArray alloc] init];
                }
                
                [contact_aux addObject:newContact];
                
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
