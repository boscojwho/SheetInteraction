//
//  SheetInteractionUITests.swift
//  SheetInteractionUITests
//
//  Created by Bosco Ho on 2022-12-28.
//

import XCTest

final class SheetInteractionUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Test initializtion succeeded by opening sheet to largest detent and scrolling table to the bottom.
    func testSheetInit() throws {
        let app = XCUIApplication()
        app.launch()
        if app.navigationBars.element.waitForExistence(timeout: 2) == true {
            app.tables.element.swipeUp(velocity: .fast)
            app.tables.element.swipeUp(velocity: .fast)
            app.tables.element.swipeUp(velocity: .fast)
            app.tables.element.swipeUp(velocity: .fast)
            let element = app.tables.element.cells.element(matching: .cell, identifier: "full")
            waitFor(object: element) { $0.exists }
            XCTAssert(element.exists)
        } else {
            XCTFail()
        }
    }
    
    func testSheetRestsAtFullDetent() throws {
        let app = XCUIApplication()
        app.launch()
        if app.navigationBars.element.waitForExistence(timeout: 2) == true {
            app.tables.element.swipeUp(velocity: .fast)
            app.tables.element.swipeUp(velocity: .fast)
            app.tables.element.swipeUp(velocity: .fast)
            let strutForFullDetent = app.windows.element.otherElements.element(matching: .any, identifier: "struts.fullDetent")
            let navBar = app.navigationBars.element
            XCTAssert(navBar.frame.origin.y == strutForFullDetent.frame.origin.y)
        } else {
            XCTFail()
        }
    }
}

extension XCTestCase {
    
    // Based on https://stackoverflow.com/a/33855219
    func waitFor<T>(object: T, timeout: TimeInterval = 5, file: String = #file, line: Int = #line, expectationPredicate: @escaping (T) -> Bool) {
        let predicate = NSPredicate { obj, _ in
            expectationPredicate(obj as! T)
        }
        expectation(for: predicate, evaluatedWith: object, handler: nil)
        
        waitForExpectations(timeout: timeout) { error in
            if (error != nil) {
                let message = "Failed to fulful expectation block for \(object) after \(timeout) seconds."
                let location = XCTSourceCodeLocation(filePath: file, lineNumber: line)
                let issue = XCTIssue(type: .assertionFailure, compactDescription: message, detailedDescription: nil, sourceCodeContext: .init(location: location), associatedError: nil, attachments: [])
                self.record(issue)
            }
        }
    }
    
}
