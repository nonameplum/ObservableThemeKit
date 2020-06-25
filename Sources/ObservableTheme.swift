// Copyright © 2020 plum. All rights reserved.

import Foundation

@propertyWrapper
public struct ObservableTheme<Value> where Value: Theme {
    private let observableValue: Observable<Value>
    private let stylesheetCancellation: ObserverCancellable?

    public init() {
        let value = Observable(Value.default)
        self.observableValue = value
        self.stylesheetCancellation = Value.stylesheet.observe { [weak value] (newStylesheet) in
            value?.wrappedValue = Value(stylesheet: newStylesheet)
        }
    }

    public var projectedValue: Observable<Value> {
        return self.observableValue
    }

    public var wrappedValue: Value {
        nonmutating set { self.observableValue.wrappedValue = newValue }
        get { return self.observableValue.wrappedValue }
    }
}
