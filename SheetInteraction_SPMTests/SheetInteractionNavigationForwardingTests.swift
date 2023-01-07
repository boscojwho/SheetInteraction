//
//  SheetInteractionNavigationForwardingTests.swift
//  SheetInteraction_SPMTests
//
//  Created by Bosco Ho on 2023-01-07.
//

import XCTest
@testable import SheetInteraction_SPM

final class SheetInteractionNavigationForwardingTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNavigationForwarding() throws {
        let vc1 = XCTestExpectation(description: "Called third")
        vc1.expectedFulfillmentCount = 4
        let vc2 = XCTestExpectation(description: "Called second")
        vc2.expectedFulfillmentCount = 4
        let vc3 = XCTestExpectation(description: "Called first")
        vc3.expectedFulfillmentCount = 4
        let vcs: [MockSheetInteractionNavigationForwardingViewController] = (1...3).compactMap {
            let vc = MockSheetInteractionNavigationForwardingViewController()
            vc.accessibilityLabel = $0.description
            vc.callback = { index in
                if index == 3 {
                    vc3.fulfill()
                }
                if index == 2 {
                    vc2.fulfill()
                }
                if index == 1 {
                    vc1.fulfill()
                }
            }
            return vc
        }
        
        let nc1 = XCTestExpectation(description: "Called fourth (last).")
        nc1.expectedFulfillmentCount = 4
        let nc = MockSheetInteractionNavigationForwardingNavigationController(rootViewController: vcs.first!)
        nc.accessibilityLabel = "0"
        nc.setViewControllers(vcs, animated: false)
        nc.callback = { _ in
            nc1.fulfill()
        }
        
        let mockSheet = UISheetPresentationController.mockInit()
        let mockSheetView = UIView()
        let mockSheetInteraction = SheetInteraction(sheet: mockSheet, sheetView: mockSheetView)
        let forwarding = SheetInteractionNavigationForwarding(navigationController: nc)
        forwarding?.sheetInteractionBegan(sheetInteraction: mockSheetInteraction, at: ._medium)
        forwarding?.sheetInteractionChanged(sheetInteraction: mockSheetInteraction, interactionChange: .init(isMinimizing: false, isOverscrolling: false, closest: .init(detentIdentifier: ._medium, distance: 0), approaching: .init(detentIdentifier: ._medium, distance: 0), preceding: .init(detentIdentifier: ._medium, distance: 0), percentageTotal: -1, percentageApproaching: -1, percentagePreceding: -1))
        forwarding?.sheetInteractionWillEnd(sheetInteraction: mockSheetInteraction, targetDetentInfo: .init(detentIdentifier: ._medium, distance: 0), targetPercentageTotal: -1, onTouchUpPercentageTotal: -1)
        forwarding?.sheetInteractionDidEnd(sheetInteraction: mockSheetInteraction, selectedDetentIdentifier: ._medium)
        
        let result = XCTWaiter().wait(for: [vc3, vc2, vc1, nc1], timeout: 10, enforceOrder: true)
        XCTAssertEqual(result, .completed)
    }
}

fileprivate extension UISheetPresentationController {
    
    class func mockInit() -> UISheetPresentationController {
        UISheetPresentationController.init(presentedViewController: .init(), presenting: .init())
    }
}

final class MockSheetInteractionNavigationForwardingNavigationController: UINavigationController, SheetInteractionDelegate, SheetStackInteractionForwardingBehavior {
    
    var callback: ((Int) -> Void)?
    
    func shouldHandleSheetInteraction() -> Bool {
        return true
    }
    
    func sheetInteractionBegan(sheetInteraction: SheetInteraction, at detent: DetentIdentifier) {
        print(#function, Int(accessibilityLabel!)!)
        callback?(Int(accessibilityLabel!)!)
    }
    
    func sheetInteractionChanged(sheetInteraction: SheetInteraction, interactionChange: SheetInteraction.Change) {
        print(#function, Int(accessibilityLabel!)!)
        callback?(Int(accessibilityLabel!)!)
    }
    
    func sheetInteractionWillEnd(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat) {
        print(#function, Int(accessibilityLabel!)!)
        callback?(Int(accessibilityLabel!)!)
    }
    
    func sheetInteractionDidEnd(sheetInteraction: SheetInteraction, selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier) {
        print(#function, Int(accessibilityLabel!)!)
        callback?(Int(accessibilityLabel!)!)
    }
    
}

final class MockSheetInteractionNavigationForwardingViewController: UIViewController, SheetInteractionDelegate, SheetStackInteractionForwardingBehavior {
    
    var callback: ((Int) -> Void)?
    
    func shouldHandleSheetInteraction() -> Bool {
        return true
    }
    
    func sheetInteractionBegan(sheetInteraction: SheetInteraction, at detent: DetentIdentifier) {
        print(#function, Int(accessibilityLabel!)!)
        callback?(Int(accessibilityLabel!)!)
    }
    
    func sheetInteractionChanged(sheetInteraction: SheetInteraction, interactionChange: SheetInteraction.Change) {
        print(#function, Int(accessibilityLabel!)!)
        callback?(Int(accessibilityLabel!)!)
    }
    
    func sheetInteractionWillEnd(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat) {
        print(#function, Int(accessibilityLabel!)!)
        callback?(Int(accessibilityLabel!)!)
    }
    
    func sheetInteractionDidEnd(sheetInteraction: SheetInteraction, selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier) {
        print(#function, Int(accessibilityLabel!)!)
        callback?(Int(accessibilityLabel!)!)
    }
}
