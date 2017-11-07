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
                    b.observer.fullUpdate.subscribe({ () -> DeleteOrKeep in
                        expect(b.obj.allObjects()) == expectedUpdatedValue
                        return .delete
                    })
                    expect(b.obj.allObjects()) == expectedDefaultValue
                    arr = [1, 2, 10, 20]
                    expect(b.obj.allObjects()) == expectedDefaultValue
                    expect(bNoStore.obj.allObjects()) == expectedUpdatedValue
                    a.observer.fullUpdate.update()
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
                    b.observer.fullUpdate.subscribe({ () -> DeleteOrKeep in
                        expect(b.obj.value()) == expectedUpdatedValue
                        return .delete
                    })
                    expect(b.obj.value()) == expectedDefaultValue
                    arr = [1, 2, 10, 20]
                    expect(b.obj.value()) == expectedDefaultValue
                    expect(bNoStore.obj.value()) == expectedUpdatedValue
                    a.observer.fullUpdate.update()
                    expect(b.obj.value()) == expectedUpdatedValue
                }
            }
        }
        
        describe("2d") {
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
            
            context("map2d", {
                let b = a.map2d { (arg) -> Double in
                    return Double(arg)+0.5
                }
                let bNoStore = a.map2dWithoutStorage { (arg) -> Double in
                    return Double(arg)+0.5
                }
                let expectedDefaultValue = [[1.5, 2.5, 3.5], [40.5, 50.5], [600.5], [7000.5, 8000.5]]
                it("expected value") {
                    cleanupState()
                    expect(b.obj.equal2d(expectedDefaultValue)) == true
                }
                it("expected updating behaviour") {
                    let expectedUpdatedValue = [[1.5, 2.5, 3.5, 9.5], [40.5, 50.5, 10.5], [600.5], [7000.5, 8000.5], [123.5]]
                    cleanupState()
                    b.observer.fullUpdate.subscribe({ () -> DeleteOrKeep in
                        expect(b.obj.equal2d(expectedUpdatedValue)) == true
                        return .delete
                    })
                    expect(b.obj.equal2d(expectedDefaultValue)) == true
                    arr[0].append(9)
                    arr[1].append(10)
                    arr.append([123])
                    expect(b.obj.equal2d(expectedDefaultValue)) == true
                    expect(bNoStore.obj.equal2d(expectedUpdatedValue)) == true
                    a.observer.fullUpdate.update()
                    expect(b.obj.equal2d(expectedUpdatedValue)) == true
                }
            })
            
            context("map1d", {
                let b = a.map1d { (arg) -> Int in
                    return arg.allObjects().reduce(0, { (sum, newElement) -> Int in
                        return sum+newElement
                    })
                }
                let bNoStore = a.map1dWithoutStorage { (arg) -> Int in
                    return arg.allObjects().reduce(0, { (sum, newElement) -> Int in
                        return sum+newElement
                    })
                }
                let expectedDefaultValue = [6, 90, 600, 15000]
                it("expected value") {
                    cleanupState()
                    expect(b.obj.allObjects()) == expectedDefaultValue
                }
                it("expected updating behaviour") {
                    let expectedUpdatedValue = [6+9, 90+10, 600, 15000]
                    cleanupState()
                    b.observer.fullUpdate.subscribe({ () -> DeleteOrKeep in
                        expect(b.obj.allObjects()) == expectedUpdatedValue
                        return .delete
                    })
                    expect(b.obj.allObjects()) == expectedDefaultValue
                    arr[0].append(9)
                    arr[1].append(10)
                    expect(b.obj.allObjects()) == expectedDefaultValue
                    expect(bNoStore.obj.allObjects()) == expectedUpdatedValue
                    a.observer.fullUpdate.update()
                    expect(b.obj.allObjects()) == expectedUpdatedValue
                }
            })
            
            context("map0d", {
                let b = a.map0d { (arg) -> Int in
                    return arg.allObjects().reduce(0, { (sum, seq) -> Int in
                        return sum+seq.count
                    })
                }
                let bNoStore = a.map0dWithoutStorage { (arg) -> Int in
                    return arg.allObjects().reduce(0, { (sum, seq) -> Int in
                        return sum+seq.count
                    })
                }
                let expectedDefaultValue = 8
                it("expected value") {
                    cleanupState()
                    expect(b.obj.value()) == 8
                }
                it("expected updating behaviour") {
                    let expectedUpdatedValue = 8+2
                    cleanupState()
                    b.observer.fullUpdate.subscribe({ () -> DeleteOrKeep in
                        expect(b.obj.value()) == expectedUpdatedValue
                        return .delete
                    })
                    expect(b.obj.value()) == expectedDefaultValue
                    arr[0].append(9)
                    arr[1].append(10)
                    expect(b.obj.value()) == expectedDefaultValue
                    expect(bNoStore.obj.value()) == expectedUpdatedValue
                    a.observer.fullUpdate.update()
                    expect(b.obj.value()) == expectedUpdatedValue
                }
            })
        }
    }
}
