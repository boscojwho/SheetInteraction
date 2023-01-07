//
//  UISheetPresentationControllerTests.swift
//  SheetInteraction_SPMTests
//
//  Created by Bosco Ho on 2023-01-07.
//

import XCTest
@testable import SheetInteraction_SPM

final class UISheetPresentationControllerTests: XCTestCase {
    
    private var sheetPresentationController: UISheetPresentationController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let presented = UIViewController()
        let presenting = UIViewController()
        
        let window = UIWindow()
        window.rootViewController = presenting
        
        presenting.loadViewIfNeeded()
        presented.loadViewIfNeeded()
        
        window.addSubview(presenting.view)
        window.addSubview(presented.view)
        
        presented.modalPresentationStyle = .pageSheet
        presented.sheetPresentationController?.detents = [._large()]
        
        guard let sheetPresentationController = presented.sheetPresentationController else {
            XCTFail("sheetPresentationController not found.")
            return
        }
        
        self.sheetPresentationController = sheetPresentationController
        
        presenting.present(presented, animated: false)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSheetWithOneDetent() throws {
        sheetPresentationController.detents = [._large()]
        XCTAssertTrue(sheetPresentationController.identifierForSelectedDetent() == ._large)
        XCTAssertTrue(sheetPresentationController.identifierForSmallestDetent() == ._large)
        XCTAssertTrue(sheetPresentationController.smallestActiveDetent().identifier == ._large)
        XCTAssertTrue(sheetPresentationController.largestActiveDetent().identifier == ._large)
        XCTAssertTrue(sheetPresentationController.identifierForSmallestDetent(active: false) == ._large)
        XCTAssertTrue(sheetPresentationController.detent(withIdentifier: ._large)?.identifier == ._large)
        XCTAssertTrue(sheetPresentationController.detent(withIdentifier: ._small) == nil)
    }
    
    func testSheetWithTwoDetents() throws {
        sheetPresentationController.detents = [._medium(), ._large()]
        XCTAssertTrue(sheetPresentationController.identifierForSelectedDetent() == ._medium)
        sheetPresentationController.selectedDetentIdentifier = ._large
        XCTAssertTrue(sheetPresentationController.identifierForSelectedDetent() == ._large)
        XCTAssertTrue(sheetPresentationController.identifierForSmallestDetent() == ._medium)
        XCTAssertTrue(sheetPresentationController.smallestActiveDetent().identifier == ._medium)
        XCTAssertTrue(sheetPresentationController.largestActiveDetent().identifier == ._large)
        XCTAssertTrue(sheetPresentationController.identifierForSmallestDetent(active: false) == ._medium)
        XCTAssertTrue(sheetPresentationController.detent(withIdentifier: ._medium)?.identifier == ._medium)
        XCTAssertTrue(sheetPresentationController.detent(withIdentifier: ._small) == nil)
    }
    
    func testSheetWithThreeDetents() throws {
        sheetPresentationController.detents = [._small(), ._medium(), ._large()]
        XCTAssertTrue(sheetPresentationController.identifierForSelectedDetent() == ._small)
        sheetPresentationController.selectedDetentIdentifier = ._medium
        XCTAssertTrue(sheetPresentationController.identifierForSelectedDetent() == ._medium)
        XCTAssertTrue(sheetPresentationController.identifierForSmallestDetent() == ._small)
        XCTAssertTrue(sheetPresentationController.smallestActiveDetent().identifier == ._small)
        XCTAssertTrue(sheetPresentationController.largestActiveDetent().identifier == ._large)
        XCTAssertTrue(sheetPresentationController.identifierForSmallestDetent(active: false) == ._small)
        XCTAssertTrue(sheetPresentationController.detent(withIdentifier: ._small)?.identifier == ._small)
        XCTAssertTrue(sheetPresentationController.detent(withIdentifier: ._medSmall) == nil)
    }
    
    func testCompareDetents() throws {
        sheetPresentationController.detents = [._small(), ._medium(), ._large()]
        let small = sheetPresentationController.smallestActiveDetent()
        let large = sheetPresentationController.largestActiveDetent()
        XCTAssertFalse(small.greaterThan(large, in: sheetPresentationController))
        XCTAssertTrue(large.greaterThan(small, in: sheetPresentationController))
        XCTAssertFalse(small.greaterThan(small, in: sheetPresentationController))
    }
    
    func testCompareInactiveDetents() throws {
        let firstInactive = UISheetPresentationController.Detent.custom { context in
            return nil
        }
        let secondInactive = UISheetPresentationController.Detent.custom { context in
            return nil
        }
        sheetPresentationController.detents = [firstInactive, secondInactive, ._large()]
        
        XCTAssertFalse(firstInactive.greaterThan(._large(), in: sheetPresentationController))
        XCTAssertTrue(sheetPresentationController.largestActiveDetent().greaterThan(firstInactive, in: sheetPresentationController))
        XCTAssertFalse(firstInactive.greaterThan(secondInactive, in: sheetPresentationController))
    }
}

extension UISheetPresentationController.Detent.Identifier {
    static let _small: Self = .init("small")
    static let _medSmall: Self = .init("medSmall")
    static let _medium: Self = .init("medium")
    static let _medLarge: Self = .init("medLarge")
    static let _large: Self = .init("large")
    static let _full: Self = .init("full")
}

extension UISheetPresentationController.Detent {
    
    class func _small() -> UISheetPresentationController.Detent {
        .custom(identifier: ._small) { context in
            /// This should not be 0, as the resolutionContext.maximumDetentValue does not appear to account for visual presentation.
            /// We may wish to provide different values here for home button vs home indicator devices.
            56
        }
    }
    
    class func _medSmall() -> UISheetPresentationController.Detent {
        .custom(identifier: ._medSmall) { context in
            context.maximumDetentValue * 0.33
        }
    }
    
    class func _medium() -> UISheetPresentationController.Detent {
        .custom(identifier: ._medium) { context in
            context.maximumDetentValue * 0.5
        }
    }
    
    class func _medLarge() -> UISheetPresentationController.Detent {
        .custom(identifier: ._medLarge) { context in
            context.maximumDetentValue * 0.67
        }
    }
    
    class func _large() -> UISheetPresentationController.Detent {
        .custom(identifier: ._large) { context in
            context.maximumDetentValue * 0.95
        }
    }
    
    class func _full() -> UISheetPresentationController.Detent {
        .custom(identifier: ._full) { context in
            context.maximumDetentValue
        }
    }
}
