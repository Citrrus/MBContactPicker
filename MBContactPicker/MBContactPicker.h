//
//  MBContactPicker.h
//  MBContactPicker
//
//  Created by Matt Bowman on 12/2/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactCollectionView.h"
#import "ContactCollectionViewCell.h"
#import "ContactCollectionViewCellModel.h"
#import "ContactCollectionViewPromptCell.h"
#import "ContactEntryCollectionViewCell.h"

@protocol MBContactPickerDataSource <NSObject>

@required

@optional

- (NSArray *)contactModelsForCollectionView:(ContactCollectionView*)collectionView;

@end

@protocol MBContactPickerDelegate <ContactCollectionViewDelegate>

@required

- (void)showFilteredContacts;
- (void)hideFilteredContacts;
- (void)updateViewHeightTo:(CGFloat)newHeight;

@end

@interface MBContactPicker : UIView <UITextFieldDelegateImproved, UITableViewDataSource, UITableViewDelegate, ContactCollectionViewDelegate>

@property (nonatomic, weak) id<MBContactPickerDelegate> delegate;
@property (nonatomic, weak) id<MBContactPickerDataSource> datasource;
@property (nonatomic, readonly) NSArray *contactsSelected;
@property (nonatomic) NSInteger cellHeight;
@property (nonatomic, copy) NSString *prompt;
@property (nonatomic) CGFloat maxVisibleRows;
@property (nonatomic, readonly) CGFloat currentContentHeight;
@property (nonatomic, readonly) CGFloat keyboardHeight;

@property (nonatomic, weak) id<UITableViewDelegate> searchTableDelegate;
@property (nonatomic, weak) id<UITableViewDataSource> searchTableDataSource;

- (void)reloadData;

@end
