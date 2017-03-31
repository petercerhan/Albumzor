//
//  ArtistCollectionViewLayout.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/29/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol ArtistCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForLabelAtIndexPath path: IndexPath) -> CGSize
}

class ArtistCollectionViewLayout: UICollectionViewLayout {

    var delegate: ArtistCollectionViewLayoutDelegate!

    private var cache = [UICollectionViewLayoutAttributes]()

    var cellSpacing: CGFloat = 10.0
    
    var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    
    override func prepare() {
        if cache.isEmpty {
            contentHeight = 0
            let maxRowWidth = contentWidth
            
            var item = 0
            
            while item < (collectionView!.numberOfItems(inSection: 0)) {

                var rowWidth: CGFloat = 0.0
                var rowCellsTotalWidth: CGFloat = 0.0
                var labelSizes = [(indexPath: IndexPath, size: CGSize)]()
                
                while rowWidth <= maxRowWidth {
                    let indexPath = IndexPath(item: item, section: 0)
                    let size = delegate.collectionView(collectionView!, sizeForLabelAtIndexPath: indexPath)
                    rowWidth = rowWidth + size.width + cellSpacing
                    
                    if rowWidth <= maxRowWidth {
                        rowCellsTotalWidth += size.width
                        labelSizes.append((indexPath, size))
                    } else {
                        break
                    }
                    
                    if item + 1 < (collectionView!.numberOfItems(inSection: 0)) {
                        item += 1
                    } else {
                        break
                    }
                }
                
                //All labels should have the same height but keep this for safety/flexibility
                var rowHeight: CGFloat = 0.0
                var x: CGFloat = (maxRowWidth - rowCellsTotalWidth - cellSpacing*CGFloat(labelSizes.count - 1)) / CGFloat(2.0)

                for labelSize in labelSizes {
                    rowHeight = max(rowHeight, labelSize.size.height)
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: labelSize.indexPath)
                    attributes.frame = CGRect(x: x, y: contentHeight, width: labelSize.size.width, height: labelSize.size.height)
                    cache.append(attributes)
                    
                    x = x + labelSize.size.width + cellSpacing
                }
                
                contentHeight = contentHeight + rowHeight + cellSpacing
                
                if item == collectionView!.numberOfItems(inSection: 0) - 1 {
                    item += 1
                }
            }
            
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    func clearCache() {
        cache = [UICollectionViewLayoutAttributes]()
    }
    
}
