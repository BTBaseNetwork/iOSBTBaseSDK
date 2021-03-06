//
//  UICollectionViewFullFlowLayout.swift
//  iDiaries
//
//  Created by AlexChow on 16/1/13.
//  Copyright © 2016年 GStudio. All rights reserved.
//

import Foundation
import UIKit

class UICollectionViewFullFlowLayout: UICollectionViewFlowLayout {
    var minimumSpacing: CGFloat = 7

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if var answer = super.layoutAttributesForElements(in: rect) {
            var lineContentWidth: CGFloat = 0
            var avgInterval: CGFloat = 0
            let cellWidth = collectionViewContentSize.width
            var lineItemCount = 0
            var lineStartIndex = 0
            for i in 1 ..< answer.count {
                let currentLayoutAttributes = answer[i]
                let prevLayoutAttributes = answer[i - 1]
                let origin = prevLayoutAttributes.frame.maxX
                lineItemCount += 1
                if origin + minimumSpacing + currentLayoutAttributes.frame.size.width < cellWidth {
                    var frame = currentLayoutAttributes.frame
                    frame.origin.x = origin + minimumSpacing
                    currentLayoutAttributes.frame = frame
                    lineContentWidth = frame.origin.x + frame.size.width

                } else {
                    avgInterval = (cellWidth - lineContentWidth) / CGFloat(lineItemCount)
                    for index in 0 ..< lineItemCount {
                        let realIndex = lineStartIndex + index
                        var frame = answer[realIndex].frame
                        frame.origin.x += avgInterval * CGFloat(index)
                        frame.size.width += avgInterval
                        answer[realIndex].frame = frame
                    }
                    lineItemCount = 0
                    lineStartIndex = i
                }
            }
            return answer
        }
        return nil
    }
}

class UICollectionViewMaxWhiteSpaceFlowLayout: UICollectionViewFlowLayout {
    var minimumSpacing: CGFloat = 7

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if var answer = super.layoutAttributesForElements(in: rect) {
            let cellWidth = collectionViewContentSize.width
            for i in 1 ..< answer.count {
                let currentLayoutAttributes = answer[i]
                let prevLayoutAttributes = answer[i - 1]
                let origin = prevLayoutAttributes.frame.maxX
                if origin + minimumSpacing + currentLayoutAttributes.frame.size.width < cellWidth {
                    var frame = currentLayoutAttributes.frame
                    frame.origin.x = origin + minimumSpacing
                    currentLayoutAttributes.frame = frame
                }
            }
            return answer
        }
        return nil
    }
}
