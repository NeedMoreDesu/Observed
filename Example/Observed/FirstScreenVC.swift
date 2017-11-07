//
//  ViewController.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/13/2017.
//  Copyright (c) 2017 Oleksii Horishnii. All rights reserved.
//

import UIKit
import Observed
import LazySeq

class FirstScreenVC: UIViewController, FirstScreenView, UITableViewDelegate, UITableViewDataSource {
    //MARK:- outlets
    @IBOutlet private weak var tableView: UITableView!

    //MARK:- FirstScreenView Interface
    var presenter: FirstScreenPresenter!

    var observed: Observed2d<FirstScreenCellModel>! {
        didSet {
            self.observed.callback.subscribeTableView(tableViewGetter: { [weak self] () -> TableViewOrDeleteOrKeep in
                guard let `self` = self else {
                    // if this screen is dead - remove callback
                    return .delete
                }
                guard let tableView = self.tableView else {
                    // if tableview is not yet here, keep callback alive
                    return .keep
                }
                return .tableView(tableView)
            })
        }
    }
    var sectionModels: GeneratedSeq<FirstScreenSectionModel>!

    //MARK:- table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.observed.obj.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.observed.obj[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = self.observed.obj[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "main", for: indexPath)
        
        cell.textLabel?.text = cellModel.cellTitle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionModel = self.sectionModels[section]
        return sectionModel.sectionTitle
    }
    
    //MARK:- table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.cellClickedAt(indexPath: indexPath)
    }
}

