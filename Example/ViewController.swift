// Copyright © 2020 plum. All rights reserved.

import ObservableThemeKit
import UIKit

// MARK: - ViewController

/// The ViewController
class ViewController: UIViewController {

    // MARK: Properties

    /// Theme
    @ObservableTheme var theme: ViewTheme

    /// Button
    lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Change appearance", for: .normal)
        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        return button
    }()

    // MARK: View-Lifecycle

    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAppearance()

        self.$theme.observe(
            owner: self,
            handler: { (owner, _) in
                owner.setupAppearance()
            }
        )
    }

    /// Load view
    override func loadView() {
        self.view = self.button
    }

    // MARK: Helpers

    /// Setup appearance
    private func setupAppearance() {
        self.button.setTitleColor(theme.labelColor, for: .normal)
        self.button.titleLabel?.font = theme.buttonFont
        self.view.backgroundColor = theme.backgroundColor
    }

    /// Handle button tap
    @objc private func handleButtonTap() {
        if Stylesheet.appearance == .light {
            Stylesheet.changeAppearance(to: .dark)
        } else {
            Stylesheet.changeAppearance(to: .light)
        }
    }
}

// MARK: - ViewTheme

extension ViewController {

    /// Theme for the ViewController
    struct ViewTheme: Theme {
        static let `default`: ViewController.ViewTheme = .init(stylesheet: Self.stylesheet.wrappedValue)

        let labelColor: UIColor
        let backgroundColor: UIColor
        let buttonFont: UIFont

        init(stylesheet: Stylesheet) {
            self.labelColor = stylesheet.primaryColor
            self.backgroundColor = stylesheet.backgroundColor
            self.buttonFont = stylesheet.font(with: .header)
        }
    }
}
