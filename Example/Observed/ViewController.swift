//
//  ViewController.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/2017.
//  Copyright (c) 2017 Oleksii Horishnii. All rights reserved.
//

import UIKit
import Observed

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let a = Observed(obj: [2, 3], observer: Observer1d())
        let b = a.map({ (wholeObj) -> String in
            return "\(wholeObj.count) count"
        })
        let bb = b.map { (_) -> String in
            return "asdf"
        }
//        b.subscribeTo(a)
        let c = a.map1d({ (justOneObj) -> String in
            return "\(justOneObj)obj"
        })
//        c.subscribeTo(a)
        
        b.observer.fullUpdate.subscribe { () -> DeleteOrKeep in
            print("\(b.obj)")
            return .keep
        }
        c.observer.fullUpdate.subscribe { () -> DeleteOrKeep in
            print("\(c.obj.allObjects())")
            return .keep
        }
        
        a.observer.fullUpdate.update()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

