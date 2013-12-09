//
//  ContactPickerView.h
//  MBContactPicker
//
//  Created by Matt Bowman on 12/2/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBContactPicker.h"

@protocol ContactPickerDataSource <NSObject>

@required

@optional

- (NSArray *)contactModelsForCollectionView:(ContactCollectionView*)collectionView;

@end

@protocol ContactPickerDelegate <ContactCollectionViewDelegate>

@required

- (void)showFilteredContacts;
- (void)hideFilteredContacts;
- (void)updateViewHeightTo:(CGFloat)newHeight;

@end

@interface ContactPickerView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegateImproved, UITableViewDataSource, UITableViewDelegate, ContactCollectionViewDelegate>

@property (nonatomic, weak) id<ContactPickerDelegate> delegate;
@property (nonatomic, weak) id<ContactPickerDataSource> datasource;
@property (nonatomic, readonly) NSArray *contactsSelected;
@property (nonatomic) NSInteger cellHeight;
@property (nonatomic, copy) NSString *prompt;
@property (nonatomic) CGFloat maxVisibleRows;
@property (nonatomic, readonly) CGFloat currentContentHeight;
@property (nonatomic, readonly) CGFloat keyboardHeight;
@property (nonatomic, readonly) ContactCollectionViewPromptCell *promptCell;
@property (nonatomic, readonly) ContactEntryCollectionViewCell *entryCell;

@property (nonatomic, weak) id<UITableViewDelegate> searchTableDelegate;
@property (nonatomic, weak) id<UITableViewDataSource> searchTableDataSource;


- (void)addPreselectedContact:(ContactCollectionViewCellModel*)model;
- (void)reloadData;

@end
