//
//  TableViewController.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-02.
//

import UIKit

extension UINavigationController {
    
    func isRootModal() -> Bool {
        return levelInModalHierarchy() == 0
    }
    
    func levelInModalHierarchy() -> Int {
        var level = 0
        var presenting = presentingViewController
        while presenting is UINavigationController {
            presenting = presenting?.presentingViewController
            level += 1
        }
        return level
    }
}

class TableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func showModal(_ sender: Any) {
        showModalSheet(animated: true)
    }
    
    @IBAction func dismiss(_ sender: Any) {
        guard navigationController?.isRootModal() == false else {
            return
        }
        presentingViewController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vcIndex = navigationController?.viewControllers.firstIndex(of: self) {
            let ncIndex = navigationController?.levelInModalHierarchy() ?? 0
            navigationItem.title = "Modal \(ncIndex).\(vcIndex)"
        }
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// Ensure we use view that contains navigation bar, if sheet stack is embedded in a navigation controller.
        if let sheetPresentationController, let window = view.window, let sheetView = navigationController?.view {
            ///  Use both view origin and size to determine detent state.
            ///  Determine whch direction sheet is moving?
            ///  - Can't use touch events in here or in navigation controller because those get cancelled.
            
            let frame = sheetView.convert(sheetView.frame, to: window)
//            print(#function, "origin: \(frame.origin)", "size: \(frame.size)")
            if frame.height < sheetPresentationController.topSheetInsets.bottom + 100 {
                UIView.animate(withDuration: 0.3) {
                    self.tableView.alpha = 0
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.tableView.alpha = 1
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        super.touchesCancelled(touches, with: event)
    }
}

extension TableViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print(#function)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print(#function)
    }
        
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print(#function)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(#function)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print(#function)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(#function)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print(#function)
    }
}

extension TableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }
}

extension TableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TableViewController: UISheetPresentationControllerDelegate {
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        guard navigationController?.isRootModal() == false else {
            return false
        }
        return true
    }
    
    func presentationController(_ presentationController: UIPresentationController, prepare adaptivePresentationController: UIPresentationController) {
        print(#function)
    }
    
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        print(sheetPresentationController.selectedDetentIdentifier ?? sheetPresentationController.detents.first!)
    }
}

extension TableViewController: SheetInteractionDelegate {
    
    func sheetInteractionChanged(info: SheetInteractionInfo) {
        if let delegate = presentingViewController as? SheetInteractionDelegate {
            delegate.sheetInteractionChanged(info: info)
        }
    }
    
    func sheetInteractionEnded(targetDetent: SheetInteractionInfo.Change) {
        if let delegate = presentingViewController as? SheetInteractionDelegate {
            delegate.sheetInteractionEnded(targetDetent: targetDetent)
        }
    }
}
