//
//  Callback1d.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/17.
//

import Foundation
import LazySeq
import UIKit

public typealias Observed1d<Type> = Observed<GeneratedSeq<Type>, Callback1d>

public class Callback1d: Callback0d {
    public let changes = Subscription1d()
    
    override func setObjectToReset(_ objectToReset: AnyObject) {
        super.setObjectToReset(objectToReset)
        self.changes.objectToReset = objectToReset
    }
    
    override func subscribe<TargetObjectType, TargetCallbackType>(_ observed: Observed<TargetObjectType, TargetCallbackType>) {
        self.fullUpdate.subscribe { [weak observed] () -> DeleteOrKeep in
            guard let observed = observed else {
                return .delete
            }
            observed.callback.fullUpdate.update()
            return .keep
        }
        self.changes.subscribe { [weak observed] (deletions, insertions, updates) -> DeleteOrKeep in
            guard let observed = observed else {
                return .delete
            }
            if let callback = observed.callback as? Callback1d {
                callback.changes.update(deletions: deletions, insertions: insertions, updates: updates)
            } else {
                observed.callback.fullUpdate.update()
            }

            return .keep
        }
    }
    
    public func subscribeTableView(tableViewGetter: @escaping (() -> TableViewOrDeleteOrKeep), startingRow: Int = 0, section: Int = 0) {
        func mapIndexPaths(_ rows: [Int]) -> [IndexPath] {
            return rows.map({ (section) -> IndexPath in
                return IndexPath(row: section + startingRow, section: section)
            })
        }
        
        self.fullUpdate.subscribe { () -> DeleteOrKeep in
            switch tableViewGetter() {
            case .delete:
                return .delete
            case .keep:
                return .keep
            case .tableView(let tableView):
                tableView.reloadData()
                return .keep
            }
        }
        self.changes.subscribe { (deletions, insertions, updates) -> DeleteOrKeep in
            switch tableViewGetter() {
            case .delete:
                return .delete
            case .keep:
                return .keep
            case .tableView(let tableView):
                let mappedDeletions = mapIndexPaths(deletions)
                let mappedInsertions = mapIndexPaths(insertions)
                let mappedUpdates = mapIndexPaths(updates)
                
                tableView.beginUpdates()
                tableView.deleteRows(at: mappedDeletions, with: .fade)
                tableView.insertRows(at: mappedInsertions, with: .automatic)
                tableView.reloadRows(at: mappedUpdates, with: .automatic)
                tableView.endUpdates()
                
                return .keep
            }
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
        let observed = Observed1d<ReturnType>(strongRefs: self.strongRefs + [self], obj: outputSeq)
        self.callback.subscribe(observed)
        return observed
    }

    public func map1dWithoutStorage<ReturnType>(_ transform: @escaping (Type1d) -> ReturnType) -> Observed1d<ReturnType> {
        let inputSeq = self.obj as? GeneratedSeq<Type1d> ?? self.obj.generatedSeq()
        let outputSeq = inputSeq.map(transform)
        let observed = Observed1d<ReturnType>(strongRefs: self.strongRefs + [self], obj: outputSeq)
        self.callback.subscribe(observed)
        return observed
    }
}

extension Observed where ObjectType: Collection, CallbackType == Callback1d {
    
}
