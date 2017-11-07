//
//  FirstScreenPresenter.swift
//  Observed_Example
//
//  Created by Oleksii Horishnii on 10/24/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Observed
import LazySeq

struct FirstScreenCellModel {
    var cellTitle: String
}

struct FirstScreenSectionModel {
    var sectionTitle: String
}

protocol FirstScreenView: class {
    var presenter: FirstScreenPresenter! { get set }
    var observed: Observed2d<FirstScreenCellModel>! { get set }
    var sectionModels: GeneratedSeq<FirstScreenSectionModel>! { get set }
}

protocol FirstScreenPresenter: class {
    weak var view: FirstScreenView! { get set }
    
    func cellClickedAt(indexPath: IndexPath)
}

class FirstScreenPresenterImplementation: FirstScreenPresenter, FirstScreenOutput {
    var observed: Observed2d<Timestamp>!
    var sectionSeconds: GeneratedSeq<Seconds>!
    
    var useCase: FirstScreenUseCase!
    weak var view: FirstScreenView! { didSet { self.setup() } }
    
    func setup() {
        view.observed = observed.map2d { (timestamp) -> FirstScreenCellModel in
            let cellModel = FirstScreenCellModel(cellTitle: "\(timestamp.time)")
            return cellModel
        }
        view.sectionModels = sectionSeconds.map { (seconds) -> FirstScreenSectionModel in
            return FirstScreenSectionModel(sectionTitle: "\(seconds.value)s")
        }
    }
    
    func cellClickedAt(indexPath: IndexPath) {
        self.useCase.deleteItemAt(indexPath: indexPath)
    }
}
