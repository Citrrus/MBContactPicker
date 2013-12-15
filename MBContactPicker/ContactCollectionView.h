//
//  ContactCollectionView.h
//  MBContactPicker
//
//  Created by Matt Bowman on 11/20/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactCollectionViewCell.h"
#import "ContactEntryCollectionViewCell.h"
#import "ContactCollectionViewPromptCell.h"
#import "UICollectionViewContactFlowLayout.h"
@class ContactCollectionView;

@protocol ContactCollectionViewDelegate <NSObject>

@optional

- (void)collectionView:(UICollectionView*)collectionView willChangeContentSizeFrom:(CGSize)currentSize to:(CGSize)newSize;
- (void)entryTextDidChange:(NSString*)text inContactCollectionView:(ContactCollectionView*)collectionView;
- (void)didSelectContact:(id<MBContactPickerModelProtocol>)model inContactCollectionView:(ContactCollectionView*)collectionView;
- (void)didAddContact:(id<MBContactPickerModelProtocol>)model toContactCollectionView:(ContactCollectionView*)collectionView;
- (void)didRemoveContact:(id<MBContactPickerModelProtocol>)model fromContactCollectionView:(ContactCollectionView*)collectionView;

@end

@interface ContactCollectionView : UICollectionView <UICollectionViewDelegateContactFlowLayout, UIKeyInput>

@property (nonatomic) NSMutableArray *selectedContacts;
@property (nonatomic, weak) id<ContactCollectionViewDelegate> contactDelegate;
@property (nonatomic, weak) id<UICollectionViewDelegateContactFlowLayout> delegate;

- (void)addToSelectedContacts:(id<MBContactPickerModelProtocol>)model withCompletion:(void(^)())completion;
- (void)removeFromSelectedContacts:(NSInteger)index withCompletion:(void(^)())completion;
- (void)focusOnEntry;
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
