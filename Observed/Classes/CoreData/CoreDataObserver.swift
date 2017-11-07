//
//  CoreDataObserver.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/13/17.
//

import Foundation
import CoreData
import LazySeq

extension Observed {
    public typealias fromCoreData<Type: NSManagedObject> = CoreDataObserver<Type>.Type
}

public struct FetchRequestParameters {
    public var predicate: NSPredicate?
    public var sortDescriptors: [NSSortDescriptor]?
    public var fetchBatchSize: Int?
    public var sectionNameKeyPath: String?
    public init() {}
}

open class CoreDataObserver<Type>: NSObject, NSFetchedResultsControllerDelegate where Type: NSManagedObject {
    private var controller: NSFetchedResultsController<Type>
    private class func fetchResultController(entityName: String,
                                             primaryKey: String,
                                             managedObjectContext: NSManagedObjectContext,
                                             params: FetchRequestParameters? = nil) -> NSFetchedResultsController<Type> {
        let request = NSFetchRequest<Type>(entityName: entityName)
        request.predicate = params?.predicate
        request.fetchBatchSize = params?.fetchBatchSize ?? 20
        request.sortDescriptors = params?.sortDescriptors ?? [NSSortDescriptor(key: primaryKey, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController<Type>(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: params?.sectionNameKeyPath, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            abort()
        }
        
        return fetchedResultsController
    }
    
    init(entityName: String,
         primaryKey: String,
         managedObjectContext: NSManagedObjectContext,
         params: FetchRequestParameters? = nil) {
        let fetchedResultController = CoreDataObserver.fetchResultController(entityName: entityName,
                                                                             primaryKey: primaryKey,
                                                                             managedObjectContext: managedObjectContext,
                                                                             params: params)
        self.controller = fetchedResultController
        
        super.init()
        
        fetchedResultController.delegate = self
    }
    
    init(fetchedResultController: NSFetchedResultsController<Type>) {
        self.controller = fetchedResultController
        
        super.init()
        
        fetchedResultController.delegate = self
    }
    
    public class func create(entityName: String,
                      primaryKey: String,
                      managedObjectContext: NSManagedObjectContext,
                      params: FetchRequestParameters? = nil) -> Observed2d<Type> {
        let observer = CoreDataObserver(entityName: entityName,
                                        primaryKey: primaryKey,
                                        managedObjectContext: managedObjectContext,
                                        params: params)
        
        return observer.setupObservedSections()
    }
    
    public class func create(fetchedResultController: NSFetchedResultsController<Type>) -> Observed2d<Type> {
        let observer = CoreDataObserver(fetchedResultController: fetchedResultController)
        
        return observer.setupObservedSections()
    }
    
    weak var observed: Observed2d<Type>?
    private func setupObservedSections() -> Observed2d<Type> {
        let objs = LazySeq(count: { () -> Int in
            return self.controller.sections?.count ?? 0
        }) { (sectionIdx, _) -> GeneratedSeq<Type> in
            return GeneratedSeq<Type>(count: { () -> Int in
                if let sections = self.controller.sections {
                    if sectionIdx < sections.count {
                        return sections[sectionIdx].numberOfObjects
                    }
                }
                return 0
            }, generate: { (idx, _) -> Type? in
                let obj = self.controller.object(at: IndexPath(row: idx, section: sectionIdx))
                return obj
            })
        }
        
        let observed = Observed2d<Type>(strongRefs: [self], obj: objs)
        self.observed = observed
        
        return observed
    }
    
    private var deletions: [Index2d] = []
    private var insertions: [Index2d] = []
    private var updates: [Index2d] = []
    private var sectionDeletions: [Int] = []
    private var sectionInsertions: [Int] = []
    func resetChanges() {
        self.deletions = []
        self.insertions = []
        self.updates = []
        self.sectionDeletions = []
        self.sectionInsertions = []
    }
    func applyChanges() {
        self.observed?.callback.changes.update(deletions: self.deletions, insertions: self.insertions, updates: self.updates, sectionDeletions: self.sectionDeletions, sectionInsertions: self.sectionInsertions)
        self.resetChanges()
    }

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.resetChanges()
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.applyChanges()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        var type = type
        if (type == .update && newIndexPath != nil && indexPath?.compare(newIndexPath!) != .orderedSame) {
            type = .move;
        }
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                self.insertions.append(indexPath.toIndex2d())
            }
        case .delete:
            if let indexPath = indexPath {
                self.deletions.append(indexPath.toIndex2d())
            }
        case .update:
            if let indexPath = indexPath {
                self.updates.append(indexPath.toIndex2d())
            }
        case .move:
            if let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath {
                self.deletions.append(oldIndexPath.toIndex2d())
                self.insertions.append(newIndexPath.toIndex2d())
            }
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch (type) {
        case .insert:
            self.sectionInsertions.append(sectionIndex)
            break
        case .delete:
            self.sectionDeletions.append(sectionIndex)
            break
        default:
            break
        }
    }
}
