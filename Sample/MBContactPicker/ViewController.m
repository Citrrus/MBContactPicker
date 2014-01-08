//
//  ViewController.m
//  MBContactPicker
//
//  Created by Matt Bowman on 11/20/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "ViewController.h"
#import "ContactObject.h"
#import "MBContactPicker.h"

@interface ViewController () <MBContactPickerDataSource, MBContactPickerDelegate>

@property (nonatomic) NSArray *contacts;
@property (nonatomic) NSArray *selectedContacts;
@property (weak, nonatomic) IBOutlet MBContactPicker *contactPickerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contactPickerViewHeightConstraint;

@end

@implementation ViewController

- (IBAction)clearSelectedButtonTouchUpInside:(id)sender
{
    self.selectedContacts = @[];
    [self.contactPickerView reloadData];
}
- (IBAction)addContactsButtonTouchUpInside:(id)sender
{
    self.selectedContacts = @[
                              self.contacts[0],
                              self.contacts[1],
                              self.contacts[2],
                              self.contacts[3]
                              ];
    
    [self.contactPickerView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *array = @[
                       @{@"Name":@"Bryan Reed", @"Title":@"Software Developer"},
                       @{@"Name":@"Matt Bowman", @"Title":@"Software Developer"},
                       @{@"Name":@"Matt Hupman", @"Title":@"Software Developer"},
                       @{@"Name":@"Erica Stein", @"Title":@"Creative"},
                       @{@"Name":@"Erin Pfiffner", @"Title":@"Creative"},
                       @{@"Name":@"Ben McGinnis", @"Title":@"Project Manager"},
                       @{@"Name":@"Lenny Pham", @"Title":@"Product Manager"},
                       @{@"Name":@"Jason LaFollette", @"Title":@"Project Manager"},
                       @{@"Name":@"Caleb Everist", @"Title":@"Business Development"},
                       @{@"Name":@"Kinda long name for a kinda long", @"Title":@"Software Developer"},
                       @{@"Name":@"Super long name for a super long person with a long name", @"Title":@"Software Developer"}
                       ];
    
	NSMutableArray *contacts = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *contact in array)
    {
        MBContactModel *model = [[MBContactModel alloc] init];
        model.contactTitle = contact[@"Name"];
        model.contactSubtitle = contact[@"Title"];
        [contacts addObject:model];
    }
    self.contacts = contacts;

    self.contactPickerView.delegate = self;
    self.contactPickerView.datasource = self;
}

#pragma mark - MBContactPickerDataSource

- (NSArray *)contactModelsForContactPicker:(MBContactPicker*)contactPickerView
{
    return self.contacts;
}

- (NSArray *)selectedContactModelsForContactPicker:(MBContactPicker*)contactPickerView
{
    return self.selectedContacts;
}

#pragma mark - MBContactPickerDelegate

- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView didSelectContact:(id<MBContactPickerModelProtocol>)model
{
    NSLog(@"Did Select: %@", model.contactTitle);
}

- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView didAddContact:(id<MBContactPickerModelProtocol>)model
{
    NSLog(@"Did Add: %@", model.contactTitle);
}

- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView didRemoveContact:(id<MBContactPickerModelProtocol>)model
{
    NSLog(@"Did Remove: %@", model.contactTitle);
}

// This delegate method is called to allow the parent view to increase the size of
// the contact picker view to show the search table view
- (void)didShowFilteredContactsForContactPicker:(MBContactPicker*)contactPicker
{
    if (self.contactPickerViewHeightConstraint.constant <= contactPicker.currentContentHeight)
    {
        [UIView animateWithDuration:contactPicker.animationSpeed animations:^{
            CGRect pickerRectInWindow = [self.view convertRect:contactPicker.frame fromView:nil];
            CGFloat newHeight = self.view.window.bounds.size.height - pickerRectInWindow.origin.y - contactPicker.keyboardHeight;
            self.contactPickerViewHeightConstraint.constant = newHeight;
            [self.view layoutIfNeeded];
        }];
    }
}

// This delegate method is called to allow the parent view to decrease the size of
// the contact picker view to hide the search table view
- (void)didHideFilteredContactsForContactPicker:(MBContactPicker*)contactPicker
{
    if (self.contactPickerViewHeightConstraint.constant > contactPicker.currentContentHeight)
    {
        [UIView animateWithDuration:contactPicker.animationSpeed animations:^{
            self.contactPickerViewHeightConstraint.constant = contactPicker.currentContentHeight;
            [self.view layoutIfNeeded];
        }];
    }
}

// This delegate method is invoked to allow the parent to increase the size of the
// collectionview that shows which contacts have been selected. To increase or decrease
// the number of rows visible, change the maxVisibleRows property of the MBContactPicker
- (void)contactPicker:(MBContactPicker*)contactPicker didUpdateContentHeightTo:(CGFloat)newHeight
{
    self.contactPickerViewHeightConstraint.constant = newHeight;
    [UIView animateWithDuration:contactPicker.animationSpeed animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
