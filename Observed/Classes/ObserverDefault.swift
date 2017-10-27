//
//  Observers.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/17.
//

import Foundation

public class ObserverDefault {
    public let fullUpdate = SubscriptionBasic()
    required public init() {}
}

extension Observed {
    public func map<ReturnType>(_ transform: (ObjectType) -> ReturnType) -> Observed<ReturnType, ObserverDefault> {
        let outputObj = transform(self.obj)
        let observed = Observed<ReturnType, ObserverDefault>(obj: outputObj, observer: ObserverDefault())
        return observed
    }
}

extension Observed where ObserverType == ObserverDefault {
    public func subscribeTo<TargetObjectType>(_ observed: Observed<TargetObjectType, ObserverDefault>) {
        observed.observer.fullUpdate.subscribe { [weak self] () -> DeleteOrKeep in
            guard let `self` = self else {
                return .delete
            }
            self.observer.fullUpdate.update()
            return .keep
        }
    }

    public func subscribeTo<TargetObjectType>(_ observed: Observed<TargetObjectType, Observer1d>) {
        observed.observer.changes.subscribe { [weak self] (_, _, _) -> DeleteOrKeep in
            guard let `self` = self else {
                return .delete
            }
            self.observer.fullUpdate.update()
            return .keep
        }
        observed.observer.fullUpdate.subscribe { [weak self] () -> DeleteOrKeep in
            guard let `self` = self else {
                return .delete
            }
            self.observer.fullUpdate.update()
            return .keep
        }
    }
}
