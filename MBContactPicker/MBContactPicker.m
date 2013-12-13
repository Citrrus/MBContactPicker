//
//  MBContactPicker.m
//  MBContactPicker
//
//  Created by Matt Bowman on 12/2/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "MBContactPicker.h"

const NSInteger kCellHeight = 31;
const NSString *kPrompt = @"To:";
const CGFloat kMaxVisibleRows = 2;


@interface MBContactPicker()

@property (nonatomic, weak) ContactCollectionView *collectionView;
@property (nonatomic, weak) UITableView *searchTableView;
@property (nonatomic) NSArray *filteredContacts;
@property (nonatomic) NSArray *contacts;
@property (nonatomic) ContactCollectionViewCell *prototypeCell;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) ContactCollectionViewPromptCell *promptCell;
@property (nonatomic) ContactEntryCollectionViewCell *entryCell;

@property NSInteger selectedIndex;
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
    self.selectedIndex = -1;
    self.originalHeight = -1;
    self.originalYOffset = -1;
    self.cellHeight = kCellHeight;
    self.prompt = [kPrompt copy];
    self.maxVisibleRows = kMaxVisibleRows;
    self.prototypeCell = [[ContactCollectionViewCell alloc] init];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    

    UICollectionViewContactFlowLayout *layout = [[UICollectionViewContactFlowLayout alloc] init];
    ContactCollectionView *contactCollectionView = [[ContactCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    contactCollectionView.contactDelegate = self;
    contactCollectionView.delegate = self;
    contactCollectionView.dataSource = self;
    contactCollectionView.clipsToBounds = YES;
    contactCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contactCollectionView];
    [contactCollectionView registerClass:[ContactCollectionViewCell class] forCellWithReuseIdentifier:@"ContactCell"];
    [contactCollectionView registerClass:[ContactEntryCollectionViewCell class] forCellWithReuseIdentifier:@"ContactEntryCell"];
    [contactCollectionView registerClass:[ContactCollectionViewPromptCell class] forCellWithReuseIdentifier:@"ContactPromptCell"];
    self.collectionView = contactCollectionView;
    

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
    self.contacts = [self.datasource contactModelsForCollectionView:self.collectionView];
}

- (void)addPreselectedContact:(id<MBContactPickerModelProtocol>)model
{
    [self.collectionView.selectedContacts addObject:model];
}

#pragma mark - Properties

- (NSArray*)contactsSelected
{
    return self.collectionView.selectedContacts;
}

- (void)setCellHeight:(NSInteger)cellHeight
{
    _cellHeight = cellHeight;
    [self updateCollectionViewHeightConstraints];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)setPrompt:(NSString *)prompt
{
    _prompt = prompt;
    self.promptCell.prompt = prompt;
}

- (void)setMaxVisibleRows:(CGFloat)maxVisibleRows
{
    _maxVisibleRows = maxVisibleRows;
    [self updateCollectionViewHeightConstraints];
}

- (CGFloat)currentContentHeight
{
    return MIN(self.collectionView.contentSize.height, self.maxVisibleRows * self.cellHeight);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // Index 0 is the prompt (To:)
    // self.selectedContacts.count + 1 is the input box (where you put in your search terms)
    return self.collectionView.selectedContacts.count + 2;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *collectionCell;
    
    if ([self.collectionView isPromptCell:indexPath])
    {
        ContactCollectionViewPromptCell *cell = (ContactCollectionViewPromptCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactPromptCell" forIndexPath:indexPath];
        cell.prompt = self.prompt;
        collectionCell = cell;
        self.promptCell = cell;
    }
    else if ([self.collectionView isEntryCell:indexPath])
    {
        ContactEntryCollectionViewCell *cell = (ContactEntryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactEntryCell"
                                                                                                                           forIndexPath:indexPath];
        cell.delegate = self;
        collectionCell = cell;

        if ([self.collectionView isFirstResponder] && self.collectionView.indexPathOfSelectedCell == nil)
        {
            [cell setFocus];
        }

        self.entryCell = cell;
    }
    else
    {
        ContactCollectionViewCell *cell = (ContactCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactCell"
                                                                                                                forIndexPath:indexPath];
        cell.model = self.collectionView.selectedContacts[[self.collectionView selectedContactIndexFromIndexPath:indexPath]];
        if ([self.collectionView.indexPathOfSelectedCell isEqual:indexPath])
        {
            cell.focused = YES;
        }
        else
        {
            cell.focused = NO;
        }
        collectionCell = cell;
    }
    
    return collectionCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCollectionViewCell *cell = (ContactCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.collectionView becomeFirstResponder];
    self.selectedIndex = indexPath.row;
    cell.focused = YES;
    
    if ([self.delegate respondsToSelector:@selector(didSelectContact:inContactCollectionView:)])
    {
        [self.delegate didSelectContact:cell.model inContactCollectionView:self.collectionView];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.collectionView isContactCell:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCollectionViewCell *cell = (ContactCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.focused = NO;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.collectionView isPromptCell:indexPath])
    {
        CGFloat width = [ContactCollectionViewPromptCell widthWithPrompt:self.prompt];
        width += 10;
        return CGSizeMake(width, self.cellHeight);
    }
    else if ([self.collectionView isEntryCell:indexPath])
    {
        ContactEntryCollectionViewCell *prototype = self.entryCell;
        if (!prototype)
        {
            prototype = [[ContactEntryCollectionViewCell alloc] init];
        }
        CGFloat newWidth = MIN(prototype.frame.size.width, MAX(50, [prototype widthForText:prototype.text]));
        CGSize cellSize = CGSizeMake(newWidth, self.cellHeight);
        return cellSize;
    }
    else
    {
        id<MBContactPickerModelProtocol>model = self.contactsSelected[[self.collectionView selectedContactIndexFromIndexPath:indexPath]];
        CGSize actualSize = [self.prototypeCell sizeForCellWithContact:model];
        CGSize maxSize = CGSizeMake(self.frame.size.width - self.collectionView.contentInset.left - self.collectionView.contentInset.right, actualSize.height);
        if (actualSize.width > maxSize.width)
        {
            return maxSize;
        }
        else
        {
            return actualSize;
        }
    }
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
        if (self.collectionView.selectedContacts.count > 0)
        {
            [textField resignFirstResponder];
            NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForItem:self.contactsSelected.count
                                                                    inSection:0];
            [self.collectionView selectItemAtIndexPath:newSelectedIndexPath
                                              animated:YES
                                        scrollPosition:UICollectionViewScrollPositionBottom];
            [self.collectionView.delegate collectionView:self.collectionView didSelectItemAtIndexPath:newSelectedIndexPath];
            [self.collectionView becomeFirstResponder];
        }
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{

    [self.collectionView performBatchUpdates:^{
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self updateCollectionViewHeightConstraints];
    }
                                  completion:^(BOOL finished) {
                                      [self.collectionView scrollToEntry];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"Cell"];
    }

    id<MBContactPickerModelProtocol> model = (id<MBContactPickerModelProtocol>)self.filteredContacts[indexPath.row];

    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.imageView.image = nil;
    
    if ([model respondsToSelector:@selector(contactTitle)])
    {
        cell.textLabel.text = model.contactTitle;
    }
    
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
    [self.entryCell reset];
    [self hideSearchTableView];
    [self.collectionView addToSelectedContacts:model withCompletion:^{
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

- (void)didRemoveContact:(id<MBContactPickerModelProtocol>)model fromContactCollectionView:(ContactCollectionView *)collectionView
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

- (void)didAddContact:(id<MBContactPickerModelProtocol>)model toContactCollectionView:(ContactCollectionView *)collectionView
{
    if ([self.delegate respondsToSelector:@selector(didAddContact:toContactCollectionView:)])
    {
        [self.delegate didAddContact:model toContactCollectionView:collectionView];
    }
}

- (void)didSelectContact:(id<MBContactPickerModelProtocol>)model inContactCollectionView:(ContactCollectionView *)collectionView
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
        if (self.collectionView.indexPathOfSelectedCell)
        {
            [self.collectionView scrollToItemAtIndexPath:self.collectionView.indexPathOfSelectedCell atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        }
        else
        {
            [self.collectionView scrollToEntry];
            [self.entryCell setFocus];
        }
    }
    
    return YES;
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return [self.collectionView resignFirstResponder];
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
        if (constraint.firstItem == self.collectionView)
        {
            if (constraint.firstAttribute == NSLayoutAttributeHeight)
            {
                if (constraint.relation == NSLayoutRelationLessThanOrEqual)
                {
                    constraint.constant = self.currentContentHeight;
                }
                else if (constraint.relation == NSLayoutRelationGreaterThanOrEqual)
                {
                    constraint.constant = self.cellHeight;
                }
            }
        }
    }
}

@end
