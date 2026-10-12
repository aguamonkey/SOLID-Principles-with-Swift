import XCTest

final class Closed_Principle__OCP__Galactic_ExplorerUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAtlasSelectionAndNextObservation() throws {
        let app = XCUIApplication()
        app.launch()
        let earth = app.buttons["index.Earth"]
        XCTAssertTrue(earth.waitForExistence(timeout: 10))
        let selection = app.staticTexts["selectedEntityName"]
        XCTAssertEqual(selection.label, "Earth")

        attachScreenshot("Atlas — Earth")
        app.buttons["index.Sun"].tap()
        XCTAssertEqual(selection.label, "Sun")
        XCTAssertTrue(app.staticTexts["G-Type"].exists)

        let next = app.buttons["nextObservation"]
        if !next.isHittable { app.swipeUp() }
        next.tap()
        XCTAssertEqual(selection.label, "Halley")
        next.tap()
        XCTAssertEqual(selection.label, "Earth")
    }

    func testAtlasAtAccessibilityTextSize() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        let sun = app.buttons["index.Sun"]
        XCTAssertTrue(app.staticTexts["Orbital\nregister."].waitForExistence(timeout: 10))
        // Lazy grid entries are created as they approach the visible scroll region.
        for _ in 0..<8 {
            if sun.exists && sun.isHittable { break }
            app.swipeUp(velocity: .slow)
        }
        XCTAssertTrue(sun.isHittable)
        sun.tap()
        let selected = app.staticTexts["selectedEntityName"]
        for _ in 0..<6 where !selected.isHittable { app.swipeUp() }
        XCTAssertEqual(selected.label, "Sun")
        attachScreenshot("Atlas — Accessibility text")
    }

    func testExtensionChangesCeresWithoutHidingFailures() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Extension Lab"].tap()
        let ceres = app.staticTexts["lab-row-1"]
        XCTAssertTrue(ceres.waitForExistence(timeout: 10))
        XCTAssertTrue(ceres.label.contains("UNSUPPORTED"))
        attachScreenshot("Extension Lab — Base")
        app.buttons["lab-extension"].tap()
        XCTAssertTrue(ceres.label.contains("ACCEPTED"))
        XCTAssertTrue(ceres.label.contains("Ceres"))
        attachScreenshot("Extension Lab — Extended")
        for _ in 0..<4 where !app.staticTexts["lab-row-3"].isHittable { app.swipeUp() }
        XCTAssertTrue(app.staticTexts["lab-row-2"].label.contains("UNSUPPORTED"))
        XCTAssertTrue(app.staticTexts["lab-row-3"].label.contains("Invalid payload"))
        for _ in 0..<6 where !app.buttons["lab-extension"].isHittable { app.swipeDown() }
        app.buttons["lab-extension"].tap()
        XCTAssertTrue(ceres.label.contains("UNSUPPORTED"))
    }

    func testExtensionLabAtAccessibilityTextSize() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        app.tabBars.buttons["Extension Lab"].tap()
        let button = app.buttons["lab-extension"]
        XCTAssertTrue(button.waitForExistence(timeout: 10))
        for _ in 0..<8 where !button.isHittable { app.swipeUp(velocity: .slow) }
        XCTAssertTrue(button.isHittable)
        button.tap()
        let ceres = app.staticTexts["lab-row-1"]
        for _ in 0..<8 where !ceres.isHittable { app.swipeUp(velocity: .slow) }
        XCTAssertTrue(ceres.label.contains("ACCEPTED"))
        attachScreenshot("Extension Lab — Accessibility text")
    }

    private func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
