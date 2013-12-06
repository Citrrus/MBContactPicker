//
//  ContactCollectionViewPromptCell.m
//  MBContactPicker
//
//  Created by Matt Bowman on 12/1/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "ContactCollectionViewPromptCell.h"

@interface ContactCollectionViewPromptCell()

@property (nonatomic, weak) UILabel *promptLabel;

@end

@implementation ContactCollectionViewPromptCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithPrompt:(NSString*)prompt
{
    self = [super init];
    if (self)
    {
        self.prompt = prompt;
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
    self.insets = UIEdgeInsetsMake(0, 5, 0, 5);
#ifdef DEBUG_BORDERS
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor purpleColor].CGColor;
#endif
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:label];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(label)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(label)]];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.prompt;
    label.textColor = [UIColor blackColor];
    self.promptLabel = label;
}

- (void)setPrompt:(NSString *)prompt
{
    _prompt = prompt;
    self.promptLabel.text = prompt;
}

+ (CGFloat)widthWithPrompt:(NSString *)prompt
{
    CGRect frame = [prompt boundingRectWithSize:(CGSize){ .width = CGFLOAT_MAX, .height = CGFLOAT_MAX }
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:nil
                                        context:nil];
    return ceilf(frame.size.width) + 10;
}

@end
