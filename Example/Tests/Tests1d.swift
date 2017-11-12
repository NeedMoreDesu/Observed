// https://github.com/Quick/Quick

import Quick
import Nimble
import Observed
import LazySeq

class Tests1d: QuickSpec {
    override func spec() {
        var arr: [Int] = []
        let gen = GeneratedSeq(count: { () -> Int in
            return arr.count
        }, generate: { idx, _ in
            return arr[idx]
        })
        let a = Observed1d(obj: gen)
        func cleanupState() {
            arr = [1, 2, 3]
            a.callback.fullUpdate.update()
        }
        
        context("map1d") {
            let b = a.map1d { (justOneObj) -> String in
                return "\(justOneObj)obj"
            }
            let bNoStore = a.map1d { (justOneObj) -> String in
                return "\(justOneObj)obj"
            }
            let expectedDefaultValue = ["1obj", "2obj", "3obj"]
            it("expected value") {
                cleanupState()
                expect(b.obj.allObjects()) == expectedDefaultValue
            }
            it("expected fullupdating behaviour") {
                let expectedUpdatedValue = ["1obj", "2obj", "10obj", "20obj", "30obj"]
                cleanupState()
                b.callback.fullUpdate.subscribe({ () -> DeleteOrKeep in
                    expect(b.obj.allObjects()) == expectedUpdatedValue
                    return .delete
                })
                expect(b.obj.allObjects()) == expectedDefaultValue
                arr[2] = 10
                arr.append(20)
                arr.append(30)
                expect(b.obj.allObjects()) != expectedDefaultValue // expected broken state before update
                expect(bNoStore.obj.allObjects()) == expectedUpdatedValue
                a.callback.fullUpdate.update()
                expect(b.obj.allObjects()) == expectedUpdatedValue
            }
            it("expected updating behaviour") {
                let expectedUpdatedValue = ["1obj", "2obj", "10obj", "20obj", "30obj"]
                cleanupState()
                b.callback.changes.subscribe({ (_, _, _) -> DeleteOrKeep in
                    expect(b.obj.allObjects()) == expectedUpdatedValue
                    return .delete
                })
                expect(b.obj.allObjects()) == expectedDefaultValue
                arr[2] = 10
                arr.append(20)
                arr.append(30)
                expect(b.obj.allObjects()) != expectedDefaultValue // expected broken state before update
                expect(bNoStore.obj.allObjects()) == expectedUpdatedValue
                a.callback.changes.update(deletions: [], insertions: [3, 4], updates: [2])
                expect(b.obj.allObjects()) == expectedUpdatedValue
            }
        }
        
        context("map0d") {
            let b = a.map0d { (wholeObj) -> String in
                return "count == \(wholeObj.count)"
            }
            let bNoStore = a.map0dWithoutStorage { (wholeObj) -> String in
                return "count == \(wholeObj.count)"
            }
            let expectedDefaultValue = "count == 3"
            it("expected value") {
                cleanupState()
                expect(b.obj.value()) == expectedDefaultValue
            }
            it("expected updating behaviour") {
                let expectedUpdatedValue = "count == 4"
                cleanupState()
                b.callback.fullUpdate.subscribe({ () -> DeleteOrKeep in
                    expect(b.obj.value()) == expectedUpdatedValue
                    return .delete
                })
                expect(b.obj.value()) == expectedDefaultValue
                arr = [1, 2, 10, 20]
                expect(b.obj.value()) == expectedDefaultValue
                expect(bNoStore.obj.value()) == expectedUpdatedValue
                a.callback.fullUpdate.update()
                expect(b.obj.value()) == expectedUpdatedValue
            }
        }
    }
}
