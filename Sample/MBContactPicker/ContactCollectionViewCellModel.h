//
//  ContactCollectionViewCellModel.h
//  MBContactPicker
//
//  Created by Matt Bowman on 11/20/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactCollectionViewCellModel : NSObject

@property (nonatomic, weak) id contactObject;
@property (nonatomic, copy) NSString *contactTitle;

@end
