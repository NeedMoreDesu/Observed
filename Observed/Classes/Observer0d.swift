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

    func subscribe<TargetObjectType, TargetObserverType>(_ observed: Observed<TargetObjectType, TargetObserverType>) {
        self.fullUpdate.subscribe { [weak observed] () -> DeleteOrKeep in
            guard let observed = observed else {
                return .delete
            }
            Resetable.downgradeReset0d(obj: observed.obj)
            if let observer = observed.observer as? Observer0d {
                observer.fullUpdate.update()
            }
            return .keep
        }
    }
}



extension Observed {
    public func map<ReturnType>(_ transform: @escaping (ObjectType) -> ReturnType) -> Observed<LazyTransform<ReturnType>, Observer0d> {
        let outputObj = LazyTransform { return transform(self.obj) }
        let observed = Observed<LazyTransform<ReturnType>, Observer0d>(obj: outputObj, observer: Observer0d())
        self.observer.subscribe(observed)
//        observed.subscribeTo(self.observer)
        return observed
    }
}

extension Observed where ObserverType == Observer0d {
    public func subscribeTo<TargetObserverType>(_ observer: TargetObserverType) {
        switch(observer) {
        case is Observer1d:
            self.subscribeTo(observer as! Observer1d)
        default:
            self.subscribeTo(observer as! Observer0d)
        }
    }
    
    public func subscribeTo(_ observer: Observer0d) {
        observer.fullUpdate.subscribe { [weak self] () -> DeleteOrKeep in
            guard let `self` = self else {
                return .delete
            }
            (self.obj as? Resetable0d)?.reset()
            self.observer.fullUpdate.update()
            return .keep
        }
    }

    public func subscribeTo(_ observer: Observer1d) {
        observer.changes.subscribe { [weak self] (_, _, _) -> DeleteOrKeep in
            guard let `self` = self else {
                return .delete
            }
            (self.obj as? Resetable0d)?.reset()
            self.observer.fullUpdate.update()
            return .keep
        }
        observer.fullUpdate.subscribe { [weak self] () -> DeleteOrKeep in
            guard let `self` = self else {
                return .delete
            }
            (self.obj as? Resetable0d)?.reset()
            self.observer.fullUpdate.update()
            return .keep
        }
    }

//    public func subscribeTo<TargetObjectType>(_ observed: Observed<TargetObjectType, Observer2d>) {
//        observed.observer.changes.subscribe { [weak self] (_, _, _, _, _, _) -> DeleteOrKeep in
//            guard let `self` = self else {
//                return .delete
//            }
//            self.observer.fullUpdate.update()
//            return .keep
//        }
//        observed.observer.fullUpdate.subscribe { [weak self] () -> DeleteOrKeep in
//            guard let `self` = self else {
//                return .delete
//            }
//            self.observer.fullUpdate.update()
//            return .keep
//        }
//    }
}

