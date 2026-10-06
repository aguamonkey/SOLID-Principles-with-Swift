import XCTest

final class SRP_Example_Angels_and_DemonsUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testBothCollectionsAndFigureSelection() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["figure-michael"].waitForExistence(timeout: 5))
        screenshot("Celestial — Angels index")
        let gabriel = app.buttons["figure-gabriel"]
        scrollTo(gabriel, in: app)
        gabriel.tap()
        expectation(for: NSPredicate(format: "value == %@", "Selected"), evaluatedWith: gabriel)
        waitForExpectations(timeout: 3)
        XCTAssertTrue(app.staticTexts["figure-description"].label.contains("Gabriel"))
        let demons = app.buttons["collection-Demons"]
        scrollTo(demons, in: app)
        demons.tap()
        XCTAssertTrue(app.buttons["figure-lucifer"].waitForExistence(timeout: 5))
        app.swipeDown(velocity: .slow)
        screenshot("Celestial — Demons index")
        let mammon = app.buttons["figure-mammon"]
        scrollTo(mammon, in: app)
        mammon.tap()
        XCTAssertTrue(app.staticTexts["figure-description"].label.contains("Mammon"))
    }

    func testReopeningAnIndexSelectsItsFirstFigure() {
        let app = XCUIApplication()
        app.launch()
        let gabriel = app.buttons["figure-gabriel"]
        XCTAssertTrue(gabriel.waitForExistence(timeout: 5))
        scrollTo(gabriel, in: app)
        gabriel.tap()
        XCTAssertTrue(app.staticTexts["figure-description"].label.contains("Gabriel"))
        let demons = app.buttons["collection-Demons"]
        scrollTo(demons, in: app)
        demons.tap()
        XCTAssertTrue(app.buttons["figure-lucifer"].waitForExistence(timeout: 5))
        app.buttons["collection-Angels"].tap()
        XCTAssertTrue(app.buttons["figure-michael"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["figure-description"].label.contains("Michael"))
    }

    func testSelectionAtAccessibilityTextSize() {
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        let gabriel = app.buttons["figure-gabriel"]
        XCTAssertTrue(gabriel.waitForExistence(timeout: 5))
        scrollTo(gabriel, in: app)
        gabriel.tap()
        let description = app.staticTexts["figure-description"]
        scrollTo(description, in: app)
        XCTAssertTrue(description.label.contains("Gabriel"))
        screenshot("Celestial — Accessibility text")
    }

    private func scrollTo(_ element: XCUIElement, in app: XCUIApplication) {
        let viewport = app.frame.insetBy(dx: 0, dy: 95)
        for _ in 0..<24 {
            if element.exists {
                let frame = element.frame
                if element.isHittable && (viewport.contains(frame) || frame.height > viewport.height && viewport.intersects(frame)) { return }
                let distance = frame.midY - viewport.midY
                let fraction = min(abs(distance) / app.frame.height, 0.4)
                let startY: CGFloat = distance > 0 ? 0.7 : 0.3
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: startY))
                    .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: startY + (distance > 0 ? -fraction : fraction))))
            } else { app.swipeUp(velocity: .slow) }
        }
        XCTAssertTrue(element.isHittable)
    }

    private func screenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
