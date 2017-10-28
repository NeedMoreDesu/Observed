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
    
//    override func subscribe<TargetObjectType, TargetObserverType>(_ observed: Observed<TargetObjectType, TargetObserverType>) {
//        self.fullUpdate.subscribe { [weak observed] () -> DeleteOrKeep in
//            guard let observed = observed else {
//                return .delete
//            }
//            observed.observer.fullUpdate.update()
//            return .keep
//        }
//        self.changes.subscribe { [weak observed] (deletions, insertions, updates) -> DeleteOrKeep in
//            guard let observed = observed else {
//                return .delete
//            }
//            if let observer = observed.observer as? Observer1d {
//                observer.changes.update(deletions: deletions, insertions: insertions, updates: updates)
//            } else {
//                observed.observer.fullUpdate.update()
//            }
//
//            return .keep
//        }
//    }
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
        observed.subscribeTo(self.observer)
        return observed
    }
}

extension Observed where ObjectType: Collection, ObserverType == Observer1d {
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
            if let lazySeq = self.obj as? LazySeq<Type1d> {
                lazySeq.resetStorage()
            }
            self.observer.fullUpdate.update()
            return .keep
        }
    }
    public func subscribeTo(_ observer: Observer1d) {
        observer.fullUpdate.subscribe { [weak self] () -> DeleteOrKeep in
            guard let `self` = self else {
                return .delete
            }
            if let lazySeq = self.obj as? LazySeq<Type1d> {
                lazySeq.resetStorage()
            }
            self.observer.fullUpdate.update()
            return .keep
        }
        observer.changes.subscribe { [weak self] (deletions, insertions, updates) -> DeleteOrKeep in
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

//    public func subscribeTo<TargetObjectType>(_ observed: Observed<TargetObjectType, Observer2d>) {
//        observed.observer.fullUpdate.subscribe { [weak self] () -> DeleteOrKeep in
//            guard let `self` = self else {
//                return .delete
//            }
//            if let lazySeq = self.obj as? LazySeq<Type1d> {
//                lazySeq.resetStorage()
//            }
//            self.observer.fullUpdate.update()
//            return .keep
//        }
//        observed.observer.changes.subscribe { [weak self] (_, _, _, deletions, insertions, updates) -> DeleteOrKeep in
//            guard let `self` = self else {
//                return .delete
//            }
//            if let lazySeq = self.obj as? LazySeq<Type1d> {
//                lazySeq.applyChanges(deletions: deletions, insertions: insertions, updates: updates)
//            }
//            self.observer.changes.update(deletions: deletions, insertions: insertions, updates: updates)
//            return .keep
//        }
//    }
}
