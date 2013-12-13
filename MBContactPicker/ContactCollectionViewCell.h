//
//  ContactCollectionViewCell.h
//  MBContactPicker
//
//  Created by Matt Bowman on 11/20/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBContactModel.h"

@interface ContactCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) id<MBContactPickerModelProtocol> model;
@property (nonatomic) BOOL focused;

- (CGSize)sizeForCellWithContact:(id<MBContactPickerModelProtocol>)model;

@end
