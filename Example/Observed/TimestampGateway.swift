//
//  TimestampGateway.swift
//  Observed_Example
//
//  Created by Oleksii Horishnii on 10/24/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Observed
import LazySeq

class TimestampGateway: TimestampRouter {
    private let databaseObserved = DBTimestamp.createObserved()
    private func toTimestampEntity(dbobj: DBTimestamp) -> Timestamp {
        return Timestamp(time: dbobj.time!)
    }
    
    func observed() -> Observed2d<Timestamp> {
        return self.databaseObserved.map2d(self.toTimestampEntity)
    }
    
    func sectionSeconds() -> GeneratedSeq<Seconds> {
        return self.databaseObserved.obj.map({ (section) -> Seconds in
            let second = section.first()?.second ?? 0
            return Seconds(value: Int(second))
        })
    }
    
    func createTimestamp() -> Timestamp {
        let dbTimestamp = DBTimestamp.create()
        CoreData.shared.save()
        return toTimestampEntity(dbobj: dbTimestamp)
    }
    
    func deleteTimestampAt(indexPath: IndexPath) {
        let item = self.databaseObserved.obj[indexPath.section][indexPath.row]
        item.delete()
    }
}
