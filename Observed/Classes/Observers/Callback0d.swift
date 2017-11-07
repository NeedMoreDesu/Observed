//
//  Callbacks.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/17.
//

import Foundation
import LazySeq

public typealias Observed0d<Type> = Observed<GeneratedTransform<Type>, Callback0d>

public class Callback0d {
    public let fullUpdate = Subscription0d()
    public required init() {}

    func setObjectToReset(_ objectToReset: AnyObject) {
        self.fullUpdate.objectToReset = objectToReset
    }

    func subscribe<TargetObjectType, TargetCallbackType>(_ observed: Observed<TargetObjectType, TargetCallbackType>) {
        self.fullUpdate.subscribe { [weak observed] () -> DeleteOrKeep in
            guard let observed = observed else {
                return .delete
            }
            let _ = Resetable.downgradeReset0d(obj: observed.obj as AnyObject)?()
            observed.callback.fullUpdate.update()
            return .keep
        }
    }
}

extension Observed {
    public func map0d<ReturnType>(_ transform: @escaping (ObjectType) -> ReturnType) -> Observed0d<ReturnType> {
        let outputObj = LazyTransform { return transform(self.obj) }
        let observed = Observed0d<ReturnType>(obj: outputObj)
        self.callback.subscribe(observed)
        return observed
    }
    
    public func map0dWithoutStorage<ReturnType>(_ transform: @escaping (ObjectType) -> ReturnType) -> Observed0d<ReturnType> {
        let outputObj = GeneratedTransform { return transform(self.obj) }
        let observed = Observed0d<ReturnType>(obj: outputObj)
        self.callback.subscribe(observed)
        return observed
    }
}

extension Observed where CallbackType == Callback0d {
    
}

