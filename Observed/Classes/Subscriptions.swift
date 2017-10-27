//
//  Subscriptions.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/17.
//

import Foundation

class MutableArrayReference<Type> {
    var array = [Type]()
}

public enum DeleteOrKeep {
    case delete
    case keep
}

public class SubscriptionBasic {
    public typealias Fn = () -> DeleteOrKeep
    private var fns = MutableArrayReference<Fn>()

    public func update() {
        fns.array = fns.array.filter { (fn) -> Bool in
            return fn() == .keep
        }
    }
    public func subscribe(_ fn: @escaping Fn) {
        self.fns.array.append(fn)
    }
}

public class Subscription1d {
    public typealias Fn = (_ deletions: [Int], _ insertions: [Int], _ updates: [Int]) -> DeleteOrKeep
    private var fns = MutableArrayReference<Fn>()
    
    public func update(deletions: [Int], insertions: [Int], updates: [Int]) {
        fns.array = fns.array.filter { (fn) -> Bool in
            return fn(deletions, insertions, updates) == .keep
        }
    }
    public func subscribe(_ fn: @escaping Fn) {
        self.fns.array.append(fn)
    }
}

public class Subscription2d {
    public struct Index {
        let row: Int
        let column: Int
    }
    public typealias Fn = (_ deletions: [Index], _ insertions: [Index], _ updates: [Index], _ sectionDeletions: [Int], _ sectionInsertions: [Int]) -> DeleteOrKeep
    private var fns = MutableArrayReference<Fn>()
    
    public func update(deletions: [Index], insertions: [Index], updates: [Index], sectionDeletions: [Int], sectionInsertions: [Int]) {
        fns.array = fns.array.filter { (fn) -> Bool in
            return fn(deletions, insertions, updates, sectionDeletions, sectionInsertions) == .keep
        }
    }
    public func subscribe(_ fn: @escaping Fn) {
        self.fns.array.append(fn)
    }
}
