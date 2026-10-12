import XCTest

final class LSPExampleUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testRehearsalRestsAVoiceAndPerformsWithRemainingInstruments() {
        let app = XCUIApplication()
        app.launch()
        let flute = app.buttons["instrument.Flute"]
        XCTAssertTrue(flute.waitForExistence(timeout: 10))
        attachScreenshot("Orchestra — Rehearsal score")
        flute.tap()
        XCTAssertEqual(flute.value as? String, "Resting")
        let perform = app.buttons["performConcert"]
        scrollTo(perform, in: app)
        perform.tap()
        let first = app.staticTexts["response.0"]
        let second = app.staticTexts["response.1"]
        scrollTo(second, in: app)
        XCTAssertTrue(first.label.contains("Violin"))
        XCTAssertTrue(second.label.contains("Trumpet"))
        XCTAssertFalse(app.staticTexts["response.2"].exists)
        attachScreenshot("Orchestra — Ensemble response")
    }

    func testEmptyEnsembleDisablesTheCue() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["instrument.Violin"].waitForExistence(timeout: 10))
        for name in ["Violin", "Flute", "Trumpet"] {
            let button = app.buttons["instrument.\(name)"]
            scrollTo(button, in: app)
            button.tap()
        }
        let perform = app.buttons["performConcert"]
        scrollTo(perform, in: app)
        XCTAssertFalse(perform.isEnabled)
        XCTAssertTrue(app.staticTexts["ensembleCount"].label.contains("0 voices"))
    }

    func testRehearsalAtAccessibilityTextSize() {
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.staticTexts["rehearsalHeading"].waitForExistence(timeout: 10))
        let flute = app.buttons["instrument.Flute"]
        scrollTo(flute, in: app)
        flute.tap()
        XCTAssertEqual(flute.value as? String, "Resting")
        let perform = app.buttons["performConcert"]
        scrollTo(perform, in: app)
        perform.tap()
        let response = app.staticTexts["response.0"]
        scrollTo(response, in: app)
        XCTAssertTrue(response.label.contains("Violin"))
        attachScreenshot("Orchestra — Accessibility text")
    }

    func testAsyncLabDistinguishesUnavailableFromBrokenContract() {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Async Lab"].tap()
        let unavailable = app.buttons["cue-source-Unavailable"]
        scrollTo(unavailable, in: app)
        unavailable.tap()
        performAsync(in: app)
        let allowed = app.staticTexts["UNAVAILABLE / CONTRACT HONOURED"]
        XCTAssertTrue(allowed.waitForExistence(timeout: 10))
        let flute = app.staticTexts["async-report.Flute"]
        scrollTo(flute, in: app)
        XCTAssertTrue(flute.label.contains("unavailable"))
        attachScreenshot("Orchestra — Allowed unavailable outcome")
        let broken = app.buttons["cue-source-Broken adapter"]
        scrollTo(broken, in: app)
        broken.tap()
        performAsync(in: app)
        XCTAssertTrue(app.staticTexts["CONTRACT VIOLATION DETECTED"].waitForExistence(timeout: 10))
        scrollTo(flute, in: app)
        XCTAssertEqual(flute.label, "Wrong cue identity.")
        XCTAssertTrue(app.staticTexts["async-report.Violin"].label.contains("answers"))
        attachScreenshot("Orchestra — Wrong cue rejected")
    }

    func testAsyncCueCanBeCancelledAndPerformedAgain() {
        let app = XCUIApplication()
        app.launchEnvironment["ASYNC_CUE_SLOW_INPUT"] = "1"
        app.launch()
        app.tabBars.buttons["Async Lab"].tap()
        performAsync(in: app)
        let cancel = app.buttons["async-cancel"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 2))
        scrollTo(cancel, in: app)
        cancel.tap()
        XCTAssertTrue(app.staticTexts["CUE CANCELLED"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["async-report.Flute"].exists)
        performAsync(in: app)
        XCTAssertTrue(app.staticTexts["REHEARSAL COMPLETE"].waitForExistence(timeout: 15))
        let flute = app.staticTexts["async-report.Flute"]
        scrollTo(flute, in: app)
        XCTAssertTrue(flute.label.contains("measured rest"))
    }

    func testAsyncContractLabAtAccessibilityTextSize() {
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        app.tabBars.buttons["Async Lab"].tap()
        let broken = app.buttons["cue-source-Broken adapter"]
        scrollTo(broken, in: app)
        broken.tap()
        performAsync(in: app)
        let flute = app.staticTexts["async-report.Flute"]
        XCTAssertTrue(flute.waitForExistence(timeout: 10))
        scrollTo(flute, in: app)
        XCTAssertEqual(flute.label, "Wrong cue identity.")
        attachScreenshot("Orchestra — Accessible contract report")
    }

    private func performAsync(in app: XCUIApplication) {
        let perform = app.buttons["async-perform"]
        scrollTo(perform, in: app)
        perform.tap()
    }

    private func scrollTo(_ element: XCUIElement, in app: XCUIApplication) {
        // A partly visible large-text button can be hittable while its centre is
        // obscured. Bring the full control into the safe viewport before tapping.
        let viewport = app.frame.insetBy(dx: 0, dy: 90)
        for _ in 0..<20 {
            if element.exists {
                let frame = element.frame
                if viewport.contains(frame) && element.isHittable { return }
                let distance = frame.midY - viewport.midY
                let fraction = min(abs(distance) / app.frame.height, 0.35)
                let startY: CGFloat = distance > 0 ? 0.7 : 0.3
                let endY = startY + (distance > 0 ? -fraction : fraction)
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: startY))
                    .press(forDuration: 0.05, thenDragTo:
                        app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: endY)))
            } else {
                app.swipeUp(velocity: .slow)
            }
        }
        XCTAssertTrue(element.isHittable)
    }

    private func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
