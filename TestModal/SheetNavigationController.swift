//
//  SheetNavigationController.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-05.
//

import UIKit

class SheetNavigationController: UINavigationController {

    private lazy var detentPanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDetentPan(pan:)))
        gesture.name = "detentPan"
        gesture.delegate = self
        return gesture
    }()
    
    private var detents: [UISheetPresentationController.Detent] {
        sheetPresentationController?.detents ?? [.large()]
    }
    
    private var detentBegan: UISheetPresentationController.Detent.Identifier {
        sheetPresentationController?.selectedDetentIdentifier ?? sheetPresentationController!.detents.first!.identifier
    }
    
    private var detentClosest: UISheetPresentationController.Detent.Identifier?
    
    private var detentApproaching: UISheetPresentationController.Detent.Identifier {
        .large
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(detentPanGesture)
    }
    
    @objc private func handleDetentPan(pan: UIPanGestureRecognizer) {
        guard let sheetPresentationController, let window = view.window, let sheetView = view else {
            return
        }
        
        /// Track which detent is currently closest to the top edge of sheet statck.
//        print(#function, "state: \(pan.state)")
        switch pan.state {
        case .began:
            print(detentBegan)
        case .changed:
            let frame = sheetView.convert(sheetView.frame, from: window)
            let detents = sheetPresentationController.detents
            let direction = pan.direction
            let heights = detents.compactMap {
                let identifier = $0.identifier
                let detentHeight = UISheetPresentationController.Detent.height(identifier: identifier, maximumDetentValue: sheetPresentationController.maximumDetentValue())!
                /// Exclude sheet height outside safe area (bottom edge attached).
                let sheetHeight = frame.height - sheetPresentationController.topSheetInsets.bottom
                let distance = abs(sheetHeight - detentHeight)
                return (identifier, distance, detentHeight)
            }
            /// Closest in terms of distance, not accounting for sheet momemtum, which may cause sheet to rest at a further detent.
            let closest = heights.sorted { $0.1 < $1.1 }.first!
            print(closest)
        case .ended:
            break
        case .cancelled, .failed:
            break
        default:
            break
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        print(#function)
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print(#function)
//        super.touchesBegan(touches, with: event)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print(#function)
//        super.touchesMoved(touches, with: event)
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print(#function)
//        super.touchesEnded(touches, with: event)
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print(#function)
//        super.touchesCancelled(touches, with: event)
//    }
}

extension SheetNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
