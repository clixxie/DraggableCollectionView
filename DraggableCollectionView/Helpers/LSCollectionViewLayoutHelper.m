//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/DraggableCollectionView
//  Distributed under MIT license
//

#import "LSCollectionViewLayoutHelper.h"

@interface LSCollectionViewLayoutHelper ()

@end

@implementation LSCollectionViewLayoutHelper

- (id)initWithCollectionViewLayout:(UICollectionViewLayout<UICollectionViewLayout_Warpable>*)collectionViewLayout
{
    self = [super init];
    if (self) {
        _collectionViewLayout = collectionViewLayout;
        _isSinglePage = NO;
    }
    return self;
}

- (NSArray *)modifiedLayoutAttributesForElements:(NSArray *)elements
{
    UICollectionView *collectionView = self.collectionViewLayout.collectionView;
    NSIndexPath *fromIndexPath = self.fromIndexPath;
    NSIndexPath *toIndexPath = self.toIndexPath; // Will be either equal fromIndexPath or toIndexPath
    NSIndexPath *hideIndexPath = self.hideIndexPath;
    NSIndexPath *indexPathToRemove;
    
    
    //NSLog(@"From: %@ To: %@ Hide %@",fromIndexPath,toIndexPath,hideIndexPath);
    
    if (toIndexPath == nil) {
        if (hideIndexPath == nil) { // No touch action in progess -> nothing modified
            return elements;
        }
        //Started dragging - >  Hide cell at hideIndexPaht == fromIndexPath
        //A mock cell (image) will be displayed
        for (UICollectionViewLayoutAttributes *layoutAttributes in elements) {
            if(layoutAttributes.representedElementCategory != UICollectionElementCategoryCell) {
                continue;
            }
            if ([layoutAttributes.indexPath isEqual:hideIndexPath]) {
                layoutAttributes.hidden = YES;
            }
            else {
                layoutAttributes.hidden = NO;
            }
        }
        
        [self rearrangeIndexPathOfLayoutAttributesForElements:elements];
        
        return elements;
    }
    
    [self rearrangeIndexPathOfLayoutAttributesForElements:elements];
    
    if (fromIndexPath.section != toIndexPath.section) {
        indexPathToRemove = [NSIndexPath indexPathForItem:[collectionView numberOfItemsInSection:fromIndexPath.section] - 1
                                                inSection:fromIndexPath.section];
    }
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in elements) {
        if(layoutAttributes.representedElementCategory != UICollectionElementCategoryCell) {
            continue;
        }
        if([layoutAttributes.indexPath isEqual:indexPathToRemove]) {
            // Remove item in source section and insert item in target section
            NSInteger section  = toIndexPath.section;
            NSInteger row  = toIndexPath.row;
            layoutAttributes.indexPath = [NSIndexPath indexPathForItem:[collectionView numberOfItemsInSection:toIndexPath.section] - 1
                                                             inSection:toIndexPath.section];
            section = layoutAttributes.indexPath.section;
            row  = layoutAttributes.indexPath.row;
            
            if (layoutAttributes.indexPath.item != 0) {
                layoutAttributes.center = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:layoutAttributes.indexPath].center;
            }
        }
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        if ([indexPath isEqual:hideIndexPath]) {
            layoutAttributes.hidden = YES;
        }
        else {
            layoutAttributes.hidden = NO;
        }
        if([indexPath isEqual:toIndexPath]) {
            // Item's new location
            layoutAttributes.indexPath = fromIndexPath;
        }
        else if(fromIndexPath.section != toIndexPath.section) {
            if(indexPath.section == fromIndexPath.section && indexPath.item >= fromIndexPath.item) {
                // Change indexes in source section
                layoutAttributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
            }
            else if(indexPath.section == toIndexPath.section && indexPath.item >= toIndexPath.item) {
                // Change indexes in destination section
                layoutAttributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
            }
            
        } else if(indexPath.section == fromIndexPath.section) { // For the same secton
            if(indexPath.item <= fromIndexPath.item && indexPath.item > toIndexPath.item) {  // Item moved back
                if (self.isSinglePage || indexPath.item == 3 ) {
                    if (indexPath.item % 2 == 1) {
                        layoutAttributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item - 2 inSection:indexPath.section];
                    }
                } else {
                     layoutAttributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
                }
            } else if(indexPath.item >= fromIndexPath.item && indexPath.item < toIndexPath.item) { // Item moved forward
                
                if (self.isSinglePage || indexPath.item == 1) {
                    if (indexPath.item % 2 == 1) {
                        layoutAttributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item + 2 inSection:indexPath.section];
                    }
                } else {
                    if (indexPath.item  != 2) {
                        layoutAttributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
                    }
                }

                
            }
        }
    }
    
    return elements;
}

- (void)rearrangeIndexPathOfLayoutAttributesForElements:(NSArray *)elements
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
    {
        NSComparator cmptr = ^(NSIndexPath *ele1, NSIndexPath *ele2){
            
            if (ele1.section < ele2.section)
                return (NSComparisonResult)NSOrderedAscending;
            
            if (ele1.row < ele2.row)
                return (NSComparisonResult)NSOrderedAscending;
            
            return (NSComparisonResult)NSOrderedDescending;
        };
        
        NSMutableArray *indexPathArray = [NSMutableArray array];
        
        for (UICollectionViewLayoutAttributes *layoutAttributes in elements) {
            
            if([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]
               || [layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionFooter])
            {
                continue;
            }
            
            [indexPathArray addObject:layoutAttributes.indexPath];
        }
        
        NSArray *sortedArray = [[NSArray arrayWithArray:indexPathArray] sortedArrayUsingComparator:cmptr];
        
        for (NSInteger index = 0; index < sortedArray.count; ++index) {
            ((UICollectionViewLayoutAttributes*)[elements objectAtIndex:index]).indexPath = (NSIndexPath *)[sortedArray objectAtIndex:index];
        }
    }
}

@end
