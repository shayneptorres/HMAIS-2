//
//  MiniForm.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/11/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class MiniForm: UIView, UITextFieldDelegate {
    
    let trash = DisposeBag()
    let nibName = "MiniForm"
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var formTextField: UITextField! {
        didSet {
            formTextField.delegate = self
            formTextField.tintColor = #colorLiteral(red: 0.4831105471, green: 0.8350749612, blue: 0.006270377897, alpha: 1)
        }
    }
    
    @IBOutlet weak var addBtn: UIButton! {
        didSet {
            addBtn.rx
                .tap
                .bind(onNext: { [weak self] in
                    guard
                        let s = self,
                        let delegate = s.delegate,
                        let textField = s.formTextField as? UITextField
                    else { return }
                    
                    delegate.miniFormDidSubmit(text: textField.text ?? "")
                    s.formTextField.text = ""
                })
                .disposed(by: trash)
        }
    }
    
    var delegate: MiniFormDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetUp()
    }
    
    func xibSetUp() {
        contentView = loadViewFromNib()
        contentView.frame = self.bounds
        contentView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(contentView)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        self.contentView.applyShadow(.light(.top))
        return view
    }
    
    func beginEditing() {
        self.formTextField.becomeFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
