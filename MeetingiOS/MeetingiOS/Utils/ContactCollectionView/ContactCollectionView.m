//
//  ContactCollectionView.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 03/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "ContactCollectionView.h"
#import "NewMeetingViewController.h"

@implementation ContactCollectionView 

- (instancetype)initWithRemoveContact:(BOOL)isRemoveContact {
    
    self = [super init];
    if (self) {
        _contacts = [[NSArray alloc] init];
        _isRemoveContact = isRemoveContact;
    }
    
    return self;
}

- (void)addContact:(Contact *)contact {
    
    NSMutableArray<Contact*>* contacts = [_contacts mutableCopy];
    
    [contacts addObject:contact];
    
    _contacts = [contacts copy];
}

- (void) addContacts : (NSArray<Contact*>*) contacts {
    _contacts = [contacts copy];
}

- (void)removeContactIndex:(NSInteger)index{
    
    NSMutableArray<Contact*>* contacts = [_contacts mutableCopy];
    
    [contacts removeObjectAtIndex:index];
    
    _contacts = [contacts copy];
}



//MARK:- UICollectionViewDataSource
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath { 

    ContactCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ContactCollectionCell" forIndexPath:indexPath];
    
    [cell setContact:_contacts[indexPath.item]];
    cell.contactImage.image = _isRemoveContact ? [UIImage systemImageNamed:@"person.crop.circle.fill.badge.xmark"] :  [UIImage systemImageNamed:@"person.crop.circle.fill"];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { 
    return [self.contacts count];
}

//MARK:- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray<Contact*>* mutableContacts = [_contacts mutableCopy];

    Contact* contact = [mutableContacts objectAtIndex:indexPath.item];
    contact.isSelected = NO;
    
    [mutableContacts removeObjectAtIndex:indexPath.item];
    _contacts = [mutableContacts copy];
    
    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
        
    [NSNotificationCenter.defaultCenter postNotificationName:@"RemoveContact" object: contact];
    
}

//MARK:- UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 20, 0, 20);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(60, collectionView.frame.size.height);    
}

@end

