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

    func testEditorialChangeLeavesExportIdentical() {
        let app = XCUIApplication(); app.launch()
        app.tabBars.buttons["Edition Lab"].tap()
        XCTAssertTrue(app.staticTexts["reading-01000000-0000-0000-0000-000000000001"].waitForExistence(timeout: 5))
        screenshot("Edition Lab — Narrative")
        app.buttons["edition-export"].tap()
        let json = app.staticTexts["edition-json"]
        XCTAssertTrue(json.waitForExistence(timeout: 5))
        let before = json.label
        XCTAssertTrue(before.contains("Protection"))
        screenshot("Edition Lab — Export")
        app.buttons["edition-guide"].tap()
        app.buttons["editorial-voice"].tap()
        XCTAssertTrue(app.staticTexts["reading-01000000-0000-0000-0000-000000000001"].label.contains("Order: Archangels"))
        app.buttons["edition-export"].tap()
        XCTAssertEqual(json.label, before)
    }

    func testRefreshUpdatesBothReadersAndOfflineRetainsEdition() {
        let app = XCUIApplication(); app.launch()
        app.tabBars.buttons["Edition Lab"].tap()
        XCTAssertTrue(app.staticTexts["reading-01000000-0000-0000-0000-000000000001"].waitForExistence(timeout: 5))
        let change = app.buttons["edition-switch"]
        scrollTo(change, in: app); change.tap()
        let revision = app.staticTexts["edition-revision"]
        expectation(for: NSPredicate(format: "label CONTAINS %@", "EDITION 2"), evaluatedWith: revision)
        waitForExpectations(timeout: 5)
        let reading = app.staticTexts["reading-01000000-0000-0000-0000-000000000001"]
        scrollTo(reading, in: app)
        XCTAssertTrue(reading.label.contains("Guardianship"))
        let export = app.buttons["edition-export"]
        scrollTo(export, in: app); export.tap()
        let before = app.staticTexts["edition-json"].label
        XCTAssertTrue(before.contains("Guardianship"))
        let connection = app.buttons["edition-connection"]
        scrollTo(connection, in: app); connection.tap()
        XCTAssertTrue(app.staticTexts["edition-warning"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["edition-json"].label, before)
        scrollTo(connection, in: app); connection.tap()
        let refresh = app.buttons["edition-refresh"]
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: refresh)
        waitForExpectations(timeout: 5)
        XCTAssertFalse(app.staticTexts["edition-warning"].exists)
    }

    func testEditionLabAtAccessibilityTextSize() {
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch(); app.tabBars.buttons["Edition Lab"].tap()
        let voice = app.buttons["editorial-voice"]
        XCTAssertTrue(voice.waitForExistence(timeout: 5))
        scrollTo(voice, in: app); voice.tap()
        let reading = app.staticTexts["reading-01000000-0000-0000-0000-000000000001"]
        scrollTo(reading, in: app)
        XCTAssertTrue(reading.label.contains("Order: Archangels"))
        screenshot("Edition Lab — Accessibility text")
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
