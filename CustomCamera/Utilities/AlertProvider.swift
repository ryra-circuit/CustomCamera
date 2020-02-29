//
//  AlertProvider.swift
//  Copyright © 2019 Elegant Media Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

class AlertProvider {
    
    var _vc: UIViewController?
    var _tvc: UIViewController?
    
    init(vc: UIViewController) {
        self._vc = vc
        self._tvc = nil
    }
    
    init(tvc: UITableViewController) {
        self._vc = nil
        self._tvc = tvc
    }
    
    // Simple Alert
    func showAlert(title: String?, message: String, action: AlertAction) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: action.title, style: action.style, handler: nil))
        
        if _vc != nil {
            _vc?.present(alertController, animated: true, completion: nil)
        } else {
            _tvc?.present(alertController, animated: true, completion: nil)
        }
    }
    
    // Simple Alert with action
    func showAlertWithAction(title: String?, message: String, action: AlertAction, completion: @escaping (_ action: UIAlertAction) -> ()) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let _action = UIAlertAction(title: action.title, style: action.style) { (action: UIAlertAction) in
            completion(action)
        }
        
        alertController.addAction(_action)
        
        if _vc != nil {
            _vc?.present(alertController, animated: true, completion: nil)
        } else {
            _tvc?.present(alertController, animated: true, completion: nil)
        }
    }
    
    // Simple Alert with actions
    func showAlertWithActions(title: String?, message: String, actions: [AlertAction], completion: @escaping (_ action: UIAlertAction) -> ()) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        actions.forEach({ action in
            let _action = UIAlertAction(title: action.title, style: action.style) { (action: UIAlertAction) in
                completion(action)
            }
            alertController.addAction(_action)
        })
        
        if _vc != nil {
            _vc?.present(alertController, animated: true, completion: nil)
        } else {
            _tvc?.present(alertController, animated: true, completion: nil)
        }
    }
    
    // Actionsheet with actions and cancel
    func showActionSheetWithActions(title: String?, message: String?, withCancel: Bool = true, actions: [AlertAction], sourceView: UIView, completion: @escaping (_ action: UIAlertAction) -> ()) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        actions.forEach({ action in
            let _action = UIAlertAction(title: action.title, style: action.style) { (action: UIAlertAction) in
                completion(action)
            }
            alertController.addAction(_action)
        })
        
        switch withCancel {
        case true:
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
                completion(action)
            }
            alertController.addAction(cancelAction)
        default:
            break
        }
        
        let popOver = alertController.popoverPresentationController
        popOver?.sourceView  = sourceView
        popOver?.sourceRect = sourceView.bounds
        popOver?.permittedArrowDirections = .any
        
        if _vc != nil {
            _vc?.present(alertController, animated: true, completion: nil)
        } else {
            _tvc?.present(alertController, animated: true, completion: nil)
        }
    }
}

struct AlertAction {
    var title: String?
    var style: UIAlertAction.Style
    
    init(title: String, style: UIAlertAction.Style = .default) {
        self.title = title
        self.style = style
    }
}
