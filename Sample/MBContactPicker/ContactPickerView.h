//
//  ContactPickerView.h
//  MBContactPicker
//
//  Created by Matt Bowman on 12/2/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBContactPicker.h"

@protocol ContactCollectionViewDataSource <NSObject>

@required

@optional

- (NSArray *)contactModelsForCollectionView:(ContactCollectionView*)collectionView;

@end

@protocol ContactCollectionViewDelegate <NSObject>

@optional

- (void)didSelectContact:(ContactCollectionViewCellModel*)model inContactCollectionView:(ContactCollectionView*)collectionView;
- (void)didAddContact:(ContactCollectionViewCellModel*)model toContactCollectionView:(ContactCollectionView*)collectionView;
- (void)didRemoveContact:(ContactCollectionViewCellModel*)model fromContactCollectionView:(ContactCollectionView*)collectionView;

@end

@protocol ContactPickerDelegate <ContactCollectionViewDelegate>

@required

- (void)showFilteredContacts;
- (void)hideFilteredContacts;

@end

@interface ContactPickerView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegateImproved, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<ContactPickerDelegate> delegate;
@property (nonatomic, weak) id<ContactCollectionViewDataSource> contactDataSource;
@property (nonatomic, weak) id<ContactCollectionViewDelegate> contactDelegate;
@property (nonatomic, readonly) NSArray *contactsSelected;

- (void)reloadData;

@end
