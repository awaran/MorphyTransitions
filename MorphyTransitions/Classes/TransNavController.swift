//
//  TransNavController.swift
//  TransistionAnimation
//
//  Created by Arjay Waran on 5/16/19.
//  Copyright © 2019 Arjay Waran. All rights reserved.
//
// TODO: create same thing for present modally.  could be useful for tutorials and custom pop ups

import UIKit

public class TransNavController: UINavigationController, UINavigationControllerDelegate {
    public var animationDuration = 1.5 //sets the amount of time that the animation happens
    public var fadeDuration = 0.5 //amount of time that the previous view controller fades out
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                                     animationControllerFor operation: UINavigationController.Operation,
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return MorphTransAnimator(type: .morphNavigation, fadeDuration: self.fadeDuration, animationDuration: self.animationDuration)
        case .pop:
            return MorphTransAnimator(type: .morphNavigation, fadeDuration: self.fadeDuration, animationDuration: self.animationDuration)
        default:
            return nil
        }
    }
}


open class MorphTransAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    public enum TransitionType {
        case navigation
        case morphNavigation
    }
    
    let type: TransitionType
    public var fadeDuration:TimeInterval //amount of time that the previous view controller fades out
    public var animationDuration:TimeInterval //sets the amount of time that the animation happens
    public var transitionComputeTime:TimeInterval //if a dev wants to do a nested push / pop (not apple supported but just in case) and needs the return of pop
    
    public init(type: TransitionType, fadeDuration: TimeInterval = 0.5, animationDuration: TimeInterval = 1.5, transitionComputeTime:TimeInterval = 0.01) {
        self.type = type
        self.fadeDuration = fadeDuration
        self.animationDuration = animationDuration
        self.transitionComputeTime = transitionComputeTime
        
        super.init()
    }
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.fadeDuration + self.animationDuration + self.transitionComputeTime
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        let containerView = transitionContext.containerView
        self.animateViewFrom(containerView, toView: toViewController.view) {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    fileprivate func animateViewFrom(_ containerView:UIView, toView:UIView , callback:@escaping ()->Void) {
        toView.alpha = 0.0
        containerView.addSubview(toView)
        containerView.layoutIfNeeded()
        
        var allResetBlocks = [() -> Void]()
        var cnt = 0
        var atLeastOneAnimation = false //can't use cnt because it introduces race condition
        var fadeAnimator: UIViewPropertyAnimator!
        
        fadeAnimator = UIViewPropertyAnimator(duration: self.fadeDuration, curve: .easeInOut) {
            toView.alpha = 1.0
            toView.layoutIfNeeded()
        }
        
        fadeAnimator.addCompletion { position in
            if position == .end {
                for curResetBlock in allResetBlocks {
                    curResetBlock()
                }
                callback()
            }
        }

        guard let fromView = containerView.subviews.first else {
            print ("No from view exists, just do fade transition")
            fadeAnimator.startAnimation()
            return
        }
        
        var fromViewAnimationViews = [String:UIView] ()
        self.getAllAnimationIDViews(view:fromView, animViews:&fromViewAnimationViews)
        
        var toViewAnimationViews = [String:UIView] ()
        self.getAllAnimationIDViews(view:toView, animViews:&toViewAnimationViews)
        
        let cntQueue = DispatchQueue(label: "TRANSITION_ANIMATION_LOCK_FOR_CNT")
        
        
        for (animationId, curFromSubView) in fromViewAnimationViews {
            if let curToSubView = toViewAnimationViews[animationId] {
                atLeastOneAnimation = true
                cnt += 1
                do {
                    try curFromSubView.overlapViewWithReset(dest: curToSubView, animationDuration: self.animationDuration, doesFade: false, fadeDuration: 0) {(resetBlock:@escaping ()->Void) in
                        cntQueue.sync {
                            cnt -= 1
                            allResetBlocks.append(resetBlock)
                            if (cnt == 0) {
                                fadeAnimator.startAnimation()
                            }
                        }
                    }
                    
                } catch {
                    print("catching error with transistion, just let the transistion happen without animation.  error out gracefully")
                }
            }
        }
        
        if (!atLeastOneAnimation) {
            fadeAnimator.startAnimation()
        }
    }
    
    fileprivate func getAllAnimationIDViews(view:UIView, animViews:inout [String:UIView]) {
        for curView in view.subviews {
            if let animID = curView.morph_id {
                animViews[animID] = curView
            }
            self.getAllAnimationIDViews(view: curView, animViews: &animViews)
        }
    }
}
