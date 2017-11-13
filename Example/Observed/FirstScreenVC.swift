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
    
    func subscribe() {
        let getter = { [weak self] () -> TableViewOrDeleteOrKeep in
            guard let `self` = self else {
                // if this screen is dead - remove callback
                return .delete
            }
            guard let tableView = self.tableView else {
                // if tableview is not yet here, keep callback alive
                return .keep
            }
            return .tableView(tableView)
        }
        self.presenter.observed.callback.subscribeTableView(tableViewGetter: getter)
    }

    //MARK:- table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.presenter.observed.obj.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.observed.obj[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = self.presenter.observed.obj[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "main", for: indexPath)
        
        cell.textLabel?.text = cellModel.cellTitle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionModel = self.presenter.sectionModels.obj[section]
        return sectionModel.sectionTitle
    }
    
    //MARK:- table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.cellClickedAt(indexPath: indexPath)
    }
}

