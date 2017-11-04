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
    }
}
