//
//  Resetable.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/28/17.
//

import Foundation
import LazySeq

public struct Resetable {
    public static func downgradeReset0d(obj: Any) {
        if let resetable0d = (obj as? Resetable0d) {
            resetable0d.reset()
        }
    }
    public static func downgradeReset1d(obj: Any, deletions: [Int], insertions: [Int], updates: [Int]) {
        if let resetable1d = (obj as? Resetable1d) {
            resetable1d.reset(deletions: deletions, insertions: insertions, updates: updates)
        }
        downgradeReset0d(obj: obj)
    }
    public static func downgradeReset2d(obj: Any, deletions: [Index2d], insertions: [Index2d], updates: [Index2d], sectionDeletions: [Int], sectionInsertions: [Int], sectionUpdates: [Int]) {
        if let resetable2d = (obj as? Resetable2d) {
            resetable2d.reset(deletions: deletions, insertions: insertions, updates: updates, sectionDeletions: sectionDeletions, sectionInsertions: sectionInsertions, sectionUpdates: sectionUpdates)
        }
        downgradeReset1d(obj: obj, deletions: sectionDeletions, insertions: sectionInsertions, updates: sectionUpdates)
    }
}

public protocol Resetable0d {
    func reset()
}

extension LazySeq: Resetable0d {
    public func reset() {
        self.resetStorage()
    }
}

public protocol Resetable1d {
    func reset(deletions: [Int], insertions: [Int], updates: [Int])
    func copyStorage(seq: Resetable1d)
}

extension Resetable1d {
    public func copyStorage(seq: Resetable1d) {
    }
}

extension LazySeq: Resetable1d {
    public func reset(deletions: [Int], insertions: [Int], updates: [Int]) {
        self.applyChanges(deletions: deletions, insertions: insertions, updates: updates)
    }
    public func copyStorage(seq: Resetable1d) {
        if let seq = seq as? LazySeq<Type> {
            self.storage = seq.storage
        }
    }
}

public protocol Resetable2d {
    func reset(deletions: [Index2d], insertions: [Index2d], updates: [Index2d], sectionDeletions: [Int], sectionInsertions: [Int], sectionUpdates: [Int])
}

extension LazySeq: Resetable2d {
    public func reset(deletions: [Index2d], insertions: [Index2d], updates: [Index2d], sectionDeletions: [Int], sectionInsertions: [Int], sectionUpdates: [Int]) {
        guard self.first is Resetable1d else {
            self.reset(deletions: sectionDeletions, insertions: sectionInsertions, updates: sectionUpdates)
            return
        }
        let deletionsGrouped = Dictionary.init(grouping: deletions, by: { (index) -> Int in
            return index.section
        })
        let insertionsGrouped = Dictionary.init(grouping: insertions, by: { (index) -> Int in
            return index.section
        })
        let updatesGrouped = Dictionary.init(grouping: updates, by: { (index) -> Int in
            return index.section
        })
        
        for (sectionIdx, section) in self.storage {
            guard let section = section as? Resetable1d else {
                continue
            }
            if let _ = sectionDeletions.first(where: { $0 == sectionIdx}) {
                continue
            }
            let deletions = deletionsGrouped[sectionIdx]?.map({ $0.row }) ?? []
            let insertions = insertionsGrouped[sectionIdx]?.map({ $0.row }) ?? []
            let updates = updatesGrouped[sectionIdx]?.map({ $0.row }) ?? []
            if deletions.count == 0 && insertions.count == 0 && updates.count == 0 {
                continue
            }
            section.reset(deletions: deletions, insertions: insertions, updates: updates)
        }
        let generator = self.generatedSeq()
        self.applyChanges(deletions: sectionDeletions, insertions: sectionInsertions, updates: [], copyFn: { (oldIndex, newIndex, seq) -> Type? in
            if oldIndex == newIndex {
                return seq
            }
            if let oldLazySeq = seq as? Resetable1d,
                let newLazySeq = generator.get(newIndex) as? Resetable1d {
                // need to copy stored items, not the generator itself
                newLazySeq.copyStorage(seq: oldLazySeq)
                return newLazySeq as? Type
            }
            return nil // oh, you are not LazySeq? Then nothing of value was lost
        })
    }
}

