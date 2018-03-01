//
//  AlertCreator.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/26/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import UIKit

class ActionSheetCreator {
    var delegate: UIViewController?
    
    required init(viewController: UIViewController) {
        self.delegate = viewController
    }
    
    func createActionSheet(withTitle title: String, message: String? = nil, withActions actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        actions.forEach { action in
            alert.addAction(action)
        }
        
        delegate?.present(alert, animated: true)
    }
}
