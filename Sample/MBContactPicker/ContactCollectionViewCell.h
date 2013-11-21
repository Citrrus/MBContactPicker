//
//  ContactCollectionViewCell.h
//  MBContactPicker
//
//  Created by Matt Bowman on 11/20/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ContactCollectionViewCellModel;

@interface ContactCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) ContactCollectionViewCellModel *model;
@property (nonatomic) BOOL focused;

- (CGSize)sizeForCellWithContact:(ContactCollectionViewCellModel *)model;

@end
