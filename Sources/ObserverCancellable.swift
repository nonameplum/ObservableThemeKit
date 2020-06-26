// Copyright © 2020 plum. All rights reserved.

import Foundation

public final class ObserverCancellable {
    private var _cancel: (() -> Void)?

    public init(_ cancel: @escaping () -> Void) {
        self._cancel = cancel
    }

    public func cancel() {
        self._cancel?()
        self._cancel = nil
    }

    deinit {
        cancel()
    }
}
