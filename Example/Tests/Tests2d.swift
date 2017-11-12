// https://github.com/Quick/Quick

import Quick
import Nimble
import Observed
import LazySeq

class Tests2d: QuickSpec {
    override func spec() {
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
        
        let a = Observed2d(obj: gen)
        func cleanupState() {
            arr = [[1, 2, 3], [40, 50], [600], [7000, 8000]]
            a.callback.fullUpdate.update()
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
            it("expected fullupdating behaviour") {
                let expectedUpdatedValue = [[1.5, 2.5, 3.5, 9.5], [40.5, 50.5, 10.5], [600.5], [7000.5, 8000.5], [123.5]]
                cleanupState()
                b.callback.fullUpdate.subscribe({ () -> DeleteOrKeep in
                    expect(b.obj.equal2d(expectedUpdatedValue)) == true
                    return .delete
                })
                expect(b.obj.equal2d(expectedDefaultValue)) == true
                arr[0].append(9)
                arr[1].append(10)
                arr.append([123])
                expect(b.obj.equal2d(expectedDefaultValue)) == false // expected broken state before update
                expect(bNoStore.obj.equal2d(expectedUpdatedValue)) == true
                a.callback.fullUpdate.update()
                expect(b.obj.equal2d(expectedUpdatedValue)) == true
            }
            it("expected updating behaviour") {
                let expectedUpdatedValue = [[1.5, 2.5, 3.5, 9.5], [40.5, 50.5, 10.5], [600.5], [7000.5, 8000.5], [123.5]]
                cleanupState()
                b.callback.changes.subscribe({ (_, _, _, _, _) -> DeleteOrKeep in
                    expect(b.obj.equal2d(expectedUpdatedValue)) == true
                    return .delete
                })
                expect(b.obj.equal2d(expectedDefaultValue)) == true
                arr[0].append(9)
                arr[1].append(10)
                arr.append([123])
                expect(b.obj.equal2d(expectedDefaultValue)) == false // expected broken state before update
                expect(bNoStore.obj.equal2d(expectedUpdatedValue)) == true
                a.callback.changes.update(deletions: [], insertions: [Index2d(section:0, row: 3), Index2d(section:1, row: 2)], updates: [], sectionDeletions: [], sectionInsertions: [5])
                expect(b.obj.equal2d(expectedUpdatedValue)) == true
            }
            it("expected fullupdating behaviour 2") {
                let expectedUpdatedValue = [[1.5, 2.5, 3.5], [600.5]]
                cleanupState()
                b.callback.fullUpdate.subscribe({ () -> DeleteOrKeep in
                    expect(b.obj.equal2d(expectedUpdatedValue)) == true
                    return .delete
                })
                expect(b.obj.equal2d(expectedDefaultValue)) == true
                arr.remove(at: 1)
                arr.remove(at: 2)
                expect(b.obj.equal2d(expectedDefaultValue)) == false // expected broken state before update
                expect(bNoStore.obj.equal2d(expectedUpdatedValue)) == true
                a.callback.fullUpdate.update()
                expect(b.obj.equal2d(expectedUpdatedValue)) == true
            }
            it("expected updating behaviour 2") {
                let expectedUpdatedValue = [[1.5, 2.5, 3.5], [600.5]]
                cleanupState()
                b.callback.changes.subscribe({ (_, _, _, _, _) -> DeleteOrKeep in
                    print(arr)
                    print(expectedUpdatedValue)
                    expect(b.obj.equal2d(expectedUpdatedValue)) == true
                    return .delete
                })
                expect(b.obj.equal2d(expectedDefaultValue)) == true
                arr.remove(at: 1)
                arr.remove(at: 2)
                expect(b.obj.equal2d(expectedDefaultValue)) == false // expected broken state before update
                expect(bNoStore.obj.equal2d(expectedUpdatedValue)) == true
                a.callback.changes.update(deletions: [], insertions: [], updates: [], sectionDeletions: [1, 3], sectionInsertions: [])
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
            it("expected fullupdating behaviour") {
                let expectedUpdatedValue = [6+9, 90+10, 600, 15000]
                cleanupState()
                b.callback.fullUpdate.subscribe({ () -> DeleteOrKeep in
                    expect(b.obj.allObjects()) == expectedUpdatedValue
                    return .delete
                })
                expect(b.obj.allObjects()) == expectedDefaultValue
                arr[0].append(9)
                arr[1].append(10)
                expect(b.obj.allObjects()) == expectedDefaultValue
                expect(bNoStore.obj.allObjects()) == expectedUpdatedValue
                a.callback.fullUpdate.update()
                expect(b.obj.allObjects()) == expectedUpdatedValue
            }
            it("expected updating behaviour") {
                let expectedUpdatedValue = [6+9, 90+10, 600, 15000]
                cleanupState()
                b.callback.changes.subscribe({ (_, _, _) -> DeleteOrKeep in
                    expect(b.obj.allObjects()) == expectedUpdatedValue
                    return .delete
                })
                expect(b.obj.allObjects()) == expectedDefaultValue
                arr[0].append(9)
                arr[1].append(10)
                expect(b.obj.allObjects()) == expectedDefaultValue
                expect(bNoStore.obj.allObjects()) == expectedUpdatedValue
                a.callback.changes.update(deletions: [], insertions: [Index2d(section:0, row: 3), Index2d(section:1, row: 2)], updates: [], sectionDeletions: [], sectionInsertions: [])
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
            it("expected fullupdating behaviour") {
                let expectedUpdatedValue = 8+2
                cleanupState()
                b.callback.fullUpdate.subscribe({ () -> DeleteOrKeep in
                    expect(b.obj.value()) == expectedUpdatedValue
                    return .delete
                })
                expect(b.obj.value()) == expectedDefaultValue
                arr[0].append(9)
                arr[1].append(10)
                expect(b.obj.value()) == expectedDefaultValue
                expect(bNoStore.obj.value()) == expectedUpdatedValue
                a.callback.fullUpdate.update()
                expect(b.obj.value()) == expectedUpdatedValue
            }

            it("expected updating behaviour") {
                let expectedUpdatedValue = 8+2
                cleanupState()
                b.callback.fullUpdate.subscribe({ () -> DeleteOrKeep in
                    expect(b.obj.value()) == expectedUpdatedValue
                    return .delete
                })
                expect(b.obj.value()) == expectedDefaultValue
                arr[0].append(9)
                arr[1].append(10)
                expect(b.obj.value()) == expectedDefaultValue
                expect(bNoStore.obj.value()) == expectedUpdatedValue
                a.callback.changes.update(deletions: [], insertions: [Index2d(section:0, row: 3), Index2d(section:1, row: 2)], updates: [], sectionDeletions: [], sectionInsertions: [])
                expect(b.obj.value()) == expectedUpdatedValue
            }
})
    }
}
