//
//  ContactCollectionViewPromptCell.h
//  MBContactPicker
//
//  Created by Matt Bowman on 12/1/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBContactCollectionViewPromptCell : UICollectionViewCell

@property (nonatomic, copy) NSString *prompt;
@property (nonatomic) UIEdgeInsets insets;

+ (CGFloat)widthWithPrompt:(NSString *)prompt;

@end
