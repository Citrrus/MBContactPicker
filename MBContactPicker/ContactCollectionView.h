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

@protocol ContactCollectionViewDelegate <NSObject>

@optional

- (void)didSelectContact:(ContactCollectionViewCellModel*)model inContactCollectionView:(ContactCollectionView*)collectionView;
- (void)didAddContact:(ContactCollectionViewCellModel*)model toContactCollectionView:(ContactCollectionView*)collectionView;
- (void)didRemoveContact:(ContactCollectionViewCellModel*)model fromContactCollectionView:(ContactCollectionView*)collectionView;

@end

@interface ContactCollectionView : UICollectionView <UICollectionViewDelegateFlowLayout, UIKeyInput>

@property (nonatomic) NSMutableArray *selectedContacts;
@property (nonatomic, weak) id<ContactCollectionViewDelegate> contactDelegate;

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

+ (ContactCollectionView*)contactCollectionViewWithFrame:(CGRect)frame;

@property (nonatomic) NSInteger cellHeight;
@property (nonatomic, copy) NSString *prompt;

@end
