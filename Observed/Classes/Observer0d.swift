//
//  Observers.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/17.
//

import Foundation

public class Observer0d {
    public let fullUpdate = Subscription0d()
    public init() {}

    func setObjectToReset(_ objectToReset: AnyObject) {
        self.fullUpdate.objectToReset = objectToReset
    }

    func subscribe<TargetObjectType, TargetObserverType>(_ observed: Observed<TargetObjectType, TargetObserverType>) {
        self.fullUpdate.subscribe { [weak observed] () -> DeleteOrKeep in
            guard let observed = observed else {
                return .delete
            }
            let _ = Resetable.downgradeReset0d(obj: observed.obj as AnyObject)?()
            observed.observer.fullUpdate.update()
            return .keep
        }
    }
}

extension Observed {
    public func map<ReturnType>(_ transform: @escaping (ObjectType) -> ReturnType) -> Observed<LazyTransform<ReturnType>, Observer0d> {
        let outputObj = LazyTransform { return transform(self.obj) }
        let observed = Observed<LazyTransform<ReturnType>, Observer0d>(obj: outputObj, observer: Observer0d())
        self.observer.subscribe(observed)
        return observed
    }
    
    public func mapWithoutStorage<ReturnType>(_ transform: @escaping (ObjectType) -> ReturnType) -> Observed<GeneratedTransform<ReturnType>, Observer0d> {
        let outputObj = GeneratedTransform { return transform(self.obj) }
        let observed = Observed<GeneratedTransform<ReturnType>, Observer0d>(obj: outputObj, observer: Observer0d())
        self.observer.subscribe(observed)
        return observed
    }
}

extension Observed where ObserverType == Observer0d {
    
}

