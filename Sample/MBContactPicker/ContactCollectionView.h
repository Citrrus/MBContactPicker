//
//  ContactCollectionView.h
//  MBContactPicker
//
//  Created by Matt Bowman on 11/20/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactCollectionViewCellModel.h"
#import "ContactCollectionViewCell.h"
#import "ContactEntryCollectionViewCell.h"
#import "ContactCollectionViewPromptCell.h"
@class ContactCollectionView;

@interface ContactCollectionView : UICollectionView <UICollectionViewDelegateFlowLayout, UIKeyInput>

@property (nonatomic, readonly) NSArray *contactsSelected;
@property (nonatomic) NSArray *contacts;

- (void)addToSelectedContacts:(ContactCollectionViewCellModel*)model withCompletion:(void(^)())completion;
- (void)removeFromSelectedContacts:(NSInteger)index withCompletion:(void(^)())completion;
- (void)scrollToEntry;
- (BOOL)isEntryCell:(NSIndexPath*)indexPath;
- (BOOL)isPromptCell:(NSIndexPath*)indexPath;
- (BOOL)isContactCell:(NSIndexPath*)indexPath;
- (NSInteger)entryCellIndex;
- (NSInteger)selectedContactIndexFromIndexPath:(NSIndexPath*)indexPath;
- (NSInteger)selectedContactIndexFromRow:(NSInteger)row;
- (NSIndexPath*)indexPathOfSelectedCell;

@end
