// Copyright © 2020 plum. All rights reserved.

import XCTest
import ObservableThemeKit

final class ObservableTest: XCTestCase {

    private var cancelToken: ObserverCancellable?

    func test_observe_deinitedCancellable_shouldStopObservingChanges() {
        let sut = Observable(1)
        var receivedValues: [Int] = []
        var cancellable: ObserverCancellable? = sut.observe(handler: { receivedValues.append($0) })

        sut.wrappedValue = 2

        XCTAssertEqual(receivedValues, [2])

        cancellable = nil

        sut.wrappedValue = 3

        XCTAssertNil(cancellable)
        XCTAssertEqual(receivedValues, [2])
    }

    func test_observe_deinitedOwner_shouldStopObservingChanges() {
        let sut = Observable(1)
        var mockOwner: MockOwner? = MockOwner()
        var receivedValues: [Int] = []
        sut.observe(owner: mockOwner!, handler: { receivedValues.append($0) })

        sut.wrappedValue = 2

        XCTAssertEqual(receivedValues, [2])

        mockOwner = nil

        sut.wrappedValue = 3

        XCTAssertNil(mockOwner)
        XCTAssertEqual(receivedValues, [2])
    }

    func test_wrappedValue_whenInitialValueIsSet_shouldEqualToInitialValue() {
        let sut = makeSut(initialValue: 1)
        XCTAssertEqual(sut.wrappedValue, 1)
    }

    func test_observe_whenWrappedValueChanges_shouldBeCalledOnEachValueChange() {
        var receivedValues: [Int] = []
        let sut = makeSut(initialValue: 0, observe: { receivedValues.append($0) })

        sut.wrappedValue = 1
        sut.wrappedValue = 2
        sut.wrappedValue = 3

        XCTAssertEqual(receivedValues, [1, 2, 3])
    }

    func test_observe_whenInited_shouldNotBeCalled() {
        var callCount = 0
        _ = makeSut(initialValue: 0, observe: { _ in callCount += 1 })

        XCTAssertEqual(callCount, 0)
    }

    func test_concurrentAccess() {
        var receivedValues: [Int] = []
        let sut = makeSut(initialValue: 0, observe: { receivedValues.append($0) })

        DispatchQueue.concurrentPerform(iterations: 100, execute: { (index) in
            sut.wrappedValue = index
        })

        XCTAssertEqual(receivedValues.sorted(), Array(0..<100).sorted())
    }

    // MARK: Helpers
    private func makeSut(
        initialValue: Int,
        observe: @escaping (Int) -> Void = { _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> Observable<Int> {
        let sut = Observable(initialValue)
        self.cancelToken = sut.observe(handler: observe)
        self.trackMemoryLeaks(for: sut, file: file, line: line)
        self.addTeardownBlock { [unowned self] in
            self.cancelToken = nil
        }
        return sut
    }

    private class MockOwner {
    }
}
