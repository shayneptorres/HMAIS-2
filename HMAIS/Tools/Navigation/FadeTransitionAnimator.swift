//
//  FadeTransitionAnimator.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/17/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit

class FadeTransitionAnimator: TransitionAnimator {
    
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destination = transitionContext.viewController(forKey: .to)?.view else { return }
        
        // add subview
        transitionContext.containerView.addSubview(destination)
        
        //set constraints
        destination.translatesAutoresizingMaskIntoConstraints = false
        transitionContext.containerView.addConstraint(NSLayoutConstraint(item: transitionContext.containerView, attribute: .leading, relatedBy: .equal, toItem: destination, attribute: .leading, multiplier: 1, constant: 0))
        transitionContext.containerView.addConstraint(NSLayoutConstraint(item: transitionContext.containerView, attribute: .trailing, relatedBy: .equal, toItem: destination, attribute: .trailing, multiplier: 1, constant: 0))
        transitionContext.containerView.addConstraint(NSLayoutConstraint(item: transitionContext.containerView, attribute: .top, relatedBy: .equal, toItem: destination, attribute: .top, multiplier: 1, constant: 0))
        transitionContext.containerView.addConstraint(NSLayoutConstraint(item: transitionContext.containerView, attribute: .bottom, relatedBy: .equal, toItem: destination, attribute: .bottom, multiplier: 1, constant: 0))
        
        //animate transition
        UIView.animate(withDuration: duration, animations: {
            destination.alpha = 0
            destination.alpha = 1
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
