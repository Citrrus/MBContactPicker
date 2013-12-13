//
//  ContactObject.h
//  MBContactPicker
//
//  Created by Matt Bowman on 12/12/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBContactPickerModel.h"

@interface ContactObject : NSObject <MBContactPickerModelProtocol>

@property (nonatomic, copy) NSString *contactTitle;
@property (nonatomic, copy) NSString *contactSubtitle;

@end
