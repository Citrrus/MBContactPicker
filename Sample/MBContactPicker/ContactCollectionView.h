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
@class ContactCollectionView;

@protocol ContactCollectionViewDataSource <NSObject>

@required

@optional

- (NSArray *)contactModelsForCollectionView:(ContactCollectionView*)collectionView;
- (ContactCollectionViewCellModel *)contactModelForCollectionView:(ContactCollectionView*)collectionView atIndexPath:(NSIndexPath *)indexPath;

@end

@protocol ContactCollectionViewDelegate <NSObject>

@optional

- (void)maximumHeightForContactSearchTableViewInContactCollectionView:(ContactCollectionView*)collectionView;
- (void)didSelectContact:(ContactCollectionViewCellModel*)model inContactCollectionView:(ContactCollectionView*)collectionView;
- (void)didAddContact:(ContactCollectionViewCellModel*)model toContactCollectionView:(ContactCollectionView*)collectionView;
- (void)didRemoveContact:(ContactCollectionViewCellModel*)model fromContactCollectionView:(ContactCollectionView*)collectionView;

@end


@interface ContactCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIKeyInput>

@property (nonatomic, weak) id<ContactCollectionViewDataSource> contactDataSource;
@property (nonatomic, weak) id<ContactCollectionViewDelegate> contactDelegate;
@property (nonatomic, weak) id<UITableViewDelegate> searchTableViewDelegate;
@property (nonatomic, readonly) NSArray *contactsSelected;

@end
