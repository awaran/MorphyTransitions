//
//  TransNavController.swift
//  TransistionAnimation
//
//  Created by Arjay Waran on 5/16/19.
//  Copyright © 2019 Arjay Waran. All rights reserved.
//
// TODO: create same thing for present modally.  could be useful for tutorials and custom pop ups

import UIKit

public class TransNavController: UINavigationController {
    public var animationDuration = 1.5 //sets the amount of time that the animation happens
    public var fadeDuration = 0.5 //amount of time that the previous view controller fades out
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.pushViewController(viewController: viewController, animated: animated, completion: nil)
    }
    
    override public func popViewController(animated: Bool) -> UIViewController? {
        return self.popViewController(animated: animated, completion: nil)
    }
    
    public func pushViewController(viewController: UIViewController,
                                   animated: Bool,
                                   completion: (()->())?) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        super.pushViewController(viewController, animated: false)
        if animated, let prevViewController = self.getPreviousViewController(), let sourceView = prevViewController.view, let destView = viewController.view {
            self.animateViewFrom(sourceView, destView: destView) {
                UIApplication.shared.endIgnoringInteractionEvents()
                completion?()
            }
        } else {
            print("TransNavController:pushViewController: no animation happened, either invalid state or animate is false")
            UIApplication.shared.endIgnoringInteractionEvents()
            completion?()
        }
    }
    
    public func popViewController(animated: Bool, completion: (()->())?) -> UIViewController? {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let prevViewController = super.popViewController(animated: false)
        
        if animated, let prevViewController = prevViewController, let curViewController = self.getCurrentViewController(), let sourceView = prevViewController.view, let destView = curViewController.view {
            
            self.animateViewFrom(sourceView, destView: destView) {
                UIApplication.shared.endIgnoringInteractionEvents()
                completion?()
            }
        } else {
            print("TransNavController:popViewConroller: no animation happened, either invalid state or animate is false")
            UIApplication.shared.endIgnoringInteractionEvents()
            completion?()
        }
        
        return prevViewController
    }
    
    fileprivate func getOffset (_ view:UIView) -> CGPoint {
        if let curScrollView = view as? UIScrollView {
            return curScrollView.contentOffset
        }
        return CGPoint(x: 0, y:0)
    }
    
    fileprivate func animateViewFrom(_ sourceView:UIView, destView:UIView , callback:@escaping ()->Void) {
        let offset = self.getOffset(destView)
        var sourceAnimationViews = [String:UIView] ()
        self.getAllAnimationIDViews(view:sourceView, animViews:&sourceAnimationViews)
        
        var destAnimationViews = [String:UIView] ()
        self.getAllAnimationIDViews(view:destView, animViews:&destAnimationViews)
        
        let prevSourceParent = sourceView.superview
        sourceView.removeFromSuperview()
        destView.addSubview(sourceView)
        
        sourceView.frame = CGRect(x: sourceView.frame.origin.x+offset.x, y: sourceView.frame.origin.y+offset.y, width: sourceView.frame.width, height: sourceView.frame.height)
        
        let cntQueue = DispatchQueue(label: "TRANSITION_ANIMATION_LOCK_FOR_CNT")
        
        var allResetBlocks = [() -> Void]()
        var cnt = 0
        var atLeastOneAnimation = false //can't use cnt because it introduces race condition
        var fadeAnimator: UIViewPropertyAnimator!
        
        fadeAnimator = UIViewPropertyAnimator(duration: self.fadeDuration, curve: .easeInOut) {
            
            sourceView.alpha = 0.0
            sourceView.layoutIfNeeded()
        }
        
        fadeAnimator.addCompletion { position in
            if position == .end {
                for curResetBlock in allResetBlocks {
                    curResetBlock()
                }
                //we reset all the animation views back before we reset the source view.  the source view was in dest view when we did the animation so the reset needs to happen when the source view is in the animation
                sourceView.alpha = 1.0
                sourceView.removeFromSuperview()
                prevSourceParent?.addSubview(sourceView)
                prevSourceParent?.layoutIfNeeded()
                callback()
            }
        }
        
        for (animationId, curSourceView) in sourceAnimationViews {
            if let curDestView = destAnimationViews[animationId] {
                atLeastOneAnimation = true
                cnt += 1
                do {
                    try curSourceView.overlapViewWithReset(dest: curDestView, animationDuration: self.animationDuration, doesFade: false, fadeDuration: 0) {(resetBlock:@escaping ()->Void) in
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
    
    func getCurrentViewController() -> UIViewController? {
        let count = viewControllers.count
        guard count > 0 else { return nil }
        return viewControllers[count - 1]
    }
    
    func getPreviousViewController() -> UIViewController? {
        let count = viewControllers.count
        guard count > 1 else { return nil }
        return viewControllers[count - 2]
    }
    
}
