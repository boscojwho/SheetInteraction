//
//  ViewController.swift
//  TestModal
//
//  Created by BozBook Air on 2022-11-21.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func showModal(_ sender: Any) {
        let nc = storyboard!.instantiateViewController(withIdentifier: "navCon")
        nc.modalPresentationStyle = .pageSheet
//        nc.isModalInPresentation = true
        nc.sheetPresentationController?.delegate = self
        let small = UISheetPresentationController.Detent.custom(identifier: .init(rawValue: "small")) { context in
            return 120
        }
        let large = UISheetPresentationController.Detent.custom(identifier: .init(rawValue: "large")) { context in
            return context.maximumDetentValue * 0.98
        }
        nc.sheetPresentationController?.detents = [
            small, .medium(), large
        ]
        /// Set undimmed to allow pass-through interaction on presenting view controller.
        nc.sheetPresentationController?.largestUndimmedDetentIdentifier = .init(rawValue: "large")
        present(nc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}


extension ViewController: UISheetPresentationControllerDelegate {
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
    
    func presentationController(_ presentationController: UIPresentationController, prepare adaptivePresentationController: UIPresentationController) {
        print(#function)
    }
    
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        print(sheetPresentationController.selectedDetentIdentifier)
    }
}
