// Copyright © 2020 plum. All rights reserved.

import Foundation

/// A property wrapper type for an observable theme object.
///
/// # Reference:
/// `Theme`
@propertyWrapper
public struct ObservableTheme<Value> where Value: Theme {
    private let observableValue: Observable<Value>
    private let stylesheetCancellation: ObserverCancellable?

    /// Creates an observed theme with initial theme's default value.
    /// Subscribes to the theme's stylesheet to create a new instance of the holded theme on each stylesheet change.
    public init() {
        let value = Observable(Value.default)
        self.observableValue = value
        self.stylesheetCancellation = Value.stylesheet.observe { [weak value] (newStylesheet) in
            value?.wrappedValue = Value(stylesheet: newStylesheet)
        }
    }

    /// An observable to the theme value.
    public var projectedValue: Observable<Value> {
        return self.observableValue
    }

    /// The underlying value referenced by the observable theme variable.
    public var wrappedValue: Value {
        nonmutating set { self.observableValue.wrappedValue = newValue }
        get { return self.observableValue.wrappedValue }
    }
}
