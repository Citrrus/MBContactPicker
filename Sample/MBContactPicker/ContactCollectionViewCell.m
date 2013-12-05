//
//  ContactCollectionViewCell.m
//  MBContactPicker
//
//  Created by Matt Bowman on 11/20/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "ContactCollectionViewCell.h"
#import "ContactCollectionViewCellModel.h"

@interface ContactCollectionViewCell()

@property (nonatomic, weak) UILabel *contactTitleLabel;

@end

@implementation ContactCollectionViewCell

@synthesize focused = _focused;

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
    UILabel *contactLabel = [[UILabel alloc] initWithFrame:self.bounds];
    [self addSubview:contactLabel];
    contactLabel.textColor = [UIColor blueColor];
    contactLabel.textAlignment = NSTextAlignmentCenter;
    [contactLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.contactTitleLabel = contactLabel;

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contactTitleLabel]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"contactTitleLabel":self.contactTitleLabel}]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contactTitleLabel]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"contactTitleLabel":self.contactTitleLabel}]];
}

- (void)setModel:(ContactCollectionViewCellModel *)model
{
    _model = model;
    self.contactTitleLabel.text = self.model.contactTitle;
}

- (CGSize)sizeForCellWithContact:(ContactCollectionViewCellModel *)model
{
    UIFont *font = self.contactTitleLabel.font;
    CGSize size = [model.contactTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:0 attributes:@{ NSFontAttributeName: font } context:nil].size;
    size = CGSizeMake(ceilf(size.width) + 10, ceilf(size.height) + 10);
    return size;
}

- (void)setFocused:(BOOL)focused
{
    if (focused)
    {
        self.contactTitleLabel.textColor = [UIColor whiteColor];
        self.contactTitleLabel.backgroundColor = [UIColor blueColor];
        self.contactTitleLabel.layer.cornerRadius = 3.0f;
    }
    else
    {
        self.contactTitleLabel.textColor = [UIColor blueColor];
        self.contactTitleLabel.backgroundColor = [UIColor clearColor];
    }
    _focused = focused;
}

@end
