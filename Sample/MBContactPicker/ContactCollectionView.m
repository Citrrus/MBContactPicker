//
//  ContactCollectionView.m
//  MBContactPicker
//
//  Created by Matt Bowman on 11/20/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "ContactCollectionView.h"

@interface ContactCollectionView()

@property (nonatomic) ContactCollectionViewCell *prototypeCell;
@property (nonatomic) NSArray *contacts;
@property (nonatomic) NSMutableArray *selectedContacts;

@end

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
    self.prototypeCell = [[ContactCollectionViewCell alloc] init];
    self.delegate = self;
    self.dataSource = self;
    [self registerClass:[ContactCollectionViewCell class] forCellWithReuseIdentifier:@"ContactCell"];
}

- (void)reloadData
{
    self.contacts = [self.contactDataSource contactModelsInCollectionView:self];
    [super reloadData];
}

#pragma mark - CollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.contacts count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCollectionViewCell *cell = (ContactCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"ContactCell" forIndexPath:indexPath];
    cell.model = self.contacts[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCollectionViewCell *cell = (ContactCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.focused = YES;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.prototypeCell sizeForCellWithContact:(ContactCollectionViewCellModel*)self.contacts[indexPath.row]];
}

@end
