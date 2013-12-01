//
//  ContactEntryCollectionViewCell.h
//  MBContactPicker
//
//  Created by Matt Bowman on 11/21/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactEntryCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<UITextFieldDelegate> delegate;

- (void)setFocus;
- (void)reset;

@end
