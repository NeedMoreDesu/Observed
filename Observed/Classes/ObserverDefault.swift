//
//  Observers.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/17.
//

import Foundation

public class ObserverDefault {
    public let fullUpdate = SubscriptionBasic()
    public init() {}
//
//    func subscribe<TargetObjectType, TargetObserverType>(_ observed: Observed<TargetObjectType, TargetObserverType>) {
//        self.fullUpdate.subscribe { [weak observed] () -> DeleteOrKeep in
//            guard let observed = observed else {
//                return .delete
//            }
//            observed.observer.fullUpdate.update()
//            return .keep
//        }
//    }
}



extension Observed {
    public func map<ReturnType>(_ transform: (ObjectType) -> ReturnType) -> Observed<ReturnType, ObserverDefault> {
        let outputObj = transform(self.obj)
        let observed = Observed<ReturnType, ObserverDefault>(obj: outputObj, observer: ObserverDefault())
        observed.subscribeTo(self.observer)
        return observed
    }
}

extension Observed where ObserverType == ObserverDefault {
    public func subscribeTo<TargetObserverType>(_ observer: TargetObserverType) {
        switch(observer) {
        case is Observer1d:
            self.subscribeTo(observer as! Observer1d)
        default:
            self.subscribeTo(observer as! ObserverDefault)
        }
    }
    
    public func subscribeTo(_ observer: ObserverDefault) {
        observer.fullUpdate.subscribe { [weak self] () -> DeleteOrKeep in
            guard let `self` = self else {
                return .delete
            }
            self.observer.fullUpdate.update()
            return .keep
        }
    }

    public func subscribeTo(_ observer: Observer1d) {
        observer.changes.subscribe { [weak self] (_, _, _) -> DeleteOrKeep in
            guard let `self` = self else {
                return .delete
            }
            self.observer.fullUpdate.update()
            return .keep
        }
        observer.fullUpdate.subscribe { [weak self] () -> DeleteOrKeep in
            guard let `self` = self else {
                return .delete
            }
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

