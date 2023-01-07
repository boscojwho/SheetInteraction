//
//  SheetInteraction+Keyboard.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2023-01-07.
//

import UIKit

extension UISheetPresentationController.Detent.Identifier {
    static let _keyboard: Self = .init("keyboard")
}

extension UISheetPresentationController.Detent {
    class func _keyboard() -> UISheetPresentationController.Detent {
        .custom(identifier: ._keyboard) { context in
            context.maximumDetentValue
        }
    }
}

protocol SheetInteractionKeyboardObserving: AnyObject {
    func keyboardWillShow()
    func keyboardDidShow()
    func keyboardWillHide()
}

extension SheetInteraction {
    
    final class KeyboardObserver {
        weak var delegate: SheetInteractionKeyboardObserving?
        
        private var willShow: NSObjectProtocol?
        private var didShow: NSObjectProtocol?
        private var willHide: NSObjectProtocol?
        
        init() {
            willShow = NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] _ in
                self?.delegate?.keyboardWillShow()
            }
            didShow = NotificationCenter.default.addObserver(forName: UIApplication.keyboardDidShowNotification, object: nil, queue: .main) { [weak self] _ in
                self?.delegate?.keyboardDidShow()
            }
            willHide = NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
                self?.delegate?.keyboardWillHide()
            }
        }
    }
}
