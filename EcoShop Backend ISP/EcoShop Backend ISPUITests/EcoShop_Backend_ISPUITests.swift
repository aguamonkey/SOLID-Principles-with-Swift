import XCTest

final class EcoShop_Backend_ISPUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testCatalogAndStockroomShareEdits() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["product-EC-01"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["add-entry"].exists)
        screenshot("EcoShop — Goods ledger")
        app.tabBars.buttons["Stockroom"].tap()
        XCTAssertTrue(app.buttons["edit-EC-01"].waitForExistence(timeout: 5))
        screenshot("EcoShop — Stockroom")
        app.buttons["edit-EC-01"].tap()
        let name = app.textFields["entry-name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: "Market tote".count) + "Everyday tote")
        app.buttons["save-entry"].tap()
        XCTAssertTrue(app.tabBars.buttons["Goods"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Goods"].tap()
        let row = app.staticTexts["product-EC-01"]
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        XCTAssertTrue(row.label.contains("Everyday tote"))
    }

    func testAddValidationAndRemove() {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Stockroom"].tap()
        app.buttons["add-entry"].tap()
        app.buttons["save-entry"].tap()
        XCTAssertTrue(app.staticTexts["Enter a valid price of zero or more, such as 12.50."].exists)
        for (id, text) in [("entry-name", "Lunch tin"), ("entry-description", "Steel / for everyday lunches"), ("entry-price", "18.50")] {
            let field = app.textFields[id]
            if field.exists { field.tap(); field.typeText(text) }
            else { let editor = app.textViews[id]; editor.tap(); editor.typeText(text) }
        }
        app.buttons["save-entry"].tap()
        let remove = app.buttons["Remove Lunch tin"]
        scrollTo(remove, in: app)
        remove.tap()
        app.buttons["Remove entry"].tap()
        app.tabBars.buttons["Goods"].tap()
        XCTAssertTrue(app.staticTexts["product-EC-01"].waitForExistence(timeout: 5))
        let removed = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Lunch tin")).firstMatch
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: removed)
        waitForExpectations(timeout: 5)
    }

    func testSupportingBooks() {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Orders"].tap()
        XCTAssertTrue(app.staticTexts["ORD-001"].waitForExistence(timeout: 5))
        screenshot("EcoShop — Orders")
        app.tabBars.buttons["Reviews"].tap()
        XCTAssertTrue(app.staticTexts["Always by the door"].waitForExistence(timeout: 5))
        screenshot("EcoShop — Reviews")
    }

    func testCatalogAtAccessibilityTextSize() {
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        let row = app.staticTexts["product-EC-01"]
        XCTAssertTrue(row.waitForExistence(timeout: 10))
        scrollTo(row, in: app)
        XCTAssertTrue(row.label.contains("Market tote"))
        screenshot("EcoShop — Accessibility text")
        app.tabBars.buttons["Stockroom"].tap()
        let add = app.buttons["add-entry"]
        scrollTo(add, in: app)
        add.tap()
        XCTAssertTrue(app.textFields["entry-name"].waitForExistence(timeout: 5))
    }

    func testEmptyRegisterAfterRemovingAllGoods() {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Stockroom"].tap()
        for id in ["EC-01", "EC-02", "EC-03"] {
            let remove = app.buttons["remove-\(id)"]
            scrollTo(remove, in: app)
            remove.tap()
            app.buttons["Remove entry"].tap()
            expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: remove)
            waitForExpectations(timeout: 5)
        }
        XCTAssertTrue(app.staticTexts["No goods yet. Start the register with an entry."].waitForExistence(timeout: 5))
        app.tabBars.buttons["Goods"].tap()
        XCTAssertTrue(app.staticTexts["The shelves are empty. Add your first goods in the Stockroom."].waitForExistence(timeout: 5))
        screenshot("EcoShop — Empty register")
    }

    private func scrollTo(_ element: XCUIElement, in app: XCUIApplication) {
        let viewport = app.frame.insetBy(dx: 0, dy: 100)
        for _ in 0..<20 {
            if element.exists {
                let frame = element.frame
                if element.isHittable && (viewport.contains(frame) || frame.height > viewport.height && viewport.contains(CGPoint(x: frame.midX, y: frame.midY))) { return }
                let distance = frame.midY - viewport.midY
                let fraction = min(abs(distance) / app.frame.height, 0.35)
                let startY: CGFloat = distance > 0 ? 0.7 : 0.3
                let endY = startY + (distance > 0 ? -fraction : fraction)
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: startY))
                    .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: endY)))
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
