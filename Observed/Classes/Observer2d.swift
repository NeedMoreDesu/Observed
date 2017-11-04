//
//  Observer2d.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/17.
//

import Foundation
import LazySeq

public class Observer2d: Observer0d {
    public let changes = Subscription2d()
    
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
        self.changes.subscribe { [weak observed] (deletions, insertions, updates, sectionDeletions, sectionInsertions, sectionUpdates) -> DeleteOrKeep in
            guard let observed = observed else {
                return .delete
            }
            let _ = Resetable.downgradeReset2d(obj: observed.obj as AnyObject)?(deletions, insertions, updates, sectionDeletions, sectionInsertions, sectionUpdates)
            if let observer = observed.observer as? Observer2d {
                observer.changes.update(deletions: deletions, insertions: insertions, updates: updates, sectionDeletions: sectionDeletions, sectionInsertions: sectionInsertions, sectionUpdates: sectionUpdates)
            } else if let observer = observed.observer as? Observer1d {
                observer.changes.update(deletions: sectionDeletions, insertions: sectionInsertions, updates: sectionUpdates)
            } else {
                observed.observer.fullUpdate.update()
            }
            
            return .keep
        }
    }
    
    public func subscribeTableView(tableViewGetter: @escaping (() -> TableViewOrDeleteOrKeep), startingRows: [Int] = [], startingSection: Int = 0) {
        func startingRowForSection(_ section: Int) -> Int {
            if section < startingRows.count {
                return startingRows[section]
            }
            return 0
        }
        func mapIndexPaths(_ indexPaths: [Index2d]) -> [IndexPath] {
            return indexPaths.map({ (indexPath) -> IndexPath in
                let section = indexPath.section + startingSection
                let row = indexPath.row + startingRowForSection(section)
                return IndexPath(row: row, section: section)
            })
        }
        func mapSections(_ sections: [Int]) -> [Int] {
            return sections.map({ (section) -> Int in
                return section + startingSection
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
        self.changes.subscribe { (deletions, insertions, updates, sectionDeletions, sectionInsertions, sectionUpdates) -> DeleteOrKeep in
            switch tableViewGetter() {
            case .delete:
                return .delete
            case .keep:
                return .keep
            case .tableView(let tableView):
                let mappedDeletions = mapIndexPaths(deletions)
                let mappedInsertions = mapIndexPaths(insertions)
                let mappedUpdates = mapIndexPaths(updates)
                let mappedSectionDeletions = mapSections(sectionDeletions)
                let mappedSectionInsertions = mapSections(sectionInsertions)
                
                
                tableView.beginUpdates()
                tableView.deleteSections(IndexSet(mappedSectionDeletions), with: .fade)
                tableView.insertSections(IndexSet(mappedSectionInsertions), with: .automatic)
                tableView.deleteRows(at: mappedDeletions, with: .fade)
                tableView.insertRows(at: mappedInsertions, with: .automatic)
                tableView.reloadRows(at: mappedUpdates, with: .automatic)
                tableView.endUpdates()

                return .keep
            }
        }
    }
}

extension Observed where ObjectType: Collection, ObjectType.Element: Collection {
    public typealias Type2d = Type1d.Element

    public func map2d<ReturnType>(_ transform: @escaping (Type2d) -> ReturnType) -> Observed<LazySeq<LazySeq<ReturnType>>, Observer2d> {
        let inputSeq = self.obj as? GeneratedSeq<Type1d> ?? self.obj.generatedSeq()
        let outputSeq = inputSeq.map { (row) -> LazySeq<ReturnType> in
            let inputSeq = row as? GeneratedSeq<Type2d> ?? row.generatedSeq()
            let outputSeq = inputSeq.map(transform).lazySeq()
            return outputSeq
        }.lazySeq()
        let observed = Observed<LazySeq<LazySeq<ReturnType>>, Observer2d>(obj: outputSeq, observer: Observer2d())
        self.observer.subscribe(observed)
        return observed
    }

    public func map2dWithoutStorage<ReturnType>(_ transform: @escaping (Type2d) -> ReturnType) -> Observed<LazySeq<GeneratedSeq<ReturnType>>, Observer2d> {
        let inputSeq = self.obj as? GeneratedSeq<Type1d> ?? self.obj.generatedSeq()
        let outputSeq = inputSeq.map { (row) -> GeneratedSeq<ReturnType> in
            let inputSeq = row as? GeneratedSeq<Type2d> ?? row.generatedSeq()
            let outputSeq = inputSeq.map(transform)
            return outputSeq
            }.lazySeq()
        let observed = Observed<LazySeq<GeneratedSeq<ReturnType>>, Observer2d>(obj: outputSeq, observer: Observer2d())
        self.observer.subscribe(observed)
        return observed
    }
}

extension Observed where ObjectType: Collection, ObjectType.Element: Collection, ObserverType == Observer2d {

}

