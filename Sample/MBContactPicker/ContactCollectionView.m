//
//  ContactCollectionView.m
//  MBContactPicker
//
//  Created by Matt Bowman on 11/20/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "ContactCollectionView.h"
#import "ContactEntryCollectionViewCell.h"
#import "ContactCollectionViewPromptCell.h"

@interface ContactCollectionView()

@property (nonatomic) ContactCollectionViewCell *prototypeCell;
@property (nonatomic) UITableView *searchTableView;
@property (nonatomic) NSMutableArray *selectedContacts;
@property (nonatomic) NSArray *contacts;
@property (nonatomic) NSArray *filteredContacts;
@property NSInteger selectedIndex;
@property (nonatomic) ContactCollectionViewPromptCell *promptCell;
@property (nonatomic) ContactEntryCollectionViewCell *entryCell;
@property CGFloat originalHeight;

@end

typedef NS_ENUM(NSInteger, ContactCollectionViewSection) {
    ContactCollectionViewSectionPrompt,
    ContactCollectionViewSectionContact,
    ContactCollectionViewSectionEntry
};

@implementation ContactCollectionView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.originalHeight = -1;
    self.prototypeCell = [[ContactCollectionViewCell alloc] init];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 1;
    
    self.allowsMultipleSelection = NO;
    self.allowsSelection = YES;
    self.delegate = self;
    self.dataSource = self;
    [self registerClass:[ContactCollectionViewCell class] forCellWithReuseIdentifier:@"ContactCell"];
    [self registerClass:[ContactEntryCollectionViewCell class] forCellWithReuseIdentifier:@"ContactEntryCell"];
    [self registerClass:[ContactCollectionViewPromptCell class] forCellWithReuseIdentifier:@"ContactPromptCell"];
    self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 0)];
    self.searchTableView.dataSource = self;
    self.searchTableView.delegate = self;
    [self.searchTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self addSubview:self.searchTableView];
    
    self.selectedContacts = [[NSMutableArray alloc] init];
}

- (void)reloadData
{
    self.contacts = [self.contactDataSource contactModelsForCollectionView:self];
    [super reloadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.originalHeight == -1 || self.originalHeight == 0)
    {
        self.originalHeight = self.frame.size.height;
    }
}

#pragma mark - Properties


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // Index 0 is the prompt (To:)
    // self.selectedContacts.count + 1 is the input box (where you put in your search terms)
    return self.selectedContacts.count + 2;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *collectionCell;
    
    if ([self isPromptCell:indexPath])
    {
        ContactCollectionViewPromptCell *cell = (ContactCollectionViewPromptCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactPromptCell" forIndexPath:indexPath];
        NSString *prompt = @"To:";
        CGRect frame = [prompt boundingRectWithSize:(CGSize){ .width = CGFLOAT_MAX, .height = CGFLOAT_MAX }
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:nil
                                            context:nil];
        cell.frame = (CGRect) { .size.width = frame.size.width + 20, .size.height = frame.size.height + 10, .origin.x = 0, .origin.y = 0 };
        UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
        [cell addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = prompt;
        label.textColor = [UIColor blackColor];
        collectionCell = cell;
        self.promptCell = cell;
    }
    else if ([self isEntryCell:indexPath])
    {
        ContactEntryCollectionViewCell *cell = (ContactEntryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactEntryCell" forIndexPath:indexPath];
        cell.delegate = self;
        collectionCell = cell;
        self.entryCell = cell;
        
    }
    else
    {
        ContactCollectionViewCell *cell = (ContactCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactCell" forIndexPath:indexPath];
        cell.model = self.selectedContacts[[self selectedContactIndexFromIndexPath:indexPath]];
        collectionCell = cell;
    }

    return collectionCell;
}

#pragma mark - UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCollectionViewCell *cell = (ContactCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self becomeFirstResponder];
    self.selectedIndex = indexPath.row;
    cell.focused = YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self isContactCell:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCollectionViewCell *cell = (ContactCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.focused = NO;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isPromptCell:indexPath])
    {
        return CGSizeMake(50, 30);
    }
    else if ([self isEntryCell:indexPath])
    {
        return CGSizeMake(150, 30);
    }
    else
    {
        ContactCollectionViewCellModel *model = self.selectedContacts[[self selectedContactIndexFromIndexPath:indexPath]];
        return [self.prototypeCell sizeForCellWithContact:model];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([string isEqualToString:@"\n"])
    {
        return NO;
    }
    else if ([newString isEqualToString:@""] &&
             [string isEqualToString:@""] &&
             range.location == 0 &&
             range.length == 1)
    {
        if (self.selectedContacts.count > 0)
        {
            [textField resignFirstResponder];
            NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForItem:self.selectedContacts.count
                                                                    inSection:0];
            [self selectItemAtIndexPath:newSelectedIndexPath
                               animated:YES
                         scrollPosition:UICollectionViewScrollPositionBottom];
            [[self delegate] collectionView:self didSelectItemAtIndexPath:newSelectedIndexPath];
            [self becomeFirstResponder];
        }
        return NO;
    }
    else
    {
        if ([newString isEqualToString:@" "])
        {
            [self hideSearchTableView];
        }
        else
        {
            if (![self searchIsVisible])
            {
                [self showSearchTableView];
            }
            NSString *searchString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactTitle contains[cd] %@", searchString];
            self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
            [self.searchTableView reloadData];
        }
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - UIKeyInput

- (void) deleteBackward
{
    if (self.selectedIndex != -1 && self.selectedContacts.count + 1 > self.selectedIndex)
    {
        [self.selectedContacts removeObjectAtIndex:[self selectedContactIndexFromRow:self.selectedIndex]];
        [self deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]]];
    }
    self.selectedIndex = -1;
    [self resignFirstResponder];
    [self.entryCell setFocus];
}

- (BOOL)hasText
{
    return YES;
}

- (void)insertText:(NSString *)text
{
    
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
    if (![self.selectedContacts containsObject:model])
    {
        [self.selectedContacts addObject:model];
        [self insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedContacts.count inSection:0]]];
    }
    [self hideSearchTableView];
    [self.entryCell reset];
    [self.entryCell setFocus];
}


#pragma mark - Helper Methods

- (void)showSearchTableView
{
    CGRect frame = self.frame;
    CGRect entryCellFrame = self.entryCell.frame;

    self.searchTableView.frame = (CGRect)
    {
        .size.width = frame.size.width,
        .size.height = 0,
        .origin.x = 0,
        .origin.y = entryCellFrame.origin.y + entryCellFrame.size.height
    };

    [UIView animateWithDuration:.25 animations:^{
        CGFloat yOffset = self.contentOffset.y - self.entryCell.frame.origin.y;
        CGFloat distanceToKeyboard = self.window.frame.size.height - 216 - self.frame.size.height - self.frame.origin.y;
        self.frame = (CGRect) {
            .size.width = self.frame.size.width,
            .size.height = self.frame.size.height - yOffset + distanceToKeyboard,
            .origin.x = self.frame.origin.x,
            .origin.y = self.frame.origin.y + yOffset
        };

        self.searchTableView.frame = (CGRect)
        {
            .size.width = frame.size.width,
            .size.height = self.frame.size.height + yOffset - entryCellFrame.size.height,
            .origin.x = 0,
            .origin.y = entryCellFrame.origin.y + entryCellFrame.size.height
        };
    }];
    [self scrollRectToVisible:self.entryCell.frame animated:YES];
}

- (void)hideSearchTableView
{
    CGRect frame = self.frame;
    CGRect entryCellFrame = self.entryCell.frame;
    [UIView animateWithDuration:.25 animations:^{
        self.frame = (CGRect) {
            .size.width = self.frame.size.width,
            .size.height = self.originalHeight,
            .origin.x = self.frame.origin.x,
            .origin.y = self.frame.origin.y - (self.contentOffset.y - self.entryCell.frame.origin.y)
        };
        self.searchTableView.frame = (CGRect)
        {
            .size.width = frame.size.width,
            .size.height = 0,
            .origin.x = 0,
            .origin.y = entryCellFrame.origin.y + entryCellFrame.size.height
        };
    }];
    [self scrollRectToVisible:self.entryCell.frame animated:YES];
}

- (BOOL)searchIsVisible
{
    return self.searchTableView.frame.size.height > 0;
}

- (BOOL)isEntryCell:(NSIndexPath*)indexPath
{
    return indexPath.row == [self entryCellIndex];
}

- (BOOL)isPromptCell:(NSIndexPath*)indexPath
{
    return indexPath.row == 0;
}

- (BOOL)isContactCell:(NSIndexPath*)indexPath
{
    return ![self isPromptCell:indexPath] && ![self isEntryCell:indexPath];
}

- (NSInteger)entryCellIndex
{
    return self.selectedContacts.count + 1;
}

- (NSInteger)selectedContactIndexFromIndexPath:(NSIndexPath*)indexPath
{
    return [self selectedContactIndexFromRow:indexPath.row];
}

- (NSInteger)selectedContactIndexFromRow:(NSInteger)row
{
    return row - 1;
}
@end
