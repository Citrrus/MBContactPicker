//
//  ContactCollectionView.h
//  MBContactPicker
//
//  Created by Matt Bowman on 11/20/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBContactCollectionViewContactCell.h"
#import "MBContactEntryCollectionViewCell.h"
#import "MBContactCollectionViewPromptCell.h"
#import "MBContactCollectionViewFlowLayout.h"

@class MBContactCollectionView;

@protocol MBContactCollectionViewDelegate <NSObject>

@optional

- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView willChangeContentSizeFrom:(CGSize)currentSize to:(CGSize)newSize;
- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView entryTextDidChange:(NSString*)text;
- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView didSelectContact:(id<MBContactPickerModelProtocol>)model;
- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView didAddContact:(id<MBContactPickerModelProtocol>)model;
- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView didRemoveContact:(id<MBContactPickerModelProtocol>)model;

@end

@interface MBContactCollectionView : UICollectionView

@property (nonatomic) NSMutableArray *selectedContacts;
@property (nonatomic, weak) id<MBContactCollectionViewDelegate> contactDelegate;

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

+ (MBContactCollectionView*)contactCollectionViewWithFrame:(CGRect)frame;

@property (nonatomic) NSInteger cellHeight;
@property (nonatomic, copy) NSString *prompt;

@end
