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
}
