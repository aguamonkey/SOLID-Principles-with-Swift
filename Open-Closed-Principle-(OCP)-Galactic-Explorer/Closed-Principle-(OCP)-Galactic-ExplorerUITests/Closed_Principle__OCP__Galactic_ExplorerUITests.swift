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

    private func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
