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
        let _ = Resetable.downgradeReset2d(obj: self.objectToReset)?(deletions, insertions, updates, sectionDeletions, sectionInsertions)
        fns.array = fns.array.filter { (fn) -> Bool in
            return fn(deletions, insertions, updates, sectionDeletions, sectionInsertions) == .keep
        }
    }
    public func subscribe(_ fn: @escaping Fn) {
        self.fns.array.append(fn)
    }
}
