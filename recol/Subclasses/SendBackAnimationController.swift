//
//  SendBackAnimationController.swift
//  recol
//
//  Created by Brian on 9/25/18.
//  Copyright © 2018 Farhad Saadatpei. All rights reserved.
//

import UIKit

class SendBackAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
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
        let bounds = UIScreen.main.bounds
        
        //Initiate Second View
        toViewController.view.frame = finalFrameForViewController.offsetBy(dx: 0, dy: bounds.size.height)
        toViewController.view.layer.cornerRadius = 10
        toViewController.view.layer.masksToBounds = true
        
        //Add it to Container Previously Setup
        containerView.addSubview(toViewController.view)
        
        
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                //Perform Animation of the Second View
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
                    
                    //Apply Dark Layer Over Initiate View
                    fromViewController.view.alpha = 0.2
                    
                    //Second View Appear with Margin in Top
                    toViewController.view.frame = CGRect(x: 0, y: 50, width: finalFrameForViewController.width, height: finalFrameForViewController.height)
                    
                    //Resize & Center the Initiate View
                    fromViewController.view.frame = CGRect(x: 7.5, y: 15, width: fromViewController.view.frame.size.width - 15, height: fromViewController.view.frame.size.height - 15)
                    
                }, completion: {
                    finished in
                    
                    //Transition Complete
                    transitionContext.completeTransition(true)
                    
                    //Add From View in Background
                    UIApplication.shared.keyWindow?.addSubview(fromViewController.view)
                    UIApplication.shared.keyWindow?.sendSubviewToBack(fromViewController.view)
                })
            }
        }
        
    }

}
