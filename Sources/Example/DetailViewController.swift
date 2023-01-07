//
//  DetailViewController.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-04.
//

import UIKit
import SheetInteraction_SPM

class DetailViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var editTextField: UIButton!
    @IBAction func stopEditingTextField(_ sender: Any) {
        textField.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = {
            guard let sheet = sheetPresentationController else {
                return "Non-Sheet"
            }
            return sheet.identifierForSelectedDetent().rawValue
        }()
        
        editTextField.alpha = textField.isFirstResponder ? 1 : 0
    }
}

extension DetailViewController: SheetInteractionDelegate {
    
    func sheetInteractionChanged(sheetInteraction: SheetInteraction, interactionChange: SheetInteraction.Change) {
        navigationItem.title = interactionChange.approaching.detentIdentifier.rawValue
    }
    
    func sheetInteractionWillEnd(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat) {
        print(#function)
        navigationItem.title = targetDetentInfo.detentIdentifier.rawValue
    }
    
    func sheetInteractionDidEnd(sheetInteraction: SheetInteraction, selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier) {
        print(#function)
        navigationItem.title = selectedDetentIdentifier.rawValue
    }
    
    func sheetInteraction(sheetInteraction: SheetInteraction, keyboardWillShow fromDetent: UISheetPresentationController.Detent.Identifier) {
        navigationItem.title = fromDetent.rawValue
        editTextField.alpha = 1
    }
    
    func sheetInteraction(sheetInteraction: SheetInteraction, keyboardWillHide toDetent: UISheetPresentationController.Detent.Identifier) {
        navigationItem.title = toDetent.rawValue
        editTextField.alpha = 0
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
