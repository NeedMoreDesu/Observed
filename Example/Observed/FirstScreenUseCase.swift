//
//  FirstScreenUseCase.swift
//  Observed_Example
//
//  Created by Oleksii Horishnii on 10/24/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import LazySeq
import Observed

struct TimestampSection {
    let second: Int
    let count: Int
}

protocol FirstScreenOutput: class {
}

protocol TimestampRouter {
    var observed: Observed2d<Timestamp>! { get }
    var sections: Observed1d<TimestampSection>! { get }

    func createTimestamp() -> Timestamp
    func deleteAt(indexPath: IndexPath)
}

protocol FirstScreenUseCase: class {
    weak var output: FirstScreenOutput! { get set }
    var timestampRouter: TimestampRouter! { get set }

    var observed: Observed2d<Timestamp>! { get }
    var sections: Observed1d<TimestampSection>! { get }

    func deleteItemAt(indexPath: IndexPath)
}

class FisrtScreenInteractor: FirstScreenUseCase {
    weak var output: FirstScreenOutput! { didSet { self.setup() } }
    var timestampRouter: TimestampRouter!

    var observed: Observed2d<Timestamp>! {
        return self.timestampRouter.observed
    }
    var sections: Observed1d<TimestampSection>! {
        return self.timestampRouter.sections
    }

    func setup() {
        self.generateTimestampEvery1sec()
    }

    func deleteItemAt(indexPath: IndexPath) {
        self.timestampRouter.deleteAt(indexPath: indexPath)
    }
    
    func generateTimestampEvery1sec() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            let _ = self?.timestampRouter.createTimestamp()
            self?.generateTimestampEvery1sec()
        }
    }
}
