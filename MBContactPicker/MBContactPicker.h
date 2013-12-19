//
//  MBContactPicker.h
//  MBContactPicker
//
//  Created by Matt Bowman on 12/2/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBContactModel.h"
#import "MBContactCollectionView.h"
#import "MBContactCollectionViewContactCell.h"
#import "MBContactCollectionViewPromptCell.h"
#import "MBContactEntryCollectionViewCell.h"

@protocol MBContactPickerDataSource <NSObject>

@required

@optional

- (NSArray *)contactModelsForCollectionView:(MBContactCollectionView*)collectionView;

@end

@protocol MBContactPickerDelegate <MBContactCollectionViewDelegate>

@optional

- (void)showFilteredContacts;
- (void)hideFilteredContacts;
- (void)updateViewHeightTo:(CGFloat)newHeight;

@end

@interface MBContactPicker : UIView <UITableViewDataSource, UITableViewDelegate, MBContactCollectionViewDelegate>

@property (nonatomic, weak) id<MBContactPickerDelegate> delegate;
@property (nonatomic, weak) id<MBContactPickerDataSource> datasource;
@property (nonatomic, readonly) NSArray *contactsSelected;
@property (nonatomic) NSInteger cellHeight;
@property (nonatomic, copy) NSString *prompt;
@property (nonatomic) CGFloat maxVisibleRows;
@property (nonatomic, readonly) CGFloat currentContentHeight;
@property (nonatomic, readonly) CGFloat keyboardHeight;
@property (nonatomic) CGFloat animationSpeed;

@property (nonatomic, weak) id<UITableViewDelegate> searchTableDelegate;
@property (nonatomic, weak) id<UITableViewDataSource> searchTableDataSource;

- (void)addPreselectedContact:(id<MBContactPickerModelProtocol>)model;
- (void)reloadData;

@end
