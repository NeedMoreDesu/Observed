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
    func subscribe()
}

protocol FirstScreenPresenter: class {
    weak var view: FirstScreenView! { get set }
    
    var observed: Observed2d<FirstScreenCellModel>! { get }
    var sectionModels: Observed1d<FirstScreenSectionModel>! { get }

    func cellClickedAt(indexPath: IndexPath)
}

class FirstScreenPresenterImplementation: FirstScreenPresenter, FirstScreenOutput {
    var useCase: FirstScreenUseCase!
    weak var view: FirstScreenView! { didSet { self.setup() } }
    
    var observed: Observed2d<FirstScreenCellModel>!
    var sectionModels: Observed1d<FirstScreenSectionModel>!
    
    func setup() {
        self.observed = self.useCase.observed.map2d { (timestamp) -> FirstScreenCellModel in
            let cellModel = FirstScreenCellModel(cellTitle: "\(timestamp.time)")
            return cellModel
        }
        self.sectionModels = self.useCase.sections.map1d { (section) -> FirstScreenSectionModel in
            return FirstScreenSectionModel(sectionTitle: "\(section.second)s, count: \(section.count)")
        }
        self.view.subscribe()
    }
    
    func cellClickedAt(indexPath: IndexPath) {
        self.useCase.deleteItemAt(indexPath: indexPath)
    }
}
