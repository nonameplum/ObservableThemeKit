// Copyright © 2020 plum. All rights reserved.

import XCTest
import ObservableThemeKit

final class ObservableThemeTests: XCTestCase {

    func test_initialization_shouldSetWrappedValue() {
        let sut = makeSUT()

        XCTAssertEqual(sut.wrappedValue.color, UIColor.red)
    }

    func test_projectedValue_observation_shouldCallObservationHandlerWithNewTheme() {
        let sut = makeSUT()

        var receivedTheme: TestTheme?
        withExtendedLifetime(sut.projectedValue.observe(handler: { (theme) in
            receivedTheme = theme
        }), {
            Self.observableStylesheet.wrappedValue = TestStyle(primaryColor: .white)
        })

        XCTAssertEqual(receivedTheme?.color, UIColor.white)
    }

    func test_observationHandler_shouldNotBeCalledAfterSutDeallocation() {
        var sut: ObservableTheme<TestTheme>? = makeSUT()

        withExtendedLifetime(sut!.projectedValue.observe(handler: { (theme) in
            XCTFail("Observation handler shouldn't be called when theme was deallocated")
        }), {
            sut = nil
            Self.observableStylesheet.wrappedValue = TestStyle(primaryColor: .white)
        })
    }

    func test_propertyWrapper_initialization_shouldSetBackgroundColor() {
        let sut = makeViewSUT()

        XCTAssertEqual(sut.backgroundColor, UIColor.red)
        XCTAssertEqual(sut.styleCallCount, 1)
    }

    func test_propertyWrapper_initialization_shouldObserveStyleChanges() {
        let sut = makeViewSUT()

        Self.observableStylesheet.wrappedValue = TestStyle(primaryColor: .white)

        XCTAssertEqual(sut.backgroundColor, UIColor.white)
        XCTAssertEqual(sut.styleCallCount, 2)
    }

    // MARK: Helpers
    private func makeSUT() -> ObservableTheme<TestTheme> {
        let sut = ObservableTheme<TestTheme>()
        return sut
    }

    private func makeViewSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> TestView {
        let sut = TestView()
        trackMemoryLeaks(for: sut, file: file, line: line)
        return sut
    }

    fileprivate struct TestStyle {
        var primaryColor: UIColor = .red
        static var `default` = TestStyle()
    }

    fileprivate static var observableStylesheet = Observable(TestStyle.default)

    fileprivate struct TestTheme: Theme {
        static var `default`: TestTheme = .init(stylesheet: TestStyle.default)

        let color: UIColor
        init(stylesheet: TestStyle) {
            self.color = stylesheet.primaryColor
        }
    }

    fileprivate class TestView: UIView {
        @ObservableTheme var theme: TestTheme
        private var observationCancelation: ObserverCancellable?

        override init(frame: CGRect) {
            super.init(frame: frame)
            self.style()
            self.observationCancelation = self.$theme.observe(handler: { [weak self] _ in
                self?.style()
            })
        }

        required init?(coder: NSCoder) {
            fatalError()
        }

        var styleCallCount: Int = 0

        private func style() {
            self.styleCallCount += 1
            self.backgroundColor = theme.color
        }
    }
}

extension Theme {
    fileprivate static var stylesheet: Observable<ObservableThemeTests.TestStyle> {
        return ObservableThemeTests.observableStylesheet
    }
}
