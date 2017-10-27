//
//  Observer1d.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/17.
//

import Foundation
import LazySeq

public class Observer1d: ObserverDefault {
    public let changes = Subscription1d()
}

extension Observed where ObjectType: Collection {
    public typealias Type1d = ObjectType.Element
    
    public func map1d<ReturnType>(_ transform: @escaping (Type1d) -> ReturnType, noStore: Bool = false) -> Observed<GeneratedSeq<ReturnType>, Observer1d> {
        let inputSeq = self.obj as? GeneratedSeq<Type1d> ?? self.obj.generatedSeq()
        var outputSeq = inputSeq.map(transform)
        if(!noStore) {
            outputSeq = outputSeq.lazySeq()
        }
        let observed = Observed<GeneratedSeq<ReturnType>, Observer1d>(obj: outputSeq, observer: Observer1d())
        return observed
    }
}

extension Observed where ObjectType: Collection, ObserverType == Observer1d {

    public func subscribeTo<TargetObjectType>(_ observed: Observed<TargetObjectType, ObserverType>) {
        observed.observer.fullUpdate.subscribe { [weak self] () -> DeleteOrKeep in
            guard let `self` = self else {
                return .delete
            }
            if let lazySeq = self.obj as? LazySeq<Type1d> {
                lazySeq.resetStorage()
            }
            self.observer.fullUpdate.update()
            return .keep
        }
        observed.observer.changes.subscribe { [weak self] (deletions, insertions, updates) -> DeleteOrKeep in
            guard let `self` = self else {
                return .delete
            }
            if let lazySeq = self.obj as? LazySeq<Type1d> {
                lazySeq.applyChanges(deletions: deletions, insertions: insertions, updates: updates)
            }
            self.observer.changes.update(deletions: deletions, insertions: insertions, updates: updates)
            return .keep
        }
    }
}
