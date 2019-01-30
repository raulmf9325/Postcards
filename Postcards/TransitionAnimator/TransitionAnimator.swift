//
//  TransitionAnimator.swift
//  Postcards
//
//  Created by Raul Mena on 1/29/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning{
    
    var duration : TimeInterval
    var isPresenting : Bool
    var originFrame : CGRect
    var image: UIImage?
    
    init(duration : TimeInterval, isPresenting : Bool, originFrame : CGRect) {
        self.duration = duration
        self.isPresenting = isPresenting
        self.originFrame = originFrame
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
        
        self.isPresenting ? container.addSubview(toView) : container.insertSubview(toView, belowSubview: fromView)
        
        let animatedView = isPresenting ? toView : fromView
        
        toView.frame = isPresenting ? originFrame : toView.frame
        toView.layoutIfNeeded()
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            animatedView.frame = self.isPresenting ? fromView.frame : self.originFrame
            animatedView.layoutIfNeeded()
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
}
