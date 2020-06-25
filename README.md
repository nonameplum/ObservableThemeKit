<p align="center">
   <img width="200" src="https://raw.githubusercontent.com/SvenTiigi/SwiftKit/gh-pages/readMeAssets/SwiftKitLogo.png" alt="ObservableThemeKit Logo">
</p>

<p align="center">
   <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift 5.0">
   </a>
   <a href="http://cocoapods.org/pods/ObservableThemeKit">
      <img src="https://img.shields.io/cocoapods/v/ObservableThemeKit.svg?style=flat" alt="Version">
   </a>
   <a href="http://cocoapods.org/pods/ObservableThemeKit">
      <img src="https://img.shields.io/cocoapods/p/ObservableThemeKit.svg?style=flat" alt="Platform">
   </a>
   <a href="https://github.com/Carthage/Carthage">
      <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage Compatible">
   </a>
   <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="SPM">
   </a>
</p>

# ObservableThemeKit

<p align="center">
ObservableThemeKit framework allows to easily theme an application. It utilizes protocol oriented programming, property wrapper and observable pattern which allows to customize every aspect of a theme specification for your requirements.
</p>


## Features

- [x] Uses property wrappers to easlily access a defined theme
- [x] Allows to observe theme's style changes (it could be anything, it depends on you, e.g. _light_ to _dark_ transition)
- [x] You can define any style (stylesheet) that will be used in the themes

## Example

The example application is the best way to see `ObservableThemeKit` in action. Simply open the `ObservableThemeKit.xcodeproj` and run the `Example` scheme.

## Playground

The playground beyond the example application allows to quickly check the usage of the framework. Simply open `ObservableThemeKit.xcworkspace` and pick `ObservableThemeKitPlayground` from the Xcode's _Project navigator._

### CocoaPods

ObservableThemeKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```bash
pod 'ObservableThemeKit'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

To integrate ObservableThemeKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "nonameplum/ObservableThemeKit"
```

Run `carthage update` to build the framework and drag the built `ObservableThemeKit.framework` into your Xcode project. 

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase” and add the Framework path as mentioned in [Carthage Getting started Step 4, 5 and 6](https://github.com/Carthage/Carthage/blob/master/README.md#if-youre-building-for-ios-tvos-or-watchos)

### Swift Package Manager

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/nonameplum/ObservableThemeKit.git", from: "1.0.0")
]
```

Alternatively navigate to your Xcode project, select `Swift Packages` and click the `+` icon to search for `ObservableThemeKit`.

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate ObservableThemeKit into your project manually. Simply drag the `Sources` Folder into your Xcode project.

## Usage

The best way is to take a look at the [example app](##Example) and the [playground](##Playground).

The main concept of the framework is around the `Theme` protocol:

```swift
public protocol Theme {
    associatedtype Style
    init(stylesheet: Style)
    static var `default`: Self { get }
    static var stylesheet: Observable<Style> { get }
}
```

The idea is to provide a `Style` that will be used by themes e.g:

```swift
struct AppStylesheet {
    let accentColor: UIColor
}
```

Then you can declare the first theme like so:

```swift
struct ViewTheme: Theme {
    static let `default`: ViewController.ViewTheme = .init(stylesheet: AppStylesheet())
    static let stylesheet: Observable = Observable(AppStylesheet())
  
    let labelColor: UIColor

    init(stylesheet: AppStylesheet) {
        self.labelColor = stylesheet.accentColor
    }
}
```

The last step is to use the theme using the `ObservableTheme` _property wrapper_ which gives you freedom that the theme could be used anywhere e.g.:

```swift
class ViewController: UIViewController {
		@ObservableTheme var theme: ViewTheme
}
```

The `theme` can be observed on when the `stylesheet` has changed:

```swift
class ViewController: UIViewController {
		@ObservableTheme var theme: ViewTheme
    override func viewDidLoad() {
        super.viewDidLoad()

        self.$theme.observe(
            owner: self,
            handler: { (owner, _) in
                owner.setupAppearance()
            }
        )
    }
}
```

`ObservableTheme` provides `projectedValue` which is `Observable`.



It is important to mention that the `ViewTheme` implements the `Theme` protocol which means that the `struct` needs to provide

`default`, `stylesheet` `static` properties and the constructor `init` .

It is used by the `ObservableTheme` to instantiate the theme, observe the changes of the `stylesheet` and instantiate the new theme on every change and put it back via mentioned observable `projectedValue` .

Because most of the time this is not useful to have declaration of the theme like so, especially the `stylesheet` property:

```swift
struct ViewTheme: Theme {
    static let `default`: ViewController.ViewTheme = .init(stylesheet: AppStylesheet())
    static let stylesheet: Observable = Observable(AppStylesheet())
		...
}
```

If personally find useful to declare default implementation of the `stylesheet` in the `extension`:

```swift
extension Theme {
    /// Default stylesheet for the convenience
    static var stylesheet: Observable<Stylesheet> {
        return AppStylesheet.shared
    }
}
```

Having that you can then declare a theme:

```swift
struct ViewTheme: Theme {
    static let `default`: ViewController.ViewTheme = .init(stylesheet: Self.stylesheet.wrappedValue)
		...
}
```

But as you will find in the examples, there is a lot of ways how you can provide the `default` and `stylesheet`. It is up to you, it might be singleton, global variable or any other solution that will suit your needs.

## Contributing
Contributions are very welcome 🙌

## License

```
ObservableThemeKit
Copyright (c) 2020 plum sliwinski.lukas@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
