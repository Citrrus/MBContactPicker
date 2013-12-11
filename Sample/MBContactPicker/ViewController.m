//
//  ViewController.m
//  MBContactPicker
//
//  Created by Matt Bowman on 11/20/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "ViewController.h"
#import "MBContactPicker.h"

@interface ViewController () <MBContactPickerDataSource, MBContactPickerDelegate>

@property (nonatomic) NSArray *contacts;
@property (weak, nonatomic) IBOutlet MBContactPicker *contactPickerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contactPickerViewHeightConstraint;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *array = @[
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
    
	NSMutableArray *contacts = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSString *contact in array)
    {
        ContactCollectionViewCellModel *model = [[ContactCollectionViewCellModel alloc] init];
        model.contactObject = nil;
        model.contactTitle = contact;
        [contacts addObject:model];
    }
    self.contacts = contacts;
    
    self.contactPickerView.delegate = self;
    self.contactPickerView.datasource = self;
    [self.contactPickerView reloadData];
}

#pragma mark - ContactPickerDataSource

- (NSArray*)contactModelsForCollectionView:(ContactCollectionView*)collectionView
{
    return self.contacts;
}

#pragma mark - ContactPickerDelegate

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

// This delegate method is called to allow the parent view to increase the size of
// the contact picker view to show the search table view
- (void)showFilteredContacts
{
    if (self.contactPickerViewHeightConstraint.constant <= self.contactPickerView.currentContentHeight)
    {
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:.25 animations:^{
            CGRect pickerRectInWindow = [self.view convertRect:self.contactPickerView.frame fromView:nil];
            CGFloat newHeight = self.view.window.bounds.size.height - pickerRectInWindow.origin.y - self.contactPickerView.keyboardHeight;
            self.contactPickerViewHeightConstraint.constant = newHeight;
            [self.view layoutIfNeeded];
        }];
    }
}

// This delegate method is called to allow the parent view to decrease the size of
// the contact picker view to hide the search table view
- (void)hideFilteredContacts
{
    if (self.contactPickerViewHeightConstraint.constant > self.contactPickerView.currentContentHeight)
    {
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:.25 animations:^{
            self.contactPickerViewHeightConstraint.constant = self.contactPickerView.currentContentHeight;
            [self.view layoutIfNeeded];
        }];
    }
}

// This delegate method is invoked to allow the parent to increase the size of the
// collectionview that shows which contacts have been selected. To increase or decrease
// the number of rows visible, change the maxVisibleRows property of the MBContactPicker
- (void)updateViewHeightTo:(CGFloat)newHeight
{
    [UIView animateWithDuration:.25 animations:^{
        self.contactPickerViewHeightConstraint.constant = newHeight;
    }];
}

@end
