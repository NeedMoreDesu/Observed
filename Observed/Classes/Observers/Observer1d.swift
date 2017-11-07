//
//  Observer1d.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/17.
//

import Foundation
import LazySeq

public typealias Observed1d<Type> = Observed<GeneratedSeq<Type>, Observer1d>

public class Observer1d: Observer0d {
    public let changes = Subscription1d()
    
    override func setObjectToReset(_ objectToReset: AnyObject) {
        super.setObjectToReset(objectToReset)
        self.changes.objectToReset = objectToReset
    }
    
    override func subscribe<TargetObjectType, TargetObserverType>(_ observed: Observed<TargetObjectType, TargetObserverType>) {
        self.fullUpdate.subscribe { [weak observed] () -> DeleteOrKeep in
            guard let observed = observed else {
                return .delete
            }
            let _ = Resetable.downgradeReset0d(obj: observed.obj as AnyObject)?()
            observed.observer.fullUpdate.update()
            return .keep
        }
        self.changes.subscribe { [weak observed] (deletions, insertions, updates) -> DeleteOrKeep in
            guard let observed = observed else {
                return .delete
            }
            let _ = Resetable.downgradeReset1d(obj: observed.obj as AnyObject)?(deletions, insertions, updates)
            if let observer = observed.observer as? Observer1d {
                observer.changes.update(deletions: deletions, insertions: insertions, updates: updates)
            } else {
                observed.observer.fullUpdate.update()
            }

            return .keep
        }
    }
}

public enum TableViewOrDeleteOrKeep {
    case tableView(UITableView)
    case delete
    case keep
}

extension Observed where ObjectType: Collection {
    public typealias Type1d = ObjectType.Element
    
    public func map1d<ReturnType>(_ transform: @escaping (Type1d) -> ReturnType) -> Observed1d<ReturnType> {
        let inputSeq = self.obj as? GeneratedSeq<Type1d> ?? self.obj.generatedSeq()
        let outputSeq = inputSeq.map(transform).lazySeq()
        outputSeq.shouldStoreCount = true
        let observed = Observed1d<ReturnType>(obj: outputSeq)
        self.observer.subscribe(observed)
        return observed
    }

    public func map1dWithoutStorage<ReturnType>(_ transform: @escaping (Type1d) -> ReturnType) -> Observed1d<ReturnType> {
        let inputSeq = self.obj as? GeneratedSeq<Type1d> ?? self.obj.generatedSeq()
        let outputSeq = inputSeq.map(transform)
        let observed = Observed1d<ReturnType>(obj: outputSeq)
        self.observer.subscribe(observed)
        return observed
    }
}

extension Observed where ObjectType: Collection, ObserverType == Observer1d {
    
}
