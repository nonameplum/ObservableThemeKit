// Copyright © 2020 plum. All rights reserved.

import Foundation

/// A type that represents a theme that can be used to configure appearance of UI.
/// - Tag: Theme
public protocol Theme {
    /// A placeholder style type that will be used by a theme
    associatedtype Style
    /// Creates an instance of a theme with given style
    /// - Parameter stylesheet: Style
    init(stylesheet: Style)
    /// Provides the default instance of a theme
    static var `default`: Self { get }
    /// Provides observable style used by a theme
    static var stylesheet: Observable<Style> { get }
}
