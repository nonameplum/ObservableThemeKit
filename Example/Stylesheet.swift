// Copyright © 2020 plum. All rights reserved.

import UIKit
import ObservableThemeKit

// MARK: - Stylesheet

/// For the sake of the example Stylesheet represents what kind of the Style type, the Theme could hold
struct Stylesheet {

    fileprivate static var shared: Observable<Stylesheet> = .init(Stylesheet(appearance: .light))

    let appearance: Appearance
    let primaryColor: UIColor
    let backgroundColor: UIColor

    init(appearance: Appearance) {
        self.appearance = appearance

        switch appearance {
        case .light:
            self.primaryColor = .black
            self.backgroundColor = .white
        case .dark:
            self.primaryColor = .white
            self.backgroundColor = .darkGray
        }
    }

    func font(with type: FontType) -> UIFont {
        switch type {
        case .header:
            return UIFont.systemFont(ofSize: 16, weight: .semibold)
        case .normal:
            return UIFont.systemFont(ofSize: 14, weight: .regular)
        case .small:
            return UIFont.systemFont(ofSize: 10, weight: .regular)
        }
    }
}

// MARK: - Stylesheet helpers

extension Stylesheet {

    /// Change shared stylesheet using the new appearance
    static func changeAppearance(to appearance: Appearance) {
        Self.shared.wrappedValue = Stylesheet(appearance: appearance)
    }

    /// Currently used appearance in the stylesheet
    static var appearance: Appearance {
        return Self.shared.wrappedValue.appearance
    }

    /// Currently set stylesheet
    static var current: Stylesheet {
        return Self.shared.wrappedValue
    }
}

// MARK: - Stylesheet types

extension Stylesheet {

    enum Appearance {
        case light
        case dark
    }

    enum FontType {
        case header
        case normal
        case small
    }
}

// MARK: - Theme default implementation

extension Theme {

    /// Default stylesheet for the convenience
    static var stylesheet: Observable<Stylesheet> {
        return Stylesheet.shared
    }
}
