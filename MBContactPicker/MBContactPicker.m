//
//  MBContactPicker.m
//  MBContactPicker
//
//  Created by Matt Bowman on 12/2/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "MBContactPicker.h"

const CGFloat kMaxVisibleRows = 2;
NSString * const kMBPrompt = @"To:";

@interface MBContactPicker()

@property (nonatomic, weak) ContactCollectionView *contactCollectionView;
@property (nonatomic, weak) UITableView *searchTableView;
@property (nonatomic) NSArray *filteredContacts;
@property (nonatomic) NSArray *contacts;
@property (nonatomic) CGFloat keyboardHeight;

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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    ContactCollectionView *contactCollectionView = [ContactCollectionView contactCollectionViewWithFrame:self.bounds];
    contactCollectionView.contactDelegate = self;
    contactCollectionView.contactEntryTextDelegate = self;
    contactCollectionView.clipsToBounds = YES;
    contactCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contactCollectionView];
    self.contactCollectionView = contactCollectionView;

    UITableView *searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 0)];
    searchTableView.dataSource = self;
    searchTableView.delegate = self;
    searchTableView.translatesAutoresizingMaskIntoConstraints = NO;
    searchTableView.hidden = YES;
    [searchTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
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
    
    [self updateCollectionViewHeightConstraints];
    
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

- (void)addPreselectedContact:(ContactCollectionViewCellModel*)model
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
    _cellHeight = cellHeight;
    self.contactCollectionView.cellHeight = cellHeight;
    [self updateCollectionViewHeightConstraints];
    [self.contactCollectionView.collectionViewLayout invalidateLayout];
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
    [self updateCollectionViewHeightConstraints];
}

- (CGFloat)currentContentHeight
{
    return MIN(self.contactCollectionView.contentSize.height, self.maxVisibleRows * self.contactCollectionView.cellHeight);
}

#pragma mark - UITextFieldDelegateImproved

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    // If backspace is pressed and there isn't any text in the field, we want to select the
    // last selected contact and not let them delete the space we inserted (the space allows
    // us to catch the last backspace press - without it, we get no event!)
    if ([newString isEqualToString:@""] &&
        [string isEqualToString:@""] &&
        range.location == 0 &&
        range.length == 1)
    {
        if (self.contactCollectionView.selectedContacts.count > 0)
        {
            [textField resignFirstResponder];
            NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForItem:self.contactsSelected.count
                                                                    inSection:0];
            [self.contactCollectionView selectItemAtIndexPath:newSelectedIndexPath
                                              animated:YES
                                        scrollPosition:UICollectionViewScrollPositionBottom];
            [self.contactCollectionView.delegate collectionView:self.contactCollectionView didSelectItemAtIndexPath:newSelectedIndexPath];
            [self.contactCollectionView becomeFirstResponder];
        }
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{

    [self.contactCollectionView performBatchUpdates:^{
        [self.contactCollectionView.collectionViewLayout invalidateLayout];
        [self updateCollectionViewHeightConstraints];
    }
                                  completion:^(BOOL finished) {
                                      [self.contactCollectionView scrollToEntry];
                                  }];

    if ([textField.text isEqualToString:@" "])
    {
        [self hideSearchTableView];
    }
    else
    {
        [self showSearchTableView];
        NSString *searchString = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactTitle contains[cd] %@", searchString];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
        [self.searchTableView reloadData];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredContacts.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = ((ContactCollectionViewCellModel*)self.filteredContacts[indexPath.row]).contactTitle;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCollectionViewCellModel *model = self.filteredContacts[indexPath.row];
#warning TODO: Figure this out somehow.  Maybe a reloadData overload?
//    [self.entryCell reset];
    [self hideSearchTableView];
    [self.contactCollectionView addToSelectedContacts:model withCompletion:^{
        [UIView animateWithDuration:.25 animations:^{
            [self updateCollectionViewHeightConstraints];
            if ([self.delegate respondsToSelector:@selector(updateViewHeightTo:)])
            {
                [self.delegate updateViewHeightTo:self.currentContentHeight];
            }
        } completion:^(BOOL finished) {
            [self becomeFirstResponder];
        }];
    }];
}

#pragma mark - ContactCollectionViewDelegate

- (void)didRemoveContact:(ContactCollectionViewCellModel *)model fromContactCollectionView:(ContactCollectionView *)collectionView
{
    [UIView animateWithDuration:.25 animations:^{
        [self updateCollectionViewHeightConstraints];
        if ([self.delegate respondsToSelector:@selector(updateViewHeightTo:)])
        {
            [self.delegate updateViewHeightTo:self.currentContentHeight];
        }
    }];
    
    if ([self.delegate respondsToSelector:@selector(didRemoveContact:fromContactCollectionView:)])
    {
        [self.delegate didRemoveContact:model fromContactCollectionView:collectionView];
    }
}

- (void)didAddContact:(ContactCollectionViewCellModel *)model toContactCollectionView:(ContactCollectionView *)collectionView
{
    if ([self.delegate respondsToSelector:@selector(didAddContact:toContactCollectionView:)])
    {
        [self.delegate didAddContact:model toContactCollectionView:collectionView];
    }
}

- (void)didSelectContact:(ContactCollectionViewCellModel *)model inContactCollectionView:(ContactCollectionView *)collectionView
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
#warning need to push this logic down into ContactCollectionView, it'll make more sense there
    if (![self isFirstResponder])
    {
        if (self.contactCollectionView.indexPathOfSelectedCell)
        {
            [self.contactCollectionView scrollToItemAtIndexPath:self.contactCollectionView.indexPathOfSelectedCell atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        }
        else
        {
            [self.contactCollectionView scrollToEntry];

//            [self.entryCell setFocus];
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
                if (constraint.relation == NSLayoutRelationLessThanOrEqual)
                {
                    constraint.constant = self.currentContentHeight;
                }
                else if (constraint.relation == NSLayoutRelationGreaterThanOrEqual)
                {
                    constraint.constant = self.contactCollectionView.cellHeight;
                }
            }
        }
    }
}

@end
