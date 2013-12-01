//
//  ContactEntryCollectionViewCell.m
//  MBContactPicker
//
//  Created by Matt Bowman on 11/21/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "ContactEntryCollectionViewCell.h"

@interface ContactEntryCollectionViewCell()

@property (nonatomic, weak) UITextField *contactEntryTextField;

@end


@implementation ContactEntryCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    UITextField *textField = [[UITextField alloc] initWithFrame:self.bounds];
    textField.delegate = self.delegate;
    textField.text = @" ";
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
//    self.layer.borderColor = [UIColor orangeColor].CGColor;
//    self.layer.borderWidth = 1.0;
    [self addSubview:textField];
    self.contactEntryTextField = textField;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    _delegate = delegate;
    self.contactEntryTextField.delegate = delegate;
}

- (void)reset
{
    self.contactEntryTextField.text = @" ";
}

- (void)setFocus
{
    [self.contactEntryTextField becomeFirstResponder];
}

@end
