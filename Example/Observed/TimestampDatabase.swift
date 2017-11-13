//
//  TimestampDatabase.swift
//  Observed_Example
//
//  Created by Oleksii Horishnii on 11/13/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Observed
import LazySeq

class TimestampDatabase: TimestampDatabaseProtocol {
    private let databaseObserved = DBTimestamp.createObserved()
    private func toTimestampEntity(dbobj: DBTimestamp) -> Timestamp {
        return Timestamp(time: dbobj.time!)
    }
    
    func observed() -> Observed2d<Timestamp> {
        return self.databaseObserved.map2d(self.toTimestampEntity)
    }
    
    func sections() -> Observed1d<TimestampSection> {
        return self.databaseObserved.map1d { (section) -> TimestampSection in
            let second = section.first()?.second ?? 0
            return TimestampSection(second: Int(second), count: section.count)
        }
    }
    
    func createTimestamp() -> Timestamp {
        let dbTimestamp = DBTimestamp.create()
        CoreData.shared.save()
        return toTimestampEntity(dbobj: dbTimestamp)
    }
    
    func deleteAt(indexPath: IndexPath) {
        let item = self.databaseObserved.obj[indexPath.section][indexPath.row]
        item.delete()
    }
}
