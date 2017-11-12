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
            it("expected updating behaviour") {
                let expectedUpdatedValue = ["1obj", "2obj", "10obj", "20obj"]
                cleanupState()
                b.callback.fullUpdate.subscribe({ () -> DeleteOrKeep in
                    expect(b.obj.allObjects()) == expectedUpdatedValue
                    return .delete
                })
                expect(b.obj.allObjects()) == expectedDefaultValue
                arr = [1, 2, 10, 20]
                expect(b.obj.allObjects()) == expectedDefaultValue
                expect(bNoStore.obj.allObjects()) == expectedUpdatedValue
                a.callback.fullUpdate.update()
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
