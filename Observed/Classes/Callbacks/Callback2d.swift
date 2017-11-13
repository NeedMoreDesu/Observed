//
//  Callback2d.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/17.
//

import Foundation
import LazySeq

public typealias Observed2d<Type> = Observed<GeneratedSeq<GeneratedSeq<Type>>, Callback2d>

public class Callback2d: Callback0d {
    public let changes = Subscription2d()
    
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
        self.changes.subscribe { [weak observed] (deletions, insertions, updates, sectionDeletions, sectionInsertions) -> DeleteOrKeep in
            guard let observed = observed else {
                return .delete
            }
            
            if let callback = observed.callback as? Callback2d {
                callback.changes.update(deletions: deletions, insertions: insertions, updates: updates, sectionDeletions: sectionDeletions, sectionInsertions: sectionInsertions)
            } else if let callback = observed.callback as? Callback1d {
                if let section = callback.nth2dSection {
                    func indexConversion(_ arr: [Index2d]) -> [Int] {
                        return arr.filter{ $0.section == section }.map{ $0.row }
                    }
                    let deletions = indexConversion(deletions)
                    let insertions = indexConversion(insertions)
                    let updates = indexConversion(updates)
                    callback.changes.update(deletions: deletions, insertions: insertions, updates: updates)
                } else {
                    let updates = deletions.map { $0.section } + insertions.map { $0.section } + updates.map { $0.section }
                    callback.changes.update(deletions: sectionDeletions, insertions: sectionInsertions, updates: updates)
                }
            } else {
                observed.callback.fullUpdate.update()
            }
            
            return .keep
        }
    }
    
    public func subscribeTableView(tableViewGetter: @escaping (() -> TableViewOrDeleteOrKeep), startingRows: [Int] = [], startingSection: Int = 0, controlReftesh: Bool = true) {
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
        
        var fullUpdateLock = 0
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
        self.changes.subscribe { (deletions, insertions, updates, sectionDeletions, sectionInsertions) -> DeleteOrKeep in
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
                
                if controlReftesh {
                    CATransaction.begin()
                    CATransaction.setCompletionBlock({
                        fullUpdateLock -= 1
                        if fullUpdateLock == 0 {
                            tableView.reloadData()
                        }
                    })
                    fullUpdateLock += 1
                }
                
                tableView.beginUpdates()
                tableView.deleteSections(IndexSet(mappedSectionDeletions), with: .fade)
                tableView.insertSections(IndexSet(mappedSectionInsertions), with: .automatic)
                tableView.deleteRows(at: mappedDeletions, with: .fade)
                tableView.insertRows(at: mappedInsertions, with: .automatic)
                tableView.reloadRows(at: mappedUpdates, with: .automatic)
                tableView.endUpdates()
                
                if controlReftesh {
                    CATransaction.commit()
                }

                return .keep
            }
        }
    }
}

extension Observed where ObjectType: Collection, ObjectType.Element: Collection {
    public typealias Type2d = Type1d.Element

    public func map2d<ReturnType>(_ transform: @escaping (Type2d) -> ReturnType) -> Observed2d<ReturnType> {
        let inputSeq = self.obj as? GeneratedSeq<Type1d> ?? self.obj.generatedSeq()
        let outputSeq = inputSeq.map { (row) -> GeneratedSeq<ReturnType> in
            let inputSeq = row as? GeneratedSeq<Type2d> ?? row.generatedSeq()
            let outputSeq = inputSeq.map(transform).lazySeq()
            return outputSeq
        }.lazySeq()
        let observed = Observed2d<ReturnType>(strongRefs: self.strongRefs + [self], obj: outputSeq)
        self.callback.subscribe(observed)
        return observed
    }

    public func map2dWithoutStorage<ReturnType>(_ transform: @escaping (Type2d) -> ReturnType) -> Observed2d<ReturnType> {
        let inputSeq = self.obj as? GeneratedSeq<Type1d> ?? self.obj.generatedSeq()
        let outputSeq = inputSeq.map { (row) -> GeneratedSeq<ReturnType> in
            let inputSeq = row as? GeneratedSeq<Type2d> ?? row.generatedSeq()
            let outputSeq = inputSeq.map(transform)
            return outputSeq
            }.lazySeq()
        let observed = Observed2d<ReturnType>(strongRefs: self.strongRefs + [self], obj: outputSeq)
        self.callback.subscribe(observed)
        return observed
    }
    
    public func rowObserved(_ section: Int) -> Observed1d<Type2d> {
        let val = self.obj[self.obj.index(self.obj.startIndex, offsetBy: numericCast(section))]
        let outputSeq: GeneratedSeq<Type2d> = (val as? GeneratedSeq<Type2d> ?? val.generatedSeq()).lazySeq()
        let observed = Observed1d<Type2d>(strongRefs: self.strongRefs + [self], obj: outputSeq)
        observed.callback.nth2dSection = section
        self.callback.subscribe(observed)
        return observed
    }

    public func rowObservedNoStorage(_ section: Int) -> Observed1d<Type2d> {
        let val = self.obj[self.obj.index(self.obj.startIndex, offsetBy: numericCast(section))]
        let outputSeq: GeneratedSeq<Type2d> = val as? GeneratedSeq<Type2d> ?? val.generatedSeq()
        let observed = Observed1d<Type2d>(strongRefs: self.strongRefs + [self], obj: outputSeq)
        observed.callback.nth2dSection = section
        self.callback.subscribe(observed)
        return observed
    }
}

extension Observed where ObjectType: Collection, ObjectType.Element: Collection, CallbackType == Callback2d {

}

