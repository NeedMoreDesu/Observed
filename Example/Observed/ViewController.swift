//
//  ViewController.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/27/2017.
//  Copyright (c) 2017 Oleksii Horishnii. All rights reserved.
//

import UIKit
import Observed
import LazySeq

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var arr = [2, 3, 23]
        let gen = GeneratedSeq(count: { () -> Int in
            return arr.count
        }, generate: { idx, _ in
            return arr[idx]
        })
        let a = Observed1d(obj: gen)
        let b = a.map0d { (wholeObj) -> String in
            return "\(wholeObj.count) count"
        }
        let c = a.map1d { (justOneObj) -> String in
            return "\(justOneObj)obj"
        }
        
//        b.Callback.fullUpdate.subscribe { () -> DeleteOrKeep in
//            print("\(b.obj.value())")
//            return .keep
//        }
        c.callback.fullUpdate.subscribe { () -> DeleteOrKeep in
            print("full update: \(c.obj.allObjects())")
            print("\(b.obj.value())")
            return .keep
        }
        c.callback.changes.subscribe { (_, _, _) -> DeleteOrKeep in
            print("update: \(c.obj.allObjects())")
            print("\(b.obj.value())")
            return .keep
        }
        
        a.callback.changes.update(deletions: [], insertions: [], updates: [0, 1])
        arr.append(90)
        a.callback.fullUpdate.update()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

