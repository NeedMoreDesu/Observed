//
//  SubscriptionRelated.swift
//  Observed
//
//  Created by Oleksii Horishnii on 11/7/17.
//

import Foundation

class MutableArrayReference<Type> {
    var array = [Type]()
}

public enum DeleteOrKeep {
    case delete
    case keep
}

public struct Index2d {
    let row: Int
    let section: Int
    func toIndexPath() -> NSIndexPath {
        return NSIndexPath(row: self.row, section: self.section)
    }
}

extension IndexPath {
    func toIndex2d() -> Index2d {
        return Index2d(row: self.row, section: self.section)
    }
}
