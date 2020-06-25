// Copyright © 2020 plum. All rights reserved.

import XCTest

extension XCTestCase {
    func trackMemoryLeaks(for object: AnyObject?, file: StaticString = #file, line: UInt = #line) {
        self.addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Expected deallocated object, got \(object!) instead", file: file, line: line)
        }
    }
}
