// Copyright © 2020 plum. All rights reserved.

import Foundation

public protocol Theme {
    associatedtype Style
    init(stylesheet: Style)
    static var `default`: Self { get }
    static var stylesheet: Observable<Style> { get }
}
