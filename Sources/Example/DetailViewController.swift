//
//  DetailViewController.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-04.
//

import UIKit
import SheetInteraction_SPM

class DetailViewController: UIViewController {

    @IBAction func showInfo(_ sender: Any) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = {
            guard let sheet = sheetPresentationController else {
                return "Non-Sheet"
            }
            return sheet.identifierForSelectedDetent().rawValue
        }()
    }
}

extension DetailViewController: SheetInteractionDelegate {
    
    func sheetInteractionChanged(sheetInteraction: SheetInteraction, interactionChange: SheetInteraction.Change) {
        navigationItem.title = interactionChange.approaching.detentIdentifier.rawValue
    }
    
    func sheetInteractionWillEnd(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat) {
        navigationItem.title = targetDetentInfo.detentIdentifier.rawValue
    }
    
    func sheetInteractionDidEnd(sheetInteraction: SheetInteraction, selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier) {
        navigationItem.title = selectedDetentIdentifier.rawValue
    }
}

extension DetailViewController: SheetStackInteractionForwardingBehavior {
    
    func shouldHandleSheetInteraction() -> Bool {
        guard let navigationController else {
            return true
        }
        return navigationController.topViewController == self
    }
}
