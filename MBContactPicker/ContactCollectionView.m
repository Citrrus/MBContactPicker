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

@property (nonatomic) NSMutableArray *selectedContacts;
@property (nonatomic, readonly) NSIndexPath *indexPathOfSelectedCell;

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
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 1;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    self.allowsMultipleSelection = NO;
    self.allowsSelection = YES;
    self.backgroundColor = [UIColor whiteColor];
    
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
            [self.delegate collectionView:self didDeselectItemAtIndexPath:indexPath];
        }
    }
    return YES;
}

#pragma mark - UIKeyInput

- (void) deleteBackward
{
    if ([self indexPathsForSelectedItems].count > 0)
    {
            [self removeFromSelectedContacts:[self selectedContactIndexFromRow:self.indexPathOfSelectedCell.row] withCompletion:^{
                [self scrollToEntry];
                [self resignFirstResponder];
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

- (void)addToSelectedContacts:(ContactCollectionViewCellModel*)model withCompletion:(void(^)())completion
{
    if (![self.selectedContacts containsObject:model])
    {
        [self.selectedContacts addObject:model];
        [self performBatchUpdates:^{
            [self insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedContacts.count inSection:0]]];
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
        ContactCollectionViewCellModel *model = (ContactCollectionViewCellModel *)self.selectedContacts[index];
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

- (void)scrollToEntry
{
    [self scrollToEntryAnimated:YES];
}

- (void)scrollToEntryAnimated:(BOOL)animated
{
    [self scrollToItemAtIndexPath:[self entryCellIndexPath]
                 atScrollPosition:UICollectionViewScrollPositionBottom
                         animated:animated];
}

- (NSArray*)contactsSelected
{
    return self.selectedContacts;
}

@end
