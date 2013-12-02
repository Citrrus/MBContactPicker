//
//  ViewController.m
//  MBContactPicker
//
//  Created by Matt Bowman on 11/20/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "ViewController.h"
#import "ContactCollectionViewCellModel.h"
#import "ContactCollectionView.h"

@interface ViewController () <ContactCollectionViewDataSource, ContactCollectionViewDelegate>

@property NSArray *objects;
@property (weak, nonatomic) IBOutlet ContactCollectionView *contactCollectionView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.objects = @[
                     @"Bryan Reed",
                     @"Matt Bowman",
                     @"Matt Hupman",
                     @"Erica Stein",
                     @"Erin Pfiffner",
                     @"Ben McGinnis",
                     @"Lenny Pham",
                     @"Jason LaFollette",
                     @"A", @"B", @"C", @"D",
                     @"Caleb Everist",
                     @"Kinda long name for a kinda long",
                     @"Super long name for a super long person with a long name"
                     ];
    
    self.contactCollectionView.contactDelegate = self;
    self.contactCollectionView.contactDataSource = self;
}


#pragma mark - ContactCollectionViewDataSource

- (NSInteger)numberOfContactsInCollectionView:(ContactCollectionView*)collectionView
{
    return self.objects.count;
}

- (NSArray*)contactModelsForCollectionView:(ContactCollectionView*)collectionView
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.objects.count];
    for (NSString *contact in self.objects)
    {
        ContactCollectionViewCellModel *model = [[ContactCollectionViewCellModel alloc] init];
        model.contactObject = nil;
        model.contactTitle = contact;
        [array addObject:model];
    }
    
    return array;
}

- (ContactCollectionViewCellModel *)contactModelForContactCollectionView:(ContactCollectionView*)collectionView atIndexPath:(NSIndexPath*)indexPath
{
    ContactCollectionViewCellModel *model = [[ContactCollectionViewCellModel alloc] init];
    model.contactObject = nil;
    model.contactTitle = self.objects[indexPath.row];
    return model;
}

#pragma mark - ContactCollectionViewDelegate

- (void)didSelectContact:(ContactCollectionViewCellModel*)model inContactCollectionView:(ContactCollectionView*)collectionView
{
    NSLog(@"Did Select: %@", model.contactTitle);
}

- (void)didAddContact:(ContactCollectionViewCellModel*)model toContactCollectionView:(ContactCollectionView*)collectionView
{
    NSLog(@"Did Add: %@", model.contactTitle);
}

- (void)didRemoveContact:(ContactCollectionViewCellModel*)model fromContactCollectionView:(ContactCollectionView*)collectionView
{
    NSLog(@"Did Remove: %@", model.contactTitle);
}


@end
