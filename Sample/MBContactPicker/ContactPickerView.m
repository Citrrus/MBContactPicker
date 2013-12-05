//
//  ContactPickerView.m
//  MBContactPicker
//
//  Created by Matt Bowman on 12/2/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "ContactPickerView.h"
#import "ContactCollectionView.h"

@interface ContactPickerView()

@property (nonatomic, weak) ContactCollectionView *collectionView;
@property (nonatomic, weak) UITableView *searchTableView;
@property (nonatomic) NSArray *filteredContacts;
@property (nonatomic) NSArray *contacts;
@property (nonatomic) ContactCollectionViewPromptCell *promptCell;
@property (nonatomic) ContactEntryCollectionViewCell *entryCell;
@property (nonatomic) ContactCollectionViewCell *prototypeCell;

@property NSInteger selectedIndex;
@property CGFloat originalHeight;
@property CGFloat originalYOffset;


@end


@implementation ContactPickerView

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.selectedIndex = -1;
    self.originalHeight = -1;
    self.originalYOffset = -1;
    
    UICollectionViewContactFlowLayout *layout = [[UICollectionViewContactFlowLayout alloc] init];
    ContactCollectionView *contactCollectionView = [[ContactCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    contactCollectionView.layer.borderColor = [UIColor redColor].CGColor;
    contactCollectionView.layer.borderWidth = 0.0;
    contactCollectionView.delegate = self;
    contactCollectionView.dataSource = self;
    [self addSubview:contactCollectionView];
    [contactCollectionView registerClass:[ContactCollectionViewCell class] forCellWithReuseIdentifier:@"ContactCell"];
    [contactCollectionView registerClass:[ContactEntryCollectionViewCell class] forCellWithReuseIdentifier:@"ContactEntryCell"];
    [contactCollectionView registerClass:[ContactCollectionViewPromptCell class] forCellWithReuseIdentifier:@"ContactPromptCell"];
    
    self.collectionView = contactCollectionView;
    
    self.prototypeCell = [[ContactCollectionViewCell alloc] init];

    UITableView *searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 0)];
    searchTableView.dataSource = self;
    searchTableView.delegate = self;
    searchTableView.layer.borderColor = [UIColor blueColor].CGColor;
    searchTableView.layer.borderWidth = 1.0;
    [searchTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self addSubview:searchTableView];
    
    searchTableView.translatesAutoresizingMaskIntoConstraints = NO;
    contactCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contactCollectionView(>=31,<=63)][searchTableView(>=0)]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(contactCollectionView, searchTableView)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contactCollectionView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(contactCollectionView)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchTableView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(searchTableView)]];
    self.searchTableView = searchTableView;
    
}

- (void)reloadData
{
    self.contacts = [self.contactDataSource contactModelsForCollectionView:self.collectionView];
}

#pragma mark - Properties

- (NSArray*)contactsSelected
{
    return self.collectionView.contactsSelected;
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
    return self.collectionView.contactsSelected.count + 2;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *collectionCell;
    
    if ([self.collectionView isPromptCell:indexPath])
    {
        ContactCollectionViewPromptCell *cell = (ContactCollectionViewPromptCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactPromptCell" forIndexPath:indexPath];
        NSString *prompt = @"To:";
        CGRect frame = [prompt boundingRectWithSize:(CGSize){ .width = CGFLOAT_MAX, .height = CGFLOAT_MAX }
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:nil
                                            context:nil];
        cell.frame = (CGRect) { .size.width = ceilf(frame.size.width) + 10, .size.height = 31, .origin.x = 0, .origin.y = 0 };
        cell.layer.borderWidth = 1.0;
        cell.layer.borderColor = [UIColor purpleColor].CGColor;
        UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
        [cell addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = prompt;
        label.textColor = [UIColor blackColor];
        collectionCell = cell;
        self.promptCell = cell;
    }
    else if ([self.collectionView isEntryCell:indexPath])
    {
        ContactEntryCollectionViewCell *cell = (ContactEntryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactEntryCell"
                                                                                                                           forIndexPath:indexPath];
        cell.delegate = self;
        collectionCell = cell;
        if (self.collectionView.indexPathOfSelectedCell)
        {
            [cell setFocus];
        }
        self.entryCell = cell;
        
    }
    else
    {
        ContactCollectionViewCell *cell = (ContactCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactCell"
                                                                                                                forIndexPath:indexPath];
        cell.model = self.collectionView.contactsSelected[[self.collectionView selectedContactIndexFromIndexPath:indexPath]];
        if ([self.collectionView.indexPathOfSelectedCell isEqual:indexPath])
        {
            cell.focused = YES;
        }
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
    
    if ([self.contactDelegate respondsToSelector:@selector(didSelectContact:inContactCollectionView:)])
    {
        [self.contactDelegate didSelectContact:cell.model inContactCollectionView:self.collectionView];
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
        NSString *prompt = @"To:";
        CGRect frame = [prompt boundingRectWithSize:(CGSize){ .width = CGFLOAT_MAX, .height = CGFLOAT_MAX }
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:nil
                                            context:nil];
        CGRect x = (CGRect) { .size.width = frame.size.width + 10, .size.height = 30, .origin.x = 0, .origin.y = 0 };
        return CGSizeMake(ceilf(x.size.width), 31);
    }
    else if ([self.collectionView isEntryCell:indexPath])
    {
        ContactEntryCollectionViewCell *prototype = self.entryCell;
        if (!prototype)
        {
            prototype = [[ContactEntryCollectionViewCell alloc] init];
        }
        CGSize cellSize = CGSizeMake([prototype widthForText:prototype.text], 31);
        return cellSize;
    }
    else
    {
        ContactCollectionViewCellModel *model = self.contactsSelected[[self.collectionView selectedContactIndexFromIndexPath:indexPath]];
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
        if (self.collectionView.contactsSelected.count > 0)
        {
            [textField resignFirstResponder];
            NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForItem:self.contactsSelected.count
                                                                    inSection:0];
            [self.collectionView selectItemAtIndexPath:newSelectedIndexPath
                                              animated:YES
                                        scrollPosition:UICollectionViewScrollPositionBottom];
            [self.collectionView.delegate collectionView:self.collectionView didSelectItemAtIndexPath:newSelectedIndexPath];
            [self becomeFirstResponder];
        }
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{

    [self.collectionView performBatchUpdates:^{
        [self.collectionView.collectionViewLayout invalidateLayout];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = ((ContactCollectionViewCellModel*)self.filteredContacts[indexPath.row]).contactTitle;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCollectionViewCellModel *model = self.filteredContacts[indexPath.row];
    [self.entryCell reset];
    [self.collectionView addToSelectedContacts:model];
    [self hideSearchTableView];
    [self.collectionView scrollToEntry];
    [self.entryCell setFocus];
}

#pragma mark Helper Methods

- (void)showSearchTableView
{
    if ([self.delegate respondsToSelector:@selector(showFilteredContacts)])
    {
        [self.delegate showFilteredContacts];
    }
}

- (void)hideSearchTableView
{
    if ([self.delegate respondsToSelector:@selector(hideFilteredContacts)])
    {
        [self.delegate hideFilteredContacts];
    }
}

@end
