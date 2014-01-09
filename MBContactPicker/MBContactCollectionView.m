//
//  ContactCollectionView.m
//  MBContactPicker
//
//  Created by Matt Bowman on 11/20/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "MBContactCollectionView.h"
#import "MBContactEntryCollectionViewCell.h"
#import "MBContactCollectionViewPromptCell.h"
#import "MBContactCollectionViewFlowLayout.h"

NSInteger const kCellHeight = 31;
NSString * const kPrompt = @"To:";
NSString * const kDefaultEntryText = @" ";

@interface MBContactCollectionView() <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegateImproved, MBContactCollectionViewDelegateFlowLayout, UIKeyInput>

@property (nonatomic, readonly) NSIndexPath *indexPathOfSelectedCell;
@property (nonatomic) MBContactCollectionViewContactCell *prototypeCell;
@property (nonatomic) MBContactCollectionViewPromptCell *promptCell;
@property (nonatomic) NSString *searchText;

@end

typedef NS_ENUM(NSInteger, ContactCollectionViewSection) {
    ContactCollectionViewSectionPrompt,
    ContactCollectionViewSectionContact,
    ContactCollectionViewSectionEntry
};

@implementation MBContactCollectionView

+ (MBContactCollectionView*)contactCollectionViewWithFrame:(CGRect)frame
{
    MBContactCollectionViewFlowLayout *layout = [[MBContactCollectionViewFlowLayout alloc] init];
    return [[self alloc] initWithFrame:frame collectionViewLayout:layout];
}

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

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.selectedContacts = [[NSMutableArray alloc] init];
    
    self.cellHeight = kCellHeight;
    self.prompt = kPrompt;
    self.searchText = kDefaultEntryText;
    
    MBContactCollectionViewFlowLayout *layout = (MBContactCollectionViewFlowLayout*)self.collectionViewLayout;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 1;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    self.prototypeCell = [[MBContactCollectionViewContactCell alloc] init];
    
    self.allowsMultipleSelection = NO;
    self.allowsSelection = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    [self registerClass:[MBContactCollectionViewContactCell class] forCellWithReuseIdentifier:@"ContactCell"];
    [self registerClass:[MBContactEntryCollectionViewCell class] forCellWithReuseIdentifier:@"ContactEntryCell"];
    [self registerClass:[MBContactCollectionViewPromptCell class] forCellWithReuseIdentifier:@"ContactPromptCell"];
    
    self.dataSource = self;
    self.delegate = self;
}

- (CGFloat)maxContentWidth
{
    return self.frame.size.width - self.contentInset.left - self.contentInset.right;
}

#pragma mark - UIResponder

// Important to return YES here if we want to become the first responder after a child (i.e., entry UITextField)
// has given it up so we can respond to keyboard events
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)resignFirstResponder
{
    if (self.indexPathsForSelectedItems.count > 0)
    {
        for (NSIndexPath *indexPath in self.indexPathsForSelectedItems) {
            [self deselectItemAtIndexPath:indexPath animated:YES];
            [self.delegate collectionView:self didDeselectItemAtIndexPath:indexPath];
        }
    }
    
    [self unfocusOnEntry];
    
    [super resignFirstResponder];
    
    return YES;
}

#pragma mark - UIKeyInput

- (void) deleteBackward
{
    if ([self indexPathsForSelectedItems].count > 0)
    {
        [self removeFromSelectedContacts:[self selectedContactIndexFromRow:self.indexPathOfSelectedCell.row] withCompletion:nil];
    }
}

- (BOOL)hasText
{
    return YES;
}

- (void)insertText:(NSString *)text
{
}

#pragma mark - Helper Methods

- (void)addToSelectedContacts:(id<MBContactPickerModelProtocol>)model withCompletion:(void(^)())completion
{
    if ([[self indexPathsForVisibleItems] containsObject:self.entryCellIndexPath])
    {
        MBContactEntryCollectionViewCell *entryCell = (MBContactEntryCollectionViewCell *)[self cellForItemAtIndexPath:[self entryCellIndexPath]];
        [entryCell reset];
    }
    else
    {
        self.searchText = kDefaultEntryText;
    }
    
    if (![self.selectedContacts containsObject:model])
    {
        [self.selectedContacts addObject:model];
        CGPoint originalOffset = self.contentOffset;
        [self performBatchUpdates:^{
            [self insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedContacts.count inSection:0]]];
            self.contentOffset = originalOffset;
        } completion:^(BOOL finished) {
            if (completion)
            {
                completion();
            }
            if ([self.contactDelegate respondsToSelector:@selector(contactCollectionView:didAddContact:)])
            {
                [self.contactDelegate contactCollectionView:self didAddContact:model];
            }
        }];
    }
}

- (void)removeFromSelectedContacts:(NSInteger)index withCompletion:(void(^)())completion
{
    if (self.selectedContacts.count + 1 > self.indexPathsForSelectedItems.count)
    {
        id<MBContactPickerModelProtocol> model = (id<MBContactPickerModelProtocol>)self.selectedContacts[index];
        [self performBatchUpdates:^{
            [self.selectedContacts removeObjectAtIndex:index];
            [self deselectItemAtIndexPath:self.indexPathOfSelectedCell animated:NO];
            [self deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index + 1 inSection:0]]];
            [self scrollToItemAtIndexPath:[self entryCellIndexPath] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        } completion:^(BOOL finished) {
            if (completion)
            {
                completion();
            }
            if ([self.contactDelegate respondsToSelector:@selector(contactCollectionView:didRemoveContact:)])
            {
                [self.contactDelegate contactCollectionView:self didRemoveContact:model];
            }
            [self focusOnEntry];
        }];
    }
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

- (NSIndexPath*)entryCellIndexPath
{
    return [NSIndexPath indexPathForRow:self.selectedContacts.count + 1 inSection:0];
}

- (NSInteger)selectedContactIndexFromIndexPath:(NSIndexPath*)indexPath
{
    return [self selectedContactIndexFromRow:indexPath.row];
}

- (NSInteger)selectedContactIndexFromRow:(NSInteger)row
{
    return row - 1;
}

- (NSIndexPath*)indexPathOfSelectedCell
{
    if (self.indexPathsForSelectedItems.count > 0)
    {
        return (NSIndexPath*)self.indexPathsForSelectedItems[0];
    }
    else
    {
        return nil;
    }
}

- (void)focusOnEntry
{
    if ([self entryIsVisible])
    {
        MBContactEntryCollectionViewCell *entryCell = (MBContactEntryCollectionViewCell *)[self cellForItemAtIndexPath:[self entryCellIndexPath]];
        [entryCell setFocus];
    }
    else
    {
        [self scrollToEntryAnimated:YES onComplete:^{
            MBContactEntryCollectionViewCell *entryCell = (MBContactEntryCollectionViewCell *)[self cellForItemAtIndexPath:[self entryCellIndexPath]];
            [entryCell setFocus];
        }];
    }
}

- (void)unfocusOnEntry
{
    MBContactEntryCollectionViewCell *entryCell = (MBContactEntryCollectionViewCell *)[self cellForItemAtIndexPath:[self entryCellIndexPath]];
    [entryCell unsetFocus];
}

- (BOOL)entryIsVisible
{
    return [[self indexPathsForVisibleItems] containsObject:[self entryCellIndexPath]];
}

- (void)scrollToEntryAnimated:(BOOL)animated onComplete:(void(^)())complete
{
    if (animated)
    {
        [UIView animateWithDuration:.25
                         animations:^{
                             self.contentOffset = CGPointMake(0, self.contentSize.height - self.bounds.size.height);
                         }
                         completion:^(BOOL finished) {
                             if (complete)
                             {
                                 complete();
                             }
                         }];
    }
    else
    {
        [self scrollToItemAtIndexPath:[self entryCellIndexPath]
                     atScrollPosition:UICollectionViewScrollPositionBottom
                             animated:NO];
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MBContactCollectionViewContactCell *cell = (MBContactCollectionViewContactCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self becomeFirstResponder];
    cell.focused = YES;
    
    if ([self.contactDelegate respondsToSelector:@selector(contactCollectionView:didSelectContact:)])
    {
        [self.contactDelegate contactCollectionView:self didSelectContact:cell.model];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self isContactCell:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MBContactCollectionViewContactCell *cell = (MBContactCollectionViewContactCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.focused = NO;
}

#pragma mark - UICollectionViewDelegateContactFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isPromptCell:indexPath])
    {
        CGFloat width = [MBContactCollectionViewPromptCell widthWithPrompt:self.prompt];
        width += 10;
        return CGSizeMake(width, self.cellHeight);
    }
    else if ([self isEntryCell:indexPath])
    {
        MBContactEntryCollectionViewCell *prototype = [[MBContactEntryCollectionViewCell alloc] init];
        
        CGFloat newWidth = MAX(50, [prototype widthForText:self.searchText]);
        CGSize cellSize = CGSizeMake(MIN([self maxContentWidth], newWidth), self.cellHeight);

        return cellSize;
    }
    else
    {
        id<MBContactPickerModelProtocol> model = self.selectedContacts[[self selectedContactIndexFromIndexPath:indexPath]];
        CGSize actualSize = [self.prototypeCell sizeForCellWithContact:model];
        CGSize maxSize = CGSizeMake([self maxContentWidth], actualSize.height);
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

- (void)collectionView:(UICollectionView *)collectionView willChangeContentSizeTo:(CGSize)newSize
{
    if ([self.contactDelegate respondsToSelector:@selector(contactCollectionView:willChangeContentSizeTo:)])
    {
        [self.contactDelegate contactCollectionView:self willChangeContentSizeTo:newSize];
    }
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
    return self.selectedContacts.count + 2;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *collectionCell;
    
    if ([self isPromptCell:indexPath])
    {
        MBContactCollectionViewPromptCell *cell = (MBContactCollectionViewPromptCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactPromptCell" forIndexPath:indexPath];
        cell.prompt = self.prompt;
        collectionCell = cell;
        self.promptCell = cell;
    }
    else if ([self isEntryCell:indexPath])
    {
        MBContactEntryCollectionViewCell *cell = (MBContactEntryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactEntryCell"
                                                                                                                           forIndexPath:indexPath];
        
        cell.delegate = self;
        collectionCell = cell;
        
        if ([self isFirstResponder] && self.indexPathOfSelectedCell == nil)
        {
            [cell setFocus];
        }

        cell.text = self.searchText;
    }
    else
    {
        MBContactCollectionViewContactCell *cell = (MBContactCollectionViewContactCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactCell"
                                                                                                                forIndexPath:indexPath];
        cell.model = self.selectedContacts[[self selectedContactIndexFromIndexPath:indexPath]];
        if ([self.indexPathOfSelectedCell isEqual:indexPath])
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
        if (self.selectedContacts.count > 0)
        {
            [textField resignFirstResponder];
            NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForItem:self.selectedContacts.count
                                                                    inSection:0];
            [self selectItemAtIndexPath:newSelectedIndexPath
                                                     animated:YES
                                               scrollPosition:UICollectionViewScrollPositionBottom];
            [self.delegate collectionView:self didSelectItemAtIndexPath:newSelectedIndexPath];
            [self becomeFirstResponder];
        }
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    self.searchText = textField.text;
    if ([self.contactDelegate respondsToSelector:@selector(contactCollectionView:entryTextDidChange:)])
    {
        [self.contactDelegate contactCollectionView:self entryTextDidChange:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

@end
