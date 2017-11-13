//
//  Subscriptions.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/17.
//

import Foundation

public class Subscription1d {
    public typealias Fn = (_ deletions: [Int], _ insertions: [Int], _ updates: [Int]) -> DeleteOrKeep
    private var fns = MutableArrayReference<Fn>()
    weak var objectToReset: AnyObject!
    
    public func update(deletions: [Int], insertions: [Int], updates: [Int]) {
        let _ = Resetable.downgradeReset1d(obj: self.objectToReset)?(deletions, insertions, updates)
        fns.array = fns.array.filter { (fn) -> Bool in
            return fn(deletions, insertions, updates) == .keep
        }
    }
    public func subscribe(_ fn: @escaping Fn) {
        self.fns.array.append(fn)
    }
}

