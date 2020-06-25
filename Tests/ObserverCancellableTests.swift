// Copyright © 2020 plum. All rights reserved.

import XCTest
import ObservableThemeKit

final class ObserverCancellableTests: XCTestCase {

    func test_cancel_withCancellationClosure_shouldCallCancellationClosure() {
        expect(cancelCallCount: 1, when: { sut in
            sut?.cancel()
            sut?.cancel()
        })
    }

    func test_tokenDeallocation_withCancellationClosure_shouldCallCancellationClosure() {
        expect(cancelCallCount: 1, when: { sut in
            sut = nil
        })
    }

    // MARK: Helpers
    private func expect(
        cancelCallCount: Int,
        when action: (inout ObserverCancellable?) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedCancelCount: Int = 0
        var sut: ObserverCancellable? = ObserverCancellable({ receivedCancelCount += 1 })
        self.trackMemoryLeaks(for: sut)

        action(&sut)

        XCTAssertEqual(
            receivedCancelCount,
            cancelCallCount,
            "Expected cancel call count \(cancelCallCount), got \(receivedCancelCount) instead.",
            file: file,
            line: line
        )
    }
}
