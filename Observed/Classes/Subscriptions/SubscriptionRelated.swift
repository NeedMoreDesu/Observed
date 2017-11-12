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
    public let section: Int
    public let row: Int
    public init(section: Int, row: Int) {
        self.section = section
        self.row = row
    }
    public func toIndexPath() -> NSIndexPath {
        return NSIndexPath(row: self.row, section: self.section)
    }
}

extension IndexPath {
    public func toIndex2d() -> Index2d {
        return Index2d(section: self.section, row: self.row)
    }
}
