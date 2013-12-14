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
#import "UICollectionViewContactFlowLayout.h"

NSInteger const kCellHeight = 31;
NSString * const kPrompt = @"To:";
NSString * const kDefaultEntryText = @" ";

@interface ContactCollectionView() <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegateImproved>

@property (nonatomic, readonly) NSIndexPath *indexPathOfSelectedCell;
@property (nonatomic) ContactCollectionViewCell *prototypeCell;
@property (nonatomic) ContactCollectionViewPromptCell *promptCell;
@property (nonatomic) NSString *searchText;

@end

typedef NS_ENUM(NSInteger, ContactCollectionViewSection) {
    ContactCollectionViewSectionPrompt,
    ContactCollectionViewSectionContact,
    ContactCollectionViewSectionEntry
};

@implementation ContactCollectionView

+ (ContactCollectionView*)contactCollectionViewWithFrame:(CGRect)frame
{
    UICollectionViewContactFlowLayout *layout = [[UICollectionViewContactFlowLayout alloc] init];
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
    
    UICollectionViewContactFlowLayout *layout = (UICollectionViewContactFlowLayout*)self.collectionViewLayout;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 1;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    self.prototypeCell = [[ContactCollectionViewCell alloc] init];
    
    self.allowsMultipleSelection = NO;
    self.allowsSelection = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    [self registerClass:[ContactCollectionViewCell class] forCellWithReuseIdentifier:@"ContactCell"];
    [self registerClass:[ContactEntryCollectionViewCell class] forCellWithReuseIdentifier:@"ContactEntryCell"];
    [self registerClass:[ContactCollectionViewPromptCell class] forCellWithReuseIdentifier:@"ContactPromptCell"];
    
    self.dataSource = self;
    self.delegate = self;
}

#pragma mark - UIResponder

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
    return [super resignFirstResponder];
}

#pragma mark - UIKeyInput

- (void) deleteBackward
{
    if ([self indexPathsForSelectedItems].count > 0)
    {
            [self removeFromSelectedContacts:[self selectedContactIndexFromRow:self.indexPathOfSelectedCell.row] withCompletion:^{
//                [self resignFirstResponder];
//                [self focusOnEntry];
                ContactEntryCollectionViewCell *entryCell = (ContactEntryCollectionViewCell *)[self cellForItemAtIndexPath:[self entryCellIndexPath]];
                [entryCell setFocus];
            }];
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
        ContactEntryCollectionViewCell *entryCell = (ContactEntryCollectionViewCell *)[self cellForItemAtIndexPath:[self entryCellIndexPath]];
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
            if ([self.contactDelegate respondsToSelector:@selector(didAddContact:toContactCollectionView:)])
            {
                [self.contactDelegate didAddContact:model toContactCollectionView:self];
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
        } completion:^(BOOL finished) {
            if (completion)
            {
                completion();
            }
            if ([self.contactDelegate respondsToSelector:@selector(didRemoveContact:fromContactCollectionView:)])
            {
                [self.contactDelegate didRemoveContact:model fromContactCollectionView:self];
            }
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
    [self scrollToEntryAnimated:YES onComplete:^{
        ContactEntryCollectionViewCell *entryCell = (ContactEntryCollectionViewCell *)[self cellForItemAtIndexPath:[self entryCellIndexPath]];
        [entryCell setFocus];
    }];
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
    ContactCollectionViewCell *cell = (ContactCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self becomeFirstResponder];
    cell.focused = YES;
    
    if ([self.contactDelegate respondsToSelector:@selector(didSelectContact:inContactCollectionView:)])
    {
        [self.contactDelegate didSelectContact:cell.model inContactCollectionView:self];
    }
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

#pragma mark - UICollectionViewDelegateContactFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isPromptCell:indexPath])
    {
        CGFloat width = [ContactCollectionViewPromptCell widthWithPrompt:self.prompt];
        width += 10;
        return CGSizeMake(width, self.cellHeight);
    }
    else if ([self isEntryCell:indexPath])
    {
        ContactEntryCollectionViewCell *prototype = [[ContactEntryCollectionViewCell alloc] init];
        
        CGFloat newWidth = MAX(50, MIN([prototype widthForText:self.searchText], self.bounds.size.width));
        NSLog(@"New Width: %f", newWidth);
        CGSize cellSize = CGSizeMake(newWidth, self.cellHeight);
        return cellSize;
    }
    else
    {
        id<MBContactPickerModelProtocol> model = self.selectedContacts[[self selectedContactIndexFromIndexPath:indexPath]];
        CGSize actualSize = [self.prototypeCell sizeForCellWithContact:model];
        CGSize maxSize = CGSizeMake(self.frame.size.width - self.contentInset.left - self.contentInset.right, actualSize.height);
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

- (void)collectionView:(UICollectionView *)collectionView willChangeContentSizeFrom:(CGRect)currentSize to:(CGRect)newSize
{
    if ([self.contactDelegate respondsToSelector:@selector(collectionView:willChangeContentSizeFrom:to:)])
    {
        [self.contactDelegate collectionView:self willChangeContentSizeFrom:currentSize to:newSize];
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
        ContactCollectionViewPromptCell *cell = (ContactCollectionViewPromptCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactPromptCell" forIndexPath:indexPath];
        cell.prompt = self.prompt;
        collectionCell = cell;
        self.promptCell = cell;
    }
    else if ([self isEntryCell:indexPath])
    {
        ContactEntryCollectionViewCell *cell = (ContactEntryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactEntryCell"
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
        ContactCollectionViewCell *cell = (ContactCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactCell"
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
    if ([self.contactDelegate respondsToSelector:@selector(entryTextDidChange:inContactCollectionView:)])
    {
        [self.contactDelegate entryTextDidChange:textField.text inContactCollectionView:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

@end
