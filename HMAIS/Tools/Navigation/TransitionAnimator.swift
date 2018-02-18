//
//  TransitionAnimator.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/17/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit

enum TransitionAnimatorStyle {
    case normal
    case fade
}

extension TransitionAnimatorStyle {
    var animator: TransitionAnimator? {
        switch self {
        case .normal:
            return nil
        case .fade:
            return FadeTransitionAnimator()
        }
    }
}

class TransitionAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration: TimeInterval = 0.2
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
    }
}
