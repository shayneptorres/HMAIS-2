//
//  ModalFormNav.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/17/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum ModalFormType {
    case addSection
    case addItemToSection
    case editItem
}

extension ModalFormType {
    var formHeight: CGFloat {
        switch self {
        case .addSection:
            return 175
        case .addItemToSection:
            return 350
        case .editItem:
            return 200
        }
    }
}

class ModalFormNav: UIViewController {
    
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var container: UIView! {
        didSet {
            container.layer.cornerRadius = 8
            container.layer.masksToBounds = true
        }
    }
    
    let trash = DisposeBag()
    var formType: ModalFormType = .addSection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer()
        
        tap.rx.event.subscribe(onNext: { recognizer in
            guard
                !self.container.frame.contains(recognizer.location(in: self.view))
            else { return }
            
            self.tapToDismiss()
        }).disposed(by: trash)
        
        self.view.addGestureRecognizer(tap)
        
        setModalFormTypeHeight()
    }
    
    
    var tapToDismissEnabled = true
    
    func tapToDismiss() {
        if UIResponder.getCurrentFirstResponder() != nil {
            // dismiss keyboard
            UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil);
        } else if tapToDismissEnabled {
            // dismiss view
            dismiss(animated: true, completion: nil)
        }
    }
    
    func setModalFormTypeHeight() {
        self.containerHeight.constant = self.formType.formHeight
    }
    
    func present(_ viewController: UIViewController, from presenter: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        
        // present modal
        
        presenter.present(self, animated: flag, completion: completion)
        
        // set embedded vc
        
        addChildViewController(viewController)
        
        // set constraints
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(viewController.view)
        
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: container.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        
        // complete transition
        
        viewController.didMove(toParentViewController: self)
    }


}
