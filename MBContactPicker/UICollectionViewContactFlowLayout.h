//
//  UICollectionViewContactFlowLayout.h
//  MBContactPicker
//
//  Created by Matt Bowman on 12/1/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UICollectionViewDelegateContactFlowLayout <UICollectionViewDelegateFlowLayout>

- (void)collectionView:(UICollectionView*)collectionView willChangeContentSizeFrom:(CGSize)currentSize to:(CGSize)newSize;

@end

@interface UICollectionViewContactFlowLayout : UICollectionViewFlowLayout

@end
