//
//  MDAlertDialog.swift
//  Mold
//
//  Created by Matt Quiros on 8/3/15.
//  Copyright © 2015 Matt Quiros. All rights reserved.
//

import UIKit

open class MDAlertDialog {
    
    open class func showInPresenter(_ presenter: UIViewController,
        title: String?,
        message: String?,
        cancelButtonTitle: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: cancelButtonTitle,
                                             style: .cancel) { _ in
                                                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(cancelAction)
            
            presenter.present(alertController, animated: true, completion: nil)
        }
    }
    
}
