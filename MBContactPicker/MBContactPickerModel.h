//
//  MBContactPickerModel.h
//  MBContactPicker
//
//  Created by Matt Bowman on 12/12/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#ifndef MBContactPicker_MBContactPickerModel_h
#define MBContactPicker_MBContactPickerModel_h

@protocol MBContactPickerModelProtocol <NSObject>

@required

@property (nonatomic, copy) NSString *contactTitle;

@optional

@property (nonatomic, copy) NSString *contactSubtitle;
@property (nonatomic) UIImage *contactImage;

@end

#endif
