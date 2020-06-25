import UIKit
import PlaygroundSupport
import ObservableThemeKit

PlaygroundPage.current.needsIndefiniteExecution = true

struct Stylesheet {
    enum Appearance {
        case dark
        case light
        var isDark: Bool { self == .dark }
    }

    let appearance: Appearance

    init(appearance: Appearance) {
        self.appearance = appearance
    }

    enum FontType {
        case heading1
        case regular
    }

    public enum ColorType {
        case background
        case primary
    }

    func font(for type: FontType) -> UIFont {
        switch type {
        case .heading1:
            return UIFont.systemFont(ofSize: 18, weight: .semibold)
        case .regular:
            return UIFont.systemFont(ofSize: 14, weight: .regular)
        }
    }

    func color(type: ColorType) -> UIColor {
        switch type {
        case .background:
            return appearance.isDark ? .black : .white
        case .primary:
            return appearance.isDark ? .white : .black
        }
    }
}

class ResourceKit {
    static var stylesheet: Observable<Stylesheet> = Observable(Stylesheet(appearance: .light))
}

extension Theme {
    static var stylesheet: Observable<Stylesheet> {
        return ResourceKit.stylesheet
    }
}

class View: UIView {
    @ObservableTheme var theme: ViewTheme
    private var observationCancelation: ObserverCancellable?
    private let button: UIButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.style()
        self.observationCancelation = self.$theme.observe(handler: { [weak self] _ in
            self?.style()
        })

        self.addSubview(self.button)
        self.button.setTitle("Change appearance", for: .normal)
        self.button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
    }

    @objc private func handleButtonTap() {
        if ResourceKit.stylesheet.wrappedValue.appearance.isDark {
            ResourceKit.stylesheet.wrappedValue = .init(appearance: .light)
        } else {
            ResourceKit.stylesheet.wrappedValue = .init(appearance: .dark)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.button.frame = self.bounds.insetBy(dx: 30, dy: 10)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func style() {
        self.backgroundColor = theme.backgroundColor
        self.button.setTitleColor(theme.buttonTitleColor, for: .normal)
    }
}

extension View {
    struct ViewTheme: Theme {
        static var `default`: ViewTheme = .init(stylesheet: Self.stylesheet.wrappedValue)

        let backgroundColor: UIColor
        let buttonTitleColor: UIColor

        init(stylesheet: Stylesheet) {
            self.backgroundColor = stylesheet.color(type: .background)
            self.buttonTitleColor = stylesheet.color(type: .primary)
        }
    }
}

ResourceKit.stylesheet.wrappedValue = .init(appearance: .light)

var view = View(frame: CGRect(x: 0, y: 0, width: 300, height: 300))

PlaygroundPage.current.liveView = view
