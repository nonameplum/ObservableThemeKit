// Copyright © 2020 plum. All rights reserved.

import Foundation

/// An object that provieds action based cancelation.
/// When `cancel` method is called or the object is deallocated, cancel action will be called.
public final class ObserverCancellable {
    private var _cancel: (() -> Void)?


    /// Creates an observer cancellable with a cancel action
    /// - Parameter cancel: A cancel action that will be called on cancel or the object deallocation
    public init(_ cancel: @escaping () -> Void) {
        self._cancel = cancel
    }


    /// Calls underlying cancel action
    public func cancel() {
        self._cancel?()
        self._cancel = nil
    }
    
    deinit {
        cancel()
    }
}
