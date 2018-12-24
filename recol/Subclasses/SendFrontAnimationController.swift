//
//  SendFrontAnimationController.swift
//  recol
//
//  Created by Brian on 9/25/18.
//  Copyright © 2018 Farhad Saadatpei. All rights reserved.
//

import UIKit

class SendFrontAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        //Transition Animation Speed
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        //Initiate View
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        
        //Second View
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        //Final Frame of Initiation View
        let finalFrameForViewController = transitionContext.finalFrame(for: toViewController)
        
        //Container & Bound to Set for Second View
        let containerView = transitionContext.containerView
        
        //Initiate Second View
        toViewController.view.frame = finalFrameForViewController
        toViewController.view.alpha = 0.5
        
        containerView.addSubview(toViewController.view)
        containerView.sendSubviewToBack(toViewController.view)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            
            //Push Down the Second View
            fromViewController.view.frame = CGRect(x: 0, y: finalFrameForViewController.height, width: finalFrameForViewController.width, height: finalFrameForViewController.height)
            
            //Show To View (initiat view)
            toViewController.view.alpha = 1.0
            
        }, completion: {
            finished in
            
            //Transition Complete
            transitionContext.completeTransition(true)
        })
    }
}
