// Copyright © 2020 plum. All rights reserved.

import Foundation

/// An object that allows to observe changes mades to a value that it holds.
@propertyWrapper
public class Observable<T> {
    // MARK: Properties
    private var observers: [ObserverHolder] = []
    private var _value: T
    private let lock = NSRecursiveLock()

    /// The underlying value referenced by the observable.
    public var wrappedValue: T {
        set {
            lock.lock()
            defer { lock.unlock() }

            self._value = newValue
            self.removeObserversThatOwnerDeallocated()
            self.observers.forEach { (holder) in
                holder.handler(newValue)
            }
        }
        get {
            return self._value
        }
    }

    // MARK: Initialization

    /// Creates and returns a new observable with passed initial value
    /// - Parameter value: The initial value
    public init(_ value: T) {
        self._value = value
    }

    // MARK: Observe

    /// Observe (subscribe) to the value changes that returns cancellable
    /// - Parameter handler: An handler that will be called on every value change. It passes the changed value.
    /// - Returns: A cancellable object that allows to stop observation
    @discardableResult
    public func observe(handler: @escaping (T) -> Void) -> ObserverCancellable {
        lock.lock()
        defer { lock.unlock() }

        let uuid = UUID()

        let holder = ObserverHolder(id: .uuid(uuid), handler: handler)
        self.observers.append(holder)

        return ObserverCancellable {
            self.observers.removeAll(where: { $0.id.uuid == uuid })
        }
    }

    /// Observe (subscribe) to the value changes with an owner object that is used to hold the subscription
    /// as long as the owner is not deallocated.
    /// - Parameters:
    ///   - owner: An owner object that is used to keep the observation alive
    ///   - handler: An handler that will be called on each value change. It passes the weakified owner and the value.
    public func observe<O: AnyObject>(owner: O, handler: @escaping (O, T) -> Void) {
        lock.lock()
        defer { lock.unlock() }

        self.observers.append(
            ObserverHolder(id: .owner(WeakBox(value: owner)), handler: { [weak owner] (value) in
                guard let owner = owner
                else { return }
                handler(owner, value)
            })
        )
    }

    // MARK: Private helpers
    private func removeObserversThatOwnerDeallocated() {
        self.observers.removeAll { (holder) in
            if case let .owner(owner) = holder.id {
                return owner.value == nil
            }
            return false
        }
    }
}

extension Observable {
    private struct WeakBox {
        weak var value: AnyObject?
    }

    private struct ObserverHolder {
        enum Identifier {
            case owner(WeakBox)
            case uuid(UUID)

            var uuid: UUID? {
                if case let .uuid(uuid) = self {
                    return uuid
                }
                return nil
            }
        }
        var id: Identifier
        var handler: (T) -> Void
    }
}
