# Observed

[![CI Status](http://img.shields.io/travis/Oleksii Horishnii/Observed.svg?style=flat)](https://travis-ci.org/Oleksii Horishnii/Observed)
[![Version](https://img.shields.io/cocoapods/v/Observed.svg?style=flat)](http://cocoapods.org/pods/Observed)
[![License](https://img.shields.io/cocoapods/l/Observed.svg?style=flat)](http://cocoapods.org/pods/Observed)
[![Platform](https://img.shields.io/cocoapods/p/Observed.svg?style=flat)](http://cocoapods.org/pods/Observed)

This pod focuses on building wrapper for objects that are:

1. Loaded lazily, like batch requests from database
2. Observed and updated
3. May need transformation on the way

## Why using this pod?

It makes your application database-agnostic (since you map database objects into some other non-database objects on the way), but allows you to use lazily-created objects (say, use only those 20 objects that tableView asks, not all 10000 that are in the database), and subscribe to changes (default tableView subscription method is very simple to use).

## What is it?

Create Observed by observing something. For example, your database (CoreData supported, Reaml is on the way).

```swift
var params = FetchRequestParameters()
params.sortDescriptors = [NSSortDescriptor(key: "second", ascending: true), NSSortDescriptor(key: "someField", ascending: true)]
let observed = CoreDataObserver<DBObject>.create(entityName: entityName, managedObjectContext: context, params: params)
```

Then transform it to another structure, linking Observed's together

```swift
let newObserved = observed.map2d { (oldObject) -> NewObjectType in
            let newObject = NewObjectType()
            newObject.someField = oldObject.someOtherField
            return newObject
        }

let sectionObserved = observed.map1d { (section) -> Int in
            return section.count
}

let numberOfRowsTotal = sectionObserved.map0d { (sectionRows) -> Int in
            return sectionRows.allObjects().reduce(0, { (sum, rows) -> Int in
                     return sum+rows
                   })
}

let firstRowObserved = observed.rowObserved(0)
```

Any update calls made to `observed` will update `newObserved`, `sectionObserved` and `firstRowObserved`, and changes to `sectionObserved` will update `numberOfRowsTotal`.

``` swift
numberOfRowsTotal.callback.fullUpdate.subscribe { () -> DeleteOrKeep in
  print(numberOfRowsTotal.obj.value())
  return .delete // make it one-time subscription
}
observed.callback.fullUpdate.update()
// total number of rows printed
```

Then use it in your ViewController like that:

```swift
    var observed: Observed2d<YourType>!

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

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.observed.obj.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.observed.obj[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let yourObject = self.observed.obj[indexPath.section][indexPath.row]
        ...
    }
```

You can observe something manually

``` swift
var arr: [Int] = [1, 2, 3]
let gen = GeneratedSeq(count: { () -> Int in
    return arr.count
  }, generate: { idx, _ in
    return arr[idx]
  })
let observed1d = Observed1d(obj: gen)
// use observed somewhere, map or subscribe it
arr[1] = 10
arr.append(20)
arr.append(30)
observed1d.callback.changes.update(deletions: [], insertions: [3, 4], updates: [1])
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

The example is pretty neat, don't miss it :)

## Installation

Observed is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Observed'
```

## Author

Oleksii Horishnii, oleksii.horishnii@gmail.com

## License

Observed is available under the MIT license. See the LICENSE file for more info.
