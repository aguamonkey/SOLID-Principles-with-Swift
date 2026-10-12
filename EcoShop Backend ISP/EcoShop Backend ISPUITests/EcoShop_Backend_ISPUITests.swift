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

    func testOrderLabWriteSucceedsWhileHistoryIsOffline() {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Order Lab"].tap()
        XCTAssertTrue(labRecord("EC-02", in: app).waitForExistence(timeout: 5))
        app.buttons["lab-connections"].tap()
        app.buttons["lab-history-fault"].tap()
        app.buttons["lab-connections"].tap()
        app.buttons["lab-entry"].tap()
        let submit = app.buttons["lab-submit"]
        scrollTo(submit, in: app)
        submit.tap()
        XCTAssertTrue(app.staticTexts["lab-receipt"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["lab-entry-warning"].exists)
        screenshot("EcoShop — Submission-only receipt")
        let history = app.buttons["lab-history"]
        scrollTo(history, in: app)
        history.tap()
        XCTAssertTrue(app.staticTexts["lab-history-warning"].waitForExistence(timeout: 5))
        XCTAssertTrue(labRecord("EC-02", in: app).exists)
        XCTAssertFalse(labRecord("EC-01", in: app).exists)
        app.buttons["lab-connections"].tap()
        app.buttons["lab-history-fault"].tap()
        app.buttons["lab-connections"].tap()
        let added = labRecord("EC-01", in: app)
        XCTAssertTrue(added.waitForExistence(timeout: 5))
        scrollTo(added, in: app)
        screenshot("EcoShop — Shared order history")
    }

    func testOrderLabRetriesOfflineEntryWithoutDuplicateRecords() {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Order Lab"].tap()
        app.buttons["lab-connections"].tap()
        app.buttons["lab-entry-fault"].tap()
        app.buttons["lab-connections"].tap()
        app.buttons["lab-entry"].tap()
        let submit = app.buttons["lab-submit"]
        scrollTo(submit, in: app)
        submit.tap()
        XCTAssertTrue(app.staticTexts["lab-entry-warning"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["lab-receipt"].exists)
        let controls = app.buttons["lab-connections"]
        scrollTo(controls, in: app)
        controls.tap()
        let restore = app.buttons["lab-entry-fault"]
        scrollTo(restore, in: app)
        restore.tap()
        app.buttons["lab-connections"].tap()
        scrollTo(submit, in: app)
        submit.tap()
        XCTAssertTrue(app.staticTexts["lab-receipt"].waitForExistence(timeout: 5))
        let history = app.buttons["lab-history"]
        scrollTo(history, in: app)
        history.tap()
        XCTAssertTrue(labRecord("EC-01", in: app).waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts.matching(NSPredicate(format: "identifier BEGINSWITH %@", "lab-record-")).count, 2)
    }

    func testOrderLabAtAccessibilityTextSize() {
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        app.tabBars.buttons["Order Lab"].tap()
        let entry = app.buttons["lab-entry"]
        scrollTo(entry, in: app)
        entry.tap()
        let submit = app.buttons["lab-submit"]
        scrollTo(submit, in: app)
        submit.tap()
        let receipt = app.staticTexts["lab-receipt"]
        XCTAssertTrue(receipt.waitForExistence(timeout: 5))
        scrollTo(receipt, in: app)
        screenshot("EcoShop — Accessible submission receipt")
    }

    private func labRecord(_ reference: String, in app: XCUIApplication) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "identifier BEGINSWITH %@ AND label CONTAINS %@", "lab-record-", reference)).firstMatch
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
