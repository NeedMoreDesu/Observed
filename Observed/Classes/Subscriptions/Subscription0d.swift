//
//  Subscriptions.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/17.
//

import Foundation

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
