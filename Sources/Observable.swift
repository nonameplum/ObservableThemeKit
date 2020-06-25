// Copyright © 2020 plum. All rights reserved.

import Foundation

@propertyWrapper
public class Observable<T> {
    // MARK: Properties
    private var observers: [ObserverHolder] = []
    private var _value: T
    private let lock = NSRecursiveLock()

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
    public init(_ value: T) {
        self._value = value
    }

    // MARK: Observe
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
