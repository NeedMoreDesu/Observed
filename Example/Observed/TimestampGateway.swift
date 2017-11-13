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

protocol TimestampDatabaseProtocol: class {
    func observed() -> Observed2d<Timestamp>
    func sections() -> Observed1d<TimestampSection>
    func createTimestamp() -> Timestamp
    func deleteAt(indexPath: IndexPath)
}

class TimestampGateway: TimestampRouter {
    weak var database: TimestampDatabaseProtocol! { didSet { self.setup() } }
    
    var observed: Observed2d<Timestamp>!
    var sections: Observed1d<TimestampSection>!
    func setup() {
        self.observed = self.database.observed()
        self.sections = self.database.sections()
    }
    
    func createTimestamp() -> Timestamp {
        return self.database.createTimestamp()
    }
    
    func deleteAt(indexPath: IndexPath) {
        self.database.deleteAt(indexPath: indexPath)
    }
}
