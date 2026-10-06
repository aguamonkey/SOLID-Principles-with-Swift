import XCTest

final class ModularNetworkServiceExampleUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testSampleAndOfflineInputsUseTheReceiver() {
        let app = XCUIApplication()
        app.launch()
        receive(in: app)
        XCTAssertTrue(app.staticTexts["RECEIVED"].waitForExistence(timeout: 5))
        app.swipeDown(velocity: .slow)
        screenshot("Network — Received signal")
        let offline = app.buttons["source-Offline"]
        scrollTo(offline, in: app)
        offline.tap()
        receive(in: app)
        XCTAssertTrue(app.staticTexts["NO SIGNAL"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["receiver-message"].label.contains("Input disconnected"))
        app.swipeDown(velocity: .slow)
        screenshot("Network — Disconnected input")
        let sample = app.buttons["source-Sample"]
        scrollTo(sample, in: app)
        sample.tap()
        receive(in: app)
        XCTAssertTrue(app.staticTexts["RECEIVED"].waitForExistence(timeout: 5))
    }

    func testDelayedReceptionCanBeCancelledAndRetried() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["source-Delayed"].tap()
        receive(in: app)
        let cancel = app.buttons["cancel-reception"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 2))
        cancel.tap()
        XCTAssertTrue(app.staticTexts["CANCELLED"].waitForExistence(timeout: 2))
        receive(in: app)
        XCTAssertTrue(app.staticTexts["RECEIVED"].waitForExistence(timeout: 6))
    }

    func testSwitchingSourceDuringReceptionResetsReceiver() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["source-Delayed"].tap()
        receive(in: app)
        let sample = app.buttons["source-Sample"]
        scrollTo(sample, in: app)
        sample.tap()
        XCTAssertTrue(app.staticTexts["STANDBY"].waitForExistence(timeout: 5))
        receive(in: app)
        XCTAssertTrue(app.staticTexts["RECEIVED"].waitForExistence(timeout: 5))
    }

    func testReceiverAtAccessibilityTextSize() {
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        receive(in: app)
        let message = app.staticTexts["receiver-message"]
        scrollTo(message, in: app)
        XCTAssertTrue(message.label.contains("The source can change"))
        screenshot("Network — Accessibility receiver")
    }

    private func receive(in app: XCUIApplication) {
        let button = app.buttons["receive"]
        scrollTo(button, in: app)
        button.tap()
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
