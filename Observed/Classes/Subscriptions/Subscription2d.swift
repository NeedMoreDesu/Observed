//
//  Subscriptions.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/17.
//

import Foundation

public class Subscription2d {
    public typealias Fn = (_ deletions: [Index2d], _ insertions: [Index2d], _ updates: [Index2d], _ sectionDeletions: [Int], _ sectionInsertions: [Int]) -> DeleteOrKeep
    private var fns = MutableArrayReference<Fn>()
    weak var objectToReset: AnyObject!
    
    public func update(deletions: [Index2d], insertions: [Index2d], updates: [Index2d], sectionDeletions: [Int], sectionInsertions: [Int]) {
        fns.array = fns.array.filter { (fn) -> Bool in
            return fn(deletions, insertions, updates, sectionDeletions, sectionInsertions) == .keep
        }
    }
    public func subscribe(_ fn: @escaping Fn) {
        var resultFn = fn
        if let resetFn = Resetable.downgradeReset2d(obj: self.objectToReset) {
            resultFn = { deletions, insertions, updates, sectionDeletions, sectionInsertions -> DeleteOrKeep in
                let _ = resetFn(deletions, insertions, updates, sectionDeletions, sectionInsertions)
                return fn(deletions, insertions, updates, sectionDeletions, sectionInsertions)
            }
        }
        self.fns.array.append(resultFn)
    }
}
