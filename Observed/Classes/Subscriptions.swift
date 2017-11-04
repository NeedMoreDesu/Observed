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

public struct Index2d {
    let row: Int
    let section: Int
}

public class Subscription0d {
    public typealias Fn = () -> DeleteOrKeep
    private var fns = MutableArrayReference<Fn>()
    weak var objectToReset: AnyObject!

    public func update() {
        fns.array = fns.array.filter { (fn) -> Bool in
            return fn() == .keep
        }
    }
    public func subscribe(_ fn: @escaping Fn) {
        var resultFn = fn
        if let resetFn = Resetable.downgradeReset0d(obj: self.objectToReset) {
            resultFn = { () -> DeleteOrKeep in
                let _ = resetFn()
                return fn()
            }
        }
        self.fns.array.append(resultFn)
    }
}

public class Subscription1d {
    public typealias Fn = (_ deletions: [Int], _ insertions: [Int], _ updates: [Int]) -> DeleteOrKeep
    private var fns = MutableArrayReference<Fn>()
    weak var objectToReset: AnyObject!
    
    public func update(deletions: [Int], insertions: [Int], updates: [Int]) {
        fns.array = fns.array.filter { (fn) -> Bool in
            return fn(deletions, insertions, updates) == .keep
        }
    }
    public func subscribe(_ fn: @escaping Fn) {
        var resultFn = fn
        if let resetFn = Resetable.downgradeReset1d(obj: self.objectToReset) {
            resultFn = { deletions, insertions, updates -> DeleteOrKeep in
                let _ = resetFn(deletions, insertions, updates)
                return fn(deletions, insertions, updates)
            }
        }
        self.fns.array.append(resultFn)
    }
}

public class Subscription2d {
    public typealias Fn = (_ deletions: [Index2d], _ insertions: [Index2d], _ updates: [Index2d], _ sectionDeletions: [Int], _ sectionInsertions: [Int], _ sectionUpdates: [Int]) -> DeleteOrKeep
    private var fns = MutableArrayReference<Fn>()
    weak var objectToReset: AnyObject!
    
    public func update(deletions: [Index2d], insertions: [Index2d], updates: [Index2d], sectionDeletions: [Int], sectionInsertions: [Int], sectionUpdates: [Int]) {
        fns.array = fns.array.filter { (fn) -> Bool in
            return fn(deletions, insertions, updates, sectionDeletions, sectionInsertions, sectionUpdates) == .keep
        }
    }
    public func subscribe(_ fn: @escaping Fn) {
        var resultFn = fn
        if let resetFn = Resetable.downgradeReset2d(obj: self.objectToReset) {
            resultFn = { deletions, insertions, updates, sectionDeletions, sectionInsertions, sectionUpdates -> DeleteOrKeep in
                let _ = resetFn(deletions, insertions, updates, sectionDeletions, sectionInsertions, sectionUpdates)
                return fn(deletions, insertions, updates, sectionDeletions, sectionInsertions, sectionUpdates)
            }
        }
        self.fns.array.append(resultFn)
    }
}
