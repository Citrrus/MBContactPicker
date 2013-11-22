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

- (NSArray*)contactModelsInCollectionView:(ContactCollectionView*)collectionView;

@end

@protocol ContactCollectionViewDelegate <NSObject>

@optional

- (void)didSelectContact:(ContactCollectionViewCellModel*)model inContactCollectionView:(ContactCollectionView*)collectionView;
- (void)didAddContact:(ContactCollectionViewCellModel*)model toContactCollectionView:(ContactCollectionView*)collectionView;
- (void)didRemoveContact:(ContactCollectionViewCellModel*)model fromContactCollectionView:(ContactCollectionView*)collectionView;

@end


@interface ContactCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id<ContactCollectionViewDataSource> contactDataSource;
@property (nonatomic, weak) id<ContactCollectionViewDelegate> contactDelegate;

@end
