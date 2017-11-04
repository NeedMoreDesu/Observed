// https://github.com/Quick/Quick

import Quick
import Nimble
import Observed
import LazySeq

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("1d") {
            var arr: [Int] = []
            let gen = GeneratedSeq(count: { () -> Int in
                return arr.count
            }, generate: { idx, _ in
                return arr[idx]
            })
            let a = Observed(obj: gen, observer: Observer1d())
            func cleanupState() {
                arr = [1, 2, 3]
                a.observer.fullUpdate.update()
            }
            context("->0d map") {
                let b = a.map { (wholeObj) -> String in
                    return "count == \(wholeObj.count)"
                }
                it("expectable value") {
                    cleanupState()
                    expect(b.obj.value()) == "count == 3"
                }
                it("expectable updating behaviour") {
                    cleanupState()
                    b.observer.fullUpdate.subscribe({ () -> DeleteOrKeep in
                        expect(b.obj.value()) == "count == 4"
                        return .delete
                    })
                    expect(b.obj.value()) == "count == 3"
                    arr = [1, 2, 10, 20]
                    expect(b.obj.value()) == "count == 3"
                    a.observer.fullUpdate.update()
                    expect(b.obj.value()) == "count == 4"
                }
            }
            context("->1d map") {
                let b = a.map1d { (justOneObj) -> String in
                    return "\(justOneObj)obj"
                }
                it("expectable value") {
                    cleanupState()
                    expect(b.obj.allObjects()) == ["1obj", "2obj", "3obj"]
                }
            }
        }
        describe("1d") {
            var arr: [[Int]] = []
            let gen = LazySeq(count: { () -> Int in
                return arr.count
            }, generate: { (section, _) -> GeneratedSeq<Int> in
                return GeneratedSeq(count: { () -> Int in
                    return arr[section].count
                }, generate: { idx, _ in
                    return arr[section][idx]
                })
            })
            
            let a = Observed(obj: gen, observer: Observer1d())
            func cleanupState() {
                arr = [[1, 2, 3], [40, 50], [600], [7000, 8000]]
                a.observer.fullUpdate.update()
            }
            context("->2d map", {
                let b = a.map2d({ (arg) -> Double in
                    return Double(arg)+0.5
                })
                it("expected value") {
                    cleanupState()
                    let res: [[Double]] = b.obj.allObjects().map { $0.allObjects() }
                    let expected = [[1.5, 2.5, 3.5], [40.5, 50.5], [600.5], [7000.5, 8000.5]]
                    for (idx, items) in res.enumerated() {
                        let expected = expected[idx]
                        expect(items) == expected
                    }
                }
            })
        }
    }
}
