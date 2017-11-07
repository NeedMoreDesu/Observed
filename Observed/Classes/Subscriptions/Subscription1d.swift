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

