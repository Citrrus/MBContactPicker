//
//  MBContactPicker.m
//  MBContactPicker
//
//  Created by Matt Bowman on 12/2/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "MBContactPicker.h"

CGFloat const kMaxVisibleRows = 2;
NSString * const kMBPrompt = @"To:";
CGFloat const kAnimationSpeed = .25;

@interface MBContactPicker()

@property (nonatomic, weak) MBContactCollectionView *contactCollectionView;
@property (nonatomic, weak) UITableView *searchTableView;
@property (nonatomic) NSArray *filteredContacts;
@property (nonatomic) NSArray *contacts;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) CGSize contactCollectionViewContentSize;

@property CGFloat originalHeight;
@property CGFloat originalYOffset;

@end

@implementation MBContactPicker

- (void)awakeFromNib
{
    [self setup];
}

- (void)didMoveToWindow
{
    if (self.window)
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(keyboardChangedStatus:) name:UIKeyboardWillShowNotification object:nil];
        [nc addObserver:self selector:@selector(keyboardChangedStatus:) name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if (newWindow == nil)
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)setup
{
    self.originalHeight = -1;
    self.originalYOffset = -1;
    self.maxVisibleRows = kMaxVisibleRows;
    self.animationSpeed = kAnimationSpeed;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.clipsToBounds = YES;
    MBContactCollectionView *contactCollectionView = [MBContactCollectionView contactCollectionViewWithFrame:self.bounds];
    contactCollectionView.contactDelegate = self;
    contactCollectionView.clipsToBounds = YES;
    contactCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contactCollectionView];
    self.contactCollectionView = contactCollectionView;

    UITableView *searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 0)];
    searchTableView.dataSource = self;
    searchTableView.delegate = self;
    searchTableView.translatesAutoresizingMaskIntoConstraints = NO;
    searchTableView.hidden = YES;
    [self addSubview:searchTableView];
    self.searchTableView = searchTableView;
    
    
    [contactCollectionView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [searchTableView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[contactCollectionView(>=%ld,<=%ld)][searchTableView(>=0)]|", (long)self.cellHeight, (long)self.cellHeight]
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(contactCollectionView, searchTableView)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contactCollectionView]-(0@500)-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(contactCollectionView)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contactCollectionView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(contactCollectionView)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchTableView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(searchTableView)]];
    
    
#ifdef DEBUG_BORDERS
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 1.0;
    contactCollectionView.layer.borderColor = [UIColor redColor].CGColor;
    contactCollectionView.layer.borderWidth = 1.0;
    searchTableView.layer.borderColor = [UIColor blueColor].CGColor;
    searchTableView.layer.borderWidth = 1.0;
#endif
}

#pragma mark - Keyboard Notification Handling
- (void)keyboardChangedStatus:(NSNotification*)notification
{
    CGRect keyboardRect;
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardRect];
    self.keyboardHeight = keyboardRect.size.height;
}

- (void)reloadData
{
    self.contacts = [self.datasource contactModelsForCollectionView:self.contactCollectionView];
    [self.contactCollectionView reloadData];
}

- (void)addPreselectedContact:(id<MBContactPickerModelProtocol>)model
{
    [self.contactCollectionView.selectedContacts addObject:model];
}

#pragma mark - Properties

- (NSArray*)contactsSelected
{
    return self.contactCollectionView.selectedContacts;
}

- (void)setCellHeight:(NSInteger)cellHeight
{
    self.contactCollectionView.cellHeight = cellHeight;
    [self.contactCollectionView.collectionViewLayout invalidateLayout];
}

- (NSInteger)cellHeight
{
    return self.contactCollectionView.cellHeight;
}

- (void)setPrompt:(NSString *)prompt
{
    _prompt = prompt;
    self.contactCollectionView.prompt = prompt;
    [self.contactCollectionView.collectionViewLayout invalidateLayout];
}

- (void)setMaxVisibleRows:(CGFloat)maxVisibleRows
{
    _maxVisibleRows = maxVisibleRows;
    [self.contactCollectionView.collectionViewLayout invalidateLayout];
}

- (CGFloat)currentContentHeight
{
    CGFloat minimumSizeWithContent = MAX(self.cellHeight, self.contactCollectionViewContentSize.height);
    CGFloat maximumSize = self.maxVisibleRows * self.cellHeight;
    return MIN(minimumSizeWithContent, maximumSize);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredContacts.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"Cell"];
    }

    id<MBContactPickerModelProtocol> model = (id<MBContactPickerModelProtocol>)self.filteredContacts[indexPath.row];

    cell.textLabel.text = model.contactTitle;

    cell.detailTextLabel.text = nil;
    cell.imageView.image = nil;
    
    if ([model respondsToSelector:@selector(contactSubtitle)])
    {
        cell.detailTextLabel.text = model.contactSubtitle;
    }
    
    if ([model respondsToSelector:@selector(contactImage)])
    {
        cell.imageView.image = model.contactImage;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MBContactPickerModelProtocol> model = self.filteredContacts[indexPath.row];
    
    [self hideSearchTableView];
    [self.contactCollectionView addToSelectedContacts:model withCompletion:^{
        [self becomeFirstResponder];
    }];
}

#pragma mark - ContactCollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willChangeContentSizeFrom:(CGSize)currentSize to:(CGSize)newSize
{
    self.contactCollectionViewContentSize = newSize;
    [self updateCollectionViewHeightConstraints];

    if ([self.delegate respondsToSelector:@selector(updateViewHeightTo:)])
    {
        [self.delegate updateViewHeightTo:self.currentContentHeight];
    }
}

- (void)entryTextDidChange:(NSString*)text inContactCollectionView:(MBContactCollectionView*)collectionView
{
    [self.contactCollectionView.collectionViewLayout invalidateLayout];

    [self.contactCollectionView performBatchUpdates:^{
        [self layoutIfNeeded];
    }
    completion:^(BOOL finished) {
        [self.contactCollectionView focusOnEntry];
    }];
    
    if ([text isEqualToString:@" "])
    {
        [self hideSearchTableView];
    }
    else
    {
        [self showSearchTableView];
        NSString *searchString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactTitle contains[cd] %@", searchString];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
        [self.searchTableView reloadData];
    }
}

- (void)didRemoveContact:(id<MBContactPickerModelProtocol>)model fromContactCollectionView:(MBContactCollectionView *)collectionView
{
    if ([self.delegate respondsToSelector:@selector(didRemoveContact:fromContactCollectionView:)])
    {
        [self.delegate didRemoveContact:model fromContactCollectionView:collectionView];
    }
}

- (void)didAddContact:(id<MBContactPickerModelProtocol>)model toContactCollectionView:(MBContactCollectionView *)collectionView
{
    if ([self.delegate respondsToSelector:@selector(didAddContact:toContactCollectionView:)])
    {
        [self.delegate didAddContact:model toContactCollectionView:collectionView];
    }
}

- (void)didSelectContact:(id<MBContactPickerModelProtocol>)model inContactCollectionView:(MBContactCollectionView *)collectionView
{
    if ([self.delegate respondsToSelector:@selector(didSelectContact:inContactCollectionView:)])
    {
        [self.delegate didSelectContact:model inContactCollectionView:collectionView];
    }
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    if (![self isFirstResponder])
    {
        if (self.contactCollectionView.indexPathOfSelectedCell)
        {
            [self.contactCollectionView scrollToItemAtIndexPath:self.contactCollectionView.indexPathOfSelectedCell atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        }
        else
        {
            [self.contactCollectionView focusOnEntry];
        }
    }
    
    return YES;
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return [self.contactCollectionView resignFirstResponder];
}

#pragma mark Helper Methods

- (void)showSearchTableView
{
    self.searchTableView.hidden = NO;
    if ([self.delegate respondsToSelector:@selector(showFilteredContacts)])
    {
        [self.delegate showFilteredContacts];
    }
}

- (void)hideSearchTableView
{
    self.searchTableView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(hideFilteredContacts)])
    {
        [self.delegate hideFilteredContacts];
    }
}

- (void)updateCollectionViewHeightConstraints
{
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        if (constraint.firstItem == self.contactCollectionView)
        {
            if (constraint.firstAttribute == NSLayoutAttributeHeight)
            {
                if (constraint.relation == NSLayoutRelationGreaterThanOrEqual)
                {
                    constraint.constant = self.cellHeight;
                }
                else if (constraint.relation == NSLayoutRelationLessThanOrEqual)
                {
                    constraint.constant = self.currentContentHeight;
                }
            }
        }
    }

}

@end
