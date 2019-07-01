//
//  UIView+Trans.swift
//  TransistionAnimation
//
//  Created by Arjay Waran on 5/16/19.
//  Copyright © 2019 Arjay Waran. All rights reserved.
//
//  This category provides simple animation support to overlap one view
//  then reset said view, swap two views autolayouts / positions
//  or swap two view layouts then reset them back to their original positions.
//
//  TODO: support batch animations
//  TODO: figure out how to support overlap without reset that is existing layout friendly
//

import Foundation
import UIKit


enum AnimationError: Error {
    case selfAndDestBothNeedAParent
    case selfAndDestNeedToShareRootView
}


@IBDesignable
public extension UIView
{
    var morphIdentifier: String! {
        get {
            return objc_getAssociatedObject(self, &morphAssociationKey) as? String ?? nil
        }
        set(newValue) {
            objc_setAssociatedObject(self, &morphAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    @IBInspectable
    var morph_id: String! {
        get {
            return objc_getAssociatedObject(self, &morphAssociationKey) as? String ?? nil
        }
        set(newValue) {
            objc_setAssociatedObject(self, &morphAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    //animates view, fades if set, call resetBlock when you are ready to reset self view
    func overlapViewWithReset(dest:UIView, animationDuration:TimeInterval, doesFade:Bool = false, fadeDuration:TimeInterval = 0.0, callback:@escaping ((_ resetBlock:@escaping()->Void) -> Void) = {(resetBlock:@escaping()->Void) in resetBlock() }) throws {
        try self.animateHelper(dest: dest, animationDuration: animationDuration, doesFade: doesFade, fadeDuration: fadeDuration, callback: callback,
                               prepMoveAnimation: { (params) in
                                params.source.prepMoveToParent(parentView: params.rootSourceView, origFrame: params.origSourceFrame)
                                
        },
                               animateMove: { (params) in
                                params.source.moveToFrame(newFrame: params.origDestFrame)
                                
        },
                               animateFade: { (params) in
                                params.source.fadeOut(newAlpha: 0.0)
        }) { (params) in
            
        }
    }
    
    
    //swaps self and dest locations with animation, fades if set, then calls resetBlock when you are ready to reset both views
    func swapViewsWithReset(dest:UIView, animationDuration:TimeInterval, doesFade:Bool = false, fadeDuration:TimeInterval = 0.0, callback:@escaping ((_ resetBlock:@escaping()->Void) -> Void) = {(resetBlock:@escaping()->Void) in resetBlock() }) throws {
        try self.animateHelper(dest: dest, animationDuration: animationDuration, doesFade: doesFade, fadeDuration: fadeDuration, callback: callback,
                               prepMoveAnimation: { (params) in
                                params.source.prepMoveToParent(parentView: params.rootSourceView, origFrame: params.origSourceFrame)
                                params.dest.prepMoveToParent(parentView: params.rootDestView, origFrame: params.origDestFrame)
                                
        },
                               animateMove: { (params) in
                                params.source.moveToFrame(newFrame: params.origDestFrame)
                                params.dest.moveToFrame(newFrame: params.origSourceFrame)
                                
        },
                               animateFade: { (params) in
                                params.source.fadeOut(newAlpha: 0.0)
                                params.dest.fadeOut(newAlpha: 0.0)
                                
                                
        }) { (params) in
            
        }
    }
    
    
    //swaps self view and dest view layout constraints over durationSeconds seconds, then fades if user provides settings and does callback when done
    func swapView(dest:UIView, animationDuration:TimeInterval, doesFade:Bool = false, fadeDuration:TimeInterval = 0.0, callback:@escaping (() -> Void) = {}) throws {
        guard let selfParent = self.superview, let destParent = dest.superview else {
            print ("ERROR:self and dest both need a parent.  they can't be the main view")
            throw AnimationError.selfAndDestBothNeedAParent
        }
        
        try self.animateHelper(dest: dest, animationDuration: animationDuration, doesFade: doesFade, fadeDuration: fadeDuration, callback: { (resetBlock:@escaping () -> Void) in
            resetBlock()
        },
                               prepMoveAnimation: { (params) in
                                params.source.prepMoveToParent(parentView: params.rootSourceView, origFrame: params.origSourceFrame)
                                params.dest.prepMoveToParent(parentView: params.rootDestView, origFrame: params.origDestFrame)
        },
                               animateMove: { (params) in
                                params.source.moveToFrame(newFrame: params.origDestFrame)
                                params.dest.moveToFrame(newFrame: params.origSourceFrame)
                                
        },
                               animateFade: { (params) in
                                params.source.fadeOut(newAlpha: 0.0)
                                params.dest.fadeOut(newAlpha: 0.0)
                                
        }) { (params) in
            let selfLayout = self.getLayoutState()
            let destLayout = dest.getLayoutState()
            
            self.translatesAutoresizingMaskIntoConstraints = false
            dest.translatesAutoresizingMaskIntoConstraints = false
            var layoutsToAdd = [UIView:[NSLayoutConstraint]]()
            var layoutsToRemove = [UIView:[NSLayoutConstraint]]()
            
            //save autolayoutconstraints referencing self and dest in parent views
            UIView.getLayoutChangeForView(source: self, dest: dest, modifiedLayouts: &layoutsToAdd, originalLayouts: &layoutsToRemove)
            UIView.getLayoutChangeForView(source: dest, dest: self, modifiedLayouts: &layoutsToAdd, originalLayouts: &layoutsToRemove)
            
            self.removeFromSuperview()
            destParent.addSubview(self)
            
            dest.removeFromSuperview()
            selfParent.addSubview(dest)
            
            UIView.setAllSavedLayoutConstraints(layoutsToRemove: layoutsToRemove, layoutsToAdd: layoutsToAdd)
            self.translatesAutoresizingMaskIntoConstraints = destLayout.translatesAutoresizingMaskIntoConstraints
            dest.translatesAutoresizingMaskIntoConstraints = selfLayout.translatesAutoresizingMaskIntoConstraints
            if (destLayout.translatesAutoresizingMaskIntoConstraints) {
                self.frame = destLayout.frame
            }
            if (selfLayout.translatesAutoresizingMaskIntoConstraints) {
                dest.frame = selfLayout.frame
            }
            self.rootView().layoutIfNeeded()
            self.superview!.setNeedsLayout()
            self.superview!.layoutIfNeeded()
            callback()
        }
        
    }
    
    //remove fileprivate at own risk.  if something in anchored to self, it might break your layout
    fileprivate func overlapView(dest:UIView, animationDuration:TimeInterval, doesFade:Bool = false, fadeDuration:TimeInterval = 0.0, callback:@escaping (() -> Void) = {}) throws {
        guard let destParent = dest.superview, self.superview != nil else {
            print ("ERROR:self and dest both need a parent (they can't be the window)")
            throw AnimationError.selfAndDestBothNeedAParent
        }
        
        try self.animateHelper(dest: dest, animationDuration: animationDuration, doesFade: doesFade, fadeDuration: fadeDuration, callback: { (resetBlock:@escaping () -> Void) in
            resetBlock()
            callback()
        },
                               prepMoveAnimation: { (params) in
                                params.source.removeFromSuperview()
                                params.rootSourceView.addSubview(params.source)
                                params.source.frame = params.origSourceFrame
                                
        },
                               animateMove: { (params) in
                                params.source.frame = params.origDestFrame
                                params.source.layoutIfNeeded()
                                
        },
                               animateFade: { (params) in
                                params.source.alpha = 0.0
                                params.source.layoutIfNeeded()
                                
        }) { (params) in
            let destLayout = dest.getLayoutState()
            
            self.translatesAutoresizingMaskIntoConstraints = false
            dest.translatesAutoresizingMaskIntoConstraints = false
            var layoutsToAdd = [UIView:[NSLayoutConstraint]]()
            var layoutsToRemove = [UIView:[NSLayoutConstraint]]()
            var layoutsToIgnore = [UIView:[NSLayoutConstraint]]()
            
            //save autolayoutconstraints referencing self and dest in parent views
            UIView.getLayoutChangeForView(source: self, dest: dest, modifiedLayouts: &layoutsToAdd, originalLayouts: &layoutsToIgnore)
            UIView.getLayoutChangeForView(source: dest, dest: self, modifiedLayouts: &layoutsToIgnore, originalLayouts: &layoutsToRemove)
            
            self.removeFromSuperview()
            destParent.addSubview(self)
            UIView.setAllSavedLayoutConstraints(layoutsToRemove: layoutsToRemove, layoutsToAdd: layoutsToAdd)
            self.translatesAutoresizingMaskIntoConstraints = destLayout.translatesAutoresizingMaskIntoConstraints
            dest.translatesAutoresizingMaskIntoConstraints = destLayout.translatesAutoresizingMaskIntoConstraints
            if (destLayout.translatesAutoresizingMaskIntoConstraints) {
                self.frame = destLayout.frame
            }
        }
    }
    
    //MARK: Instance helpers
    //preps the animation by poping out the view into the root view
    fileprivate func prepMoveToParent(parentView:UIView, origFrame:CGRect) {
        self.removeFromSuperview()
        parentView.addSubview(self)
        self.frame = origFrame
    }
    
    //moves current view to new rect
    fileprivate func moveToFrame(newFrame:CGRect) {
        self.frame = newFrame
        self.layoutIfNeeded()
    }
    
    //fades current view out to new alpha
    fileprivate func fadeOut(newAlpha:CGFloat) {
        self.alpha = newAlpha
        self.layoutIfNeeded()
    }
    
    //helps with animating.  caller method fills out closures to define non-repeating code
    fileprivate func animateHelper(dest:UIView, animationDuration:TimeInterval, doesFade:Bool, fadeDuration:TimeInterval, callback:@escaping ((_ resetBlock:@escaping()->Void) -> Void),
                                   prepMoveAnimation: (_ closureParams:AnimationClosureParams) -> Void,
                                   animateMove:@escaping (_ closureParams:AnimationClosureParams)->Void,
                                   animateFade:@escaping (_ closureParams:AnimationClosureParams)->Void,
                                   end:@escaping (_ closureParams:AnimationClosureParams) -> Void) throws {
        guard let destParent = dest.superview, let selfParent = self.superview else {
            print ("ERROR:self and dest both need a parent (they can't be the window)")
            throw AnimationError.selfAndDestBothNeedAParent
        }
        let allLayouts = UIView.getAllLayouts(anyChildView: self)
        UIView.setAllAutoTranslateSetting(anyChildView:self, setting: true)
        
        let rootSelfView = self.rootView()
        let rootDestView = dest.rootView()
        guard rootSelfView == rootDestView else {
            print("Error with swaping two views.  self and dest views don't share the same root view.  swapping two views that don't share the same root view is currently unsupported.")
            throw AnimationError.selfAndDestNeedToShareRootView
        }
        UIView.removeAllLayouts(anyChildView: self)
        
        let origSelfFrame = self.superview?.convert(self.frame, to: rootSelfView) ?? self.frame
        let origDestFrame = dest.superview?.convert(dest.frame, to: rootDestView) ?? dest.frame
        
        let closureParams = AnimationClosureParams(source: self, dest: dest, origSourceFrame: origSelfFrame, origDestFrame: origDestFrame, rootSourceView: rootSelfView, rootDestView: rootDestView, sourceParent: selfParent, destParent: destParent)
        
        prepMoveAnimation(closureParams)
        
        var animator: UIViewPropertyAnimator!
        animator = UIViewPropertyAnimator(duration: animationDuration, curve: .easeInOut) {
            animateMove(closureParams)
        }
        
        animator.addCompletion { position in
            if position == .end {
                var fadeAnimator: UIViewPropertyAnimator!
                
                let prevSelfAlpha = self.alpha
                let prevDestAlpha = dest.alpha
                
                fadeAnimator = UIViewPropertyAnimator(duration: fadeDuration, curve: .easeInOut) {
                    
                    if (doesFade) {
                        animateFade(closureParams)
                    }
                    
                }
                fadeAnimator.addCompletion { position in
                    if position == .end {
                        callback() {
                            //reset both source and dest before user ends where they want
                            
                            self.removeFromSuperview()
                            selfParent.addSubview(self)
                            self.frame = origSelfFrame
                            
                            dest.removeFromSuperview()
                            destParent.addSubview(dest)
                            dest.frame = origDestFrame
                            self.alpha = prevSelfAlpha
                            dest.alpha = prevDestAlpha
                            
                            //need to set the autotranlate stuff before we set the constratins and frame because if not then we get the warnings that have two things on one item
                            UIView.resetAllLayoutsTranslateSetting(anyChildView: self, layoutsToReset: allLayouts)
                            UIView.resetAllLayouts(anyChildView:self, layoutsToReset: allLayouts)
                            end(closureParams)
                        }
                    }
                }
                fadeAnimator.startAnimation()
            }
        }
        animator.startAnimation()
    }
    
    //get layout state for just one view
    fileprivate func getLayoutState() -> LayoutState {
        let curLayout = LayoutState(translatesAutoresizingMaskIntoConstraints: self.translatesAutoresizingMaskIntoConstraints, constraints: self.constraints, frame: self.frame)
        return curLayout
    }
    
    //set the autolayout settings and frames for current view from the saved layout state
    fileprivate func setLayoutState(curLayout:LayoutState) {
        self.translatesAutoresizingMaskIntoConstraints = curLayout.translatesAutoresizingMaskIntoConstraints
        self.removeConstraints(self.constraints)
        if (self.translatesAutoresizingMaskIntoConstraints) {
            self.frame = curLayout.frame
        }
        self.addConstraints(curLayout.constraints)
    }
    
    //get the root view of the current view
    fileprivate func rootView() -> UIView {
        var curView = self
        while let s = curView.superview {
            curView = s
        }
        return curView
    }
    
    //MARK: Class static helpers
    //gets all autolayouts for all views in the same tree as anyChildView and returns them
    static fileprivate func getAllLayouts (anyChildView:UIView) -> [UIView:LayoutState] {
        var layoutConstraints = [UIView:LayoutState]()
        UIView.transverseViews(view: anyChildView.rootView()) { (curView) in
            layoutConstraints[curView] = curView.getLayoutState()
        }
        return layoutConstraints
    }
    
    //removes all autolayouts for all views in the same tree as anyChildView
    static fileprivate func removeAllLayouts (anyChildView:UIView) {
        UIView.transverseViews(view: anyChildView.rootView()) { (curView) in
            curView.removeConstraints(UIView.getPublicConstraints(allConstraints: curView.constraints))
        }
    }

    
    //resets all autolayouts for all views in the same tree as anyChildView
    static fileprivate func resetAllLayoutsTranslateSetting (anyChildView:UIView, layoutsToReset:[UIView:LayoutState]) {
        UIView.transverseViews(view: anyChildView.rootView()) { (curView) in
            if let curLayout = layoutsToReset[curView] {
                curView.translatesAutoresizingMaskIntoConstraints = curLayout.translatesAutoresizingMaskIntoConstraints
            }
        }
    }

    //resets all autolayouts for all views in the same tree as anyChildView
    static fileprivate func resetAllLayouts (anyChildView:UIView, layoutsToReset:[UIView:LayoutState]) {
        UIView.transverseViews(view: anyChildView.rootView()) { (curView) in
            if let curLayout = layoutsToReset[curView] {
                curView.setLayoutState(curLayout: curLayout)
            }
        }
    }
    
    //sets autotranslate for all views in the same tree as anyChildView
    static fileprivate func setAllAutoTranslateSetting(anyChildView:UIView, setting:Bool) {
        UIView.transverseViews(view: anyChildView.rootView()) { (curView) in
            curView.translatesAutoresizingMaskIntoConstraints = setting
        }
    }
    
    //transverses the subviews starting with view and does doWork on all of them unless it's a nav bar
    static fileprivate func transverseViews (view:UIView, doWork:@escaping ((UIView) -> Void)) {
        if (!(view is UINavigationBar || view is UIToolbar)) {
            doWork(view)
            for curView in view.subviews {
                transverseViews(view: curView, doWork: doWork)
            }
        }
        
    }
    
    //removes all layouts that were marked to remove and adds all layouts that are marked to be added
    static fileprivate func setAllSavedLayoutConstraints(layoutsToRemove:[UIView:[NSLayoutConstraint]], layoutsToAdd:[UIView:[NSLayoutConstraint]]) {
        for (key, layoutArray) in layoutsToRemove {
            key.removeConstraints(layoutArray)
        }
        for (key, layoutArray) in layoutsToAdd {
            key.addConstraints(layoutArray)
        }
    }
    
    //helper method: puts all layouts to add in layoutsToAdd and puts all layouts to remove in layoutsToRemove when ur planning on swapping two views, does it just for source
    //returns first: constraints to add to source (modified dest layouts to reflect source instead of dest), second: constraints that were modified from dest to source (the original layouts we modified, if switching views, layouts to remove)
    static fileprivate func getLayoutChangeForView(source:UIView, dest:UIView, modifiedLayouts:inout [UIView:[NSLayoutConstraint]], originalLayouts:inout [UIView:[NSLayoutConstraint]]) {
        
        var parentsVisited = Set<UIView>()
        //save autolayoutconstraints referencing source and dest in parent views
        UIView.getAllParentLayoutReferencing(source: source, dest: dest, curParent: dest.superview, modifiedLayouts: &modifiedLayouts, originalLayouts: &originalLayouts, parentsVisited: &parentsVisited)
        UIView.getReplaceConstraints(source: source, dest: dest, modifiedLayouts: &modifiedLayouts, originalLayouts: &originalLayouts)
    }
    
    //finds all constraints that match dest in all parents of dest and matches them with source.  also saves original
    static fileprivate func getAllParentLayoutReferencing(source:UIView, dest:UIView?, curParent:UIView?, modifiedLayouts:inout [UIView:[NSLayoutConstraint]], originalLayouts:inout [UIView:[NSLayoutConstraint]], parentsVisited:inout Set<UIView>) {
        guard let curParent = curParent, !parentsVisited.contains(curParent) else {
            return
        }
        parentsVisited.insert(curParent)
        
        var newModifiedLayouts = modifiedLayouts[curParent] ?? [NSLayoutConstraint]()
        var oldOriginalLayouts = originalLayouts[curParent] ?? [NSLayoutConstraint]()
        for curConstraint in curParent.constraints {
            let first = curConstraint.firstItem as? UIView?
            let second = curConstraint.secondItem as? UIView?
            
            var newFirst = curConstraint.firstItem
            var newSecond = curConstraint.secondItem
            
            var match = false
            if (first == dest) {
                newFirst = source
                match = true
            }
            if (second == dest) {
                newSecond = source
                match = true
            }
            
            //if there's a match, remove the constraint and create a new one with the replaceing restraint
            if (match && newFirst != nil) {
                if let newFirst = newFirst {
                    if let newConst = self.transformConstraint(constraint: curConstraint, newFirst: newFirst, newSecond: newSecond) {
                        newModifiedLayouts.append(newConst)
                        oldOriginalLayouts.append(curConstraint)
                    }
                }
            }
            
        }
        
        modifiedLayouts[curParent] = newModifiedLayouts
        originalLayouts[curParent] = oldOriginalLayouts
        if let superView = curParent.superview {//if we have more superviews, do them recursivly
            self.getAllParentLayoutReferencing(source: source, dest: dest, curParent: superView, modifiedLayouts: &modifiedLayouts, originalLayouts: &originalLayouts, parentsVisited: &parentsVisited)
        }
        
    }
    
    //gets all constraints that has to do with dest and creates a copy that now has to do with source.  also saves original
    static fileprivate func getReplaceConstraints(source:UIView, dest:UIView, modifiedLayouts:inout [UIView:[NSLayoutConstraint]], originalLayouts:inout [UIView:[NSLayoutConstraint]]) { //remove constraints, add constraints
        var newSourceConstraints = modifiedLayouts[source] ?? [NSLayoutConstraint]()
        var origDestConstraints = originalLayouts[dest] ?? [NSLayoutConstraint]()
        for curConstraint in dest.constraints {
            if let firstItem = curConstraint.firstItem as? UIView, firstItem == dest, curConstraint.secondItem == nil {
                if let newConstraint = UIView.copyConstraintWith(constraint: curConstraint, first: source, second: curConstraint.secondItem) {
                    newSourceConstraints.append(newConstraint)
                    origDestConstraints.append(curConstraint)
                }
            }
        }
        modifiedLayouts[source] = newSourceConstraints
        originalLayouts[dest] = origDestConstraints
    }
    
    //creates a new constraint that takes a constraint and replaces the target and source
    static fileprivate func transformConstraint(constraint:NSLayoutConstraint, newFirst:Any, newSecond:Any?) -> NSLayoutConstraint? {
        return UIView.copyConstraintWith(constraint: constraint, first: newFirst, second: newSecond)
    }
    
    static fileprivate func copyConstraintWith (constraint:NSLayoutConstraint, first:Any?, second:Any?) -> NSLayoutConstraint? {
        if let firstItem = first {
            if UIView.isConstraintPublic(constraint: constraint) {
                let newConstraint = NSLayoutConstraint(item: firstItem,
                                                       attribute: constraint.firstAttribute,
                                                       relatedBy: constraint.relation,
                                                       toItem: second,
                                                       attribute: constraint.secondAttribute,
                                                       multiplier: constraint.multiplier,
                                                       constant: constraint.constant)
                
                newConstraint.shouldBeArchived = constraint.shouldBeArchived
                
                return newConstraint
            }
        }
        return nil
    }
    
    static fileprivate func getPublicConstraints(allConstraints:[NSLayoutConstraint]) -> [NSLayoutConstraint] { //returns constraints that are just NSLayoutConstraints and not the private subclasses
        var newCopiedConstraints = [NSLayoutConstraint]()
        for curConstraint in allConstraints {
            if UIView.isConstraintPublic(constraint: curConstraint) {
                newCopiedConstraints.append(curConstraint)
            }
        }
        return newCopiedConstraints
    }
    
    static fileprivate func isConstraintPublic(constraint:NSLayoutConstraint) -> Bool {
        if type(of: constraint) == NSLayoutConstraint.self {//ignore all subclass constraints because they are most likely the private ones that I can't fully copy because their init is private.  If you have a bug and are using extensions of NSLayoutConstraints, your problem is probably here.  could make an array of whitelisted class and add yours and check all of them
            return true
        }
        return false
    }
    
}


//used for Associative References so users can use this library without modifying much
fileprivate var morphAssociationKey: UInt8 = 1

//params used in helper closures to minimzie codebase
fileprivate struct AnimationClosureParams {
    var source:UIView
    var dest:UIView
    var origSourceFrame:CGRect
    var origDestFrame:CGRect
    var rootSourceView:UIView
    var rootDestView:UIView
    var sourceParent:UIView
    var destParent:UIView
}

//layout state of a UIView
fileprivate struct LayoutState {
    var translatesAutoresizingMaskIntoConstraints:Bool
    var constraints:[NSLayoutConstraint]
    var frame:CGRect
}
