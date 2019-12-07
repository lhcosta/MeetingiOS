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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contacts = [[NSArray alloc] init];
    }
    
    return self;
}

//MARK:- UICollectionViewDataSource
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    
    ContactCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ContactCollectionCell" forIndexPath:indexPath];
    
    [cell setContact:_contacts[indexPath.item]];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { 
    return [self.contacts count];
}

//MARK:- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray<Contact*>* mutableContacts = [_contacts mutableCopy];
    
    [mutableContacts[indexPath.item] setIsSelected:NO];

    [mutableContacts removeObjectAtIndex:indexPath.item];
    _contacts = [mutableContacts copy];
    
    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
    
    [NSNotificationCenter.defaultCenter postNotificationName:@"RemoveContact" object:nil];
}

//MARK:- UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 30, 10, 30);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

@end

