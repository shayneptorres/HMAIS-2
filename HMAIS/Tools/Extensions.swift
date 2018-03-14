//
//  Extensions.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/1/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation

// MARK: - String

extension String {
    
    /// Return the current string in currency format if applicable
    ///
    /// - Returns: the string in currency format
    func toCurrency() -> String {
        guard let doubleAmount = Double(self) else { return "$0.00" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: doubleAmount)) ?? "$0.00"
    }
    
    /// Returns the current string as a double, if the string
    /// is in currency format
    ///
    /// - Returns: the double value of the string
    func fromCurrencyToDouble() -> Double {
        let trimmedString = self
                            .replacingOccurrences(of: "$", with: "")
                            .replacingOccurrences(of: ",", with: "")
        
        return Double.init(trimmedString) ?? 0.0
    }
    
}

import UIKit

extension UIColor {
    /**
     Allow the initialization of UIcolors with RGB values
     */
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    /**
     Allow the initialization of UIcolors with HEX Values
     */
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension UIView {
    
    /// Applys a shadow to a UIView with a given type
    ///
    /// - Parameter type: the type of shadow wanted (light, medium, heavy)
    func applyShadow(_ type: ShadowType = .normal(.bottom)) {
        var height = 0
        var width = 0
        var opacity: Float = 0.0
        
        switch type {
        case .light(let direction):
            height = 1
            if direction == .top { height = -height }
            opacity = 0.1
        case .normal(let direction):
            height = 2
            if direction == .top { height = -height }
            opacity = 0.3
        case .heavy(let direction):
            height = 3
            if direction == .top { height = -height }
            opacity = 0.5
        }
        
        self.layer.shadowColor = UIColor(netHex: 0x222222).cgColor
        self.layer.shadowOffset = CGSize(width: width, height: height)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = opacity
        self.layer.masksToBounds = false
        
    }
    
//    https://stackoverflow.com/questions/37163850/round-top-corners-of-a-uibutton-in-swift
    
    func roundCorners(corners: UIRectCorner, radii: CGFloat){
        let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: corners,
                                     cornerRadii:CGSize(width: radii, height: radii))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPAth1.cgPath
        self.layer.mask = maskLayer1
        
    }
    
    func applyTransform(type: UIViewTransformType, animated: Bool, duration: TimeInterval) {
        var transform = CGAffineTransform()
        switch type {
        case .restore:
            transform = CGAffineTransform.identity
        case .shrink:
            transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        
        let time = animated ? duration : 0.0
        
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.transform = transform
            }, completion: { _ in
            
            })
    }
    
}

extension UIResponder {
    
    //Class var not supported in 1.0
    private struct CurrentFirstResponder {
        weak static var currentFirstResponder: UIResponder?
    }
    
    private class var currentFirstResponder: UIResponder? {
        get { return CurrentFirstResponder.currentFirstResponder }
        set(newValue) { CurrentFirstResponder.currentFirstResponder = newValue }
    }
    
    class func getCurrentFirstResponder() -> UIResponder? {
        currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder), to: nil, from: nil, for: nil)
        return currentFirstResponder
    }
    
    @objc func findFirstResponder() {
        UIResponder.currentFirstResponder = self
    }
}
