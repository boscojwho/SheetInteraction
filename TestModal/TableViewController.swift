//
//  TableViewController.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-02.
//

import UIKit

extension UISheetPresentationController {
    
    /// The vertical space required to display the bottom sheet in "minimized" state when the top sheet is displayed in full height.
    /// This **does not** vary based on device.
    private static let bottomSheetPeekThroughHeight: CGFloat = 10.0
    
    private var bottomSheetTopInset: CGFloat {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            return 0
        }
        if window.safeAreaInsets.bottom == 0 {
            /// This additional inset is likely a visual design consideration made by Apple, and is not present on home indicator devices. [2022.12]
            let additionalTopInset: CGFloat = 10
            return window.safeAreaInsets.top + additionalTopInset
        } else {
            return window.safeAreaInsets.top
        }
    }

    private var topSheetTopInset: CGFloat {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            return 0
        }
        if window.safeAreaInsets.bottom == 0 {
            return bottomSheetTopInset + UISheetPresentationController.bottomSheetPeekThroughHeight
        } else {
            return window.safeAreaInsets.top + UISheetPresentationController.bottomSheetPeekThroughHeight
        }
    }
    
    private var sheetBottomInset: CGFloat {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            return 0
        }
        return window.safeAreaInsets.bottom
    }
    
    /// Layout insets inside window for the bottom sheet (visually underneath) in a sheet stack.
    var bottomSheetInsets: UIEdgeInsets {
        .init(top: bottomSheetTopInset, left: 0, bottom: sheetBottomInset, right: 0)
    }
    
    /// Layout insets inside window for the top sheet (visually on top) in a sheet stack.
    var topSheetInsets: UIEdgeInsets {
        .init(top: topSheetTopInset, left: 0, bottom: sheetBottomInset, right: 0)
    }
    
    /// The height available to the top sheet in a sheet stack (i.e. height within window's safe area).
    func maximumDetentValue() -> CGFloat {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            return 0
        }
        return window.frame.height - (topSheetInsets.top + topSheetInsets.bottom)
    }
}

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
