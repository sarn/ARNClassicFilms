//
//  ARNCollectionViewFocusGuideFlowLayout.m
//  classicFilms
//
//  Created by Stefan Arn on 11/03/16.
//  Copyright © 2016 Stefan Arn. All rights reserved.
//

#import "ARNCollectionViewFocusGuideFlowLayout.h"
#import "ARNFocusGuideSupplementaryView.h"

NSString * const ARNCollectionElementKindFocusGuide = @"ARNCollectionElementKindFocusGuide";

@interface ARNCollectionViewFocusGuideFlowLayout ()
    @property (nonatomic, strong) NSMutableArray *supplementaryViewAttributeList;
@end

@implementation ARNCollectionViewFocusGuideFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.supplementaryViewAttributeList = [NSMutableArray array];
    if(self.collectionView != nil) {
        // calculate layout values
        CGFloat contentWidth = self.collectionViewContentSize.width - self.sectionInset.left - self.sectionInset.right;
        CGFloat cellSizeWithSpacing = self.itemSize.width + self.minimumInteritemSpacing;
        NSInteger numberOfItemsPerLine = floor(contentWidth / cellSizeWithSpacing);
        CGFloat realInterItemSpacing = (contentWidth - (numberOfItemsPerLine * self.itemSize.width)) / (numberOfItemsPerLine - 1);
        
        // add supplementary attributes
        for (NSInteger numberOfSection = 0; numberOfSection < self.collectionView.numberOfSections; numberOfSection++) {
            NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:numberOfSection];
            NSInteger numberOfSupplementaryViews = numberOfItemsPerLine - (numberOfItems % numberOfItemsPerLine);
            
            if (numberOfSupplementaryViews > 0 && numberOfSupplementaryViews < 6) {
                NSIndexPath *indexPathOfLastCellOfSection = [NSIndexPath indexPathForItem:(numberOfItems - 1) inSection:numberOfSection];
                UICollectionViewLayoutAttributes *layoutAttributesOfLastCellOfSection = [self layoutAttributesForItemAtIndexPath:indexPathOfLastCellOfSection];
                
                for (NSInteger numberOfSupplementor = 0; numberOfSupplementor < numberOfSupplementaryViews; numberOfSupplementor++) {
                    NSIndexPath *indexPathOfSupplementor = [NSIndexPath indexPathForItem:(numberOfItems + numberOfSupplementor) inSection:numberOfSection];
                    UICollectionViewLayoutAttributes *supplementaryLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:ARNCollectionElementKindFocusGuide withIndexPath:indexPathOfSupplementor];
                    supplementaryLayoutAttributes.frame = CGRectMake(layoutAttributesOfLastCellOfSection.frame.origin.x + ((numberOfSupplementor + 1) * (self.itemSize.width + realInterItemSpacing)), layoutAttributesOfLastCellOfSection.frame.origin.y, self.itemSize.width, self.itemSize.height);
                    supplementaryLayoutAttributes.zIndex = -1;

                    [self.supplementaryViewAttributeList addObject:supplementaryLayoutAttributes];
                }
            }
        }
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *enrichedLayoutAttributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];

    for (UICollectionViewLayoutAttributes *supplementaryLayoutAttributes in self.supplementaryViewAttributeList) {
        if (CGRectIntersectsRect(rect, supplementaryLayoutAttributes.frame)) {
            [enrichedLayoutAttributes addObject:supplementaryLayoutAttributes];
        }
    }
    
    return enrichedLayoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *layoutAttributes = nil;
    
    if ([elementKind isEqualToString:ARNCollectionElementKindFocusGuide]) {
        for (UICollectionViewLayoutAttributes *supplementaryLayoutAttributes in self.supplementaryViewAttributeList) {
            if ([indexPath isEqual:supplementaryLayoutAttributes.indexPath]) {
                layoutAttributes = supplementaryLayoutAttributes;
            }
        }
        
        // create dummy layoutAttributes for
        // views that are not longer part of the layout
        if (layoutAttributes == nil) {
            UICollectionViewLayoutAttributes *dummyLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
            dummyLayoutAttributes.frame = CGRectZero;
            dummyLayoutAttributes.size = CGSizeZero;
            dummyLayoutAttributes.hidden = YES;
            layoutAttributes = dummyLayoutAttributes;
        }
    } else {
        layoutAttributes = [super layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
    }

    return layoutAttributes;
}

@end
