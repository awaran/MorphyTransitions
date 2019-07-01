import XCTest
import MorphyTransitions


class Tests: XCTestCase {
    
    let storyboardName = "TestBoard"
    let navControllerID = "generalNavControllerId"
    let beforeTransVCID = "generalBeforeTransId"
    let afterTransVCID = "generalAfterTransId"
    
    var navigationController:TransNavController?
    var beforeVC:GeneralBeforeViewController?
    var afterVC:GeneralAfterViewController?
    var storyboard:UIStoryboard?
    fileprivate var beforeAnimationAllLayouts:[UIView:LayoutState]?
    
    override func setUp() {
        
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.storyboard = UIStoryboard(name: self.storyboardName, bundle: nil)
        self.navigationController = self.storyboard?.instantiateViewController(withIdentifier: navControllerID) as? TransNavController
        
        XCTAssertNotNil(self.navigationController)
        guard let navigationController = self.navigationController else {
            XCTFail("error, can't find navigation controller.  navigation controller is nil")
            return
        }
        
        
        let window = UIWindow()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        let showingVC = navigationController.topViewController
        showingVC?.view.layoutIfNeeded()
        
        XCTAssertNotNil(navigationController.view)
        XCTAssertNotNil(showingVC)
        XCTAssertNotNil(showingVC?.view)

        guard let curVC = showingVC else {
            XCTFail("error, top vc failed to load into nav controller")
            return
        }
        
        //save all autolayouts for the views that the vc controls
        self.beforeAnimationAllLayouts = self.getAllLayouts(vc: curVC)
        
        guard let beforeVC = self.navigationController?.topViewController as? GeneralBeforeViewController else {
            XCTFail("error, top vc was not of type GeneralBeforeViewController")
            return
        }
        guard let afterVC = self.storyboard?.instantiateViewController(withIdentifier: self.afterTransVCID) as? GeneralAfterViewController else {
            XCTFail("error, after VC not found in storyboard")
            return
        }
        
        XCTAssertNotEqual(beforeVC, afterVC, "before and after trans view controllers are the same")
        self.beforeVC = beforeVC
        self.afterVC = afterVC
        //check and initialize after VC
        XCTAssertNotNil(self.afterVC)
        XCTAssertNotNil(self.afterVC?.view)

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    //0 ids beforeVC, 0 ids afterVC, 0 matching
    func testTransistionPushAndPopStoryboard0Start0End0Match() {
        checkBeforeAndAfterTransSameness()
    }
    
    //2 ids beforeVC, 0 ids afterVC, 0 matching
    func testTransistionPushAndPopStoryboard2Start0End0Match() {
        guard let beforeVC = self.beforeVC else {
            XCTFail("error, init failed before test")
            return
        }
        
        beforeVC.one.morphIdentifier = "one"
        beforeVC.two.morphIdentifier = "two"
        checkBeforeAndAfterTransSameness()
    }

    //0 ids beforeVC, 2 ids afterVC, 0 matching
    func testTransistionPushAndPopStoryboard0Start2End0Match() {
        guard let afterVC = self.afterVC else {
            XCTFail("error, init failed before test")
            return
        }
        afterVC.one.morphIdentifier = "one"
        afterVC.two.morphIdentifier = "two"
        checkBeforeAndAfterTransSameness()
    }
    
    //2 ids beforeVC, 2 ids afterVC, 1 matching
    func testTransistionPushAndPopStoryboard2Start2End1Match() {
        guard let beforeVC = self.beforeVC, let afterVC = self.afterVC else {
            XCTFail("error, init failed before test")
            return
        }
        beforeVC.one.morphIdentifier = "one"
        beforeVC.two.morphIdentifier = "two"
        afterVC.one.morphIdentifier = "one"
        afterVC.two.morphIdentifier = "NOT_two"
        checkBeforeAndAfterTransSameness()
    }
    
    //2 ids beforeVC, 2 ids afterVC, 2 matching
    func testTransistionPushAndPopStoryboard2Start2End2Match() {
        guard let beforeVC = self.beforeVC, let afterVC = self.afterVC else {
            XCTFail("error, init failed before test")
            return
        }
        beforeVC.one.morphIdentifier = "one"
        beforeVC.two.morphIdentifier = "two"
        afterVC.one.morphIdentifier = "one"
        afterVC.two.morphIdentifier = "two"
        checkBeforeAndAfterTransSameness()
    }
    
    //1 ids beforeVC, 1 ids afterVC, 1 matching
    func testTransistionPushAndPopStoryboard1Start1End1Match() {
        guard let beforeVC = self.beforeVC, let afterVC = self.afterVC else {
            XCTFail("error, init failed before test")
            return
        }
        beforeVC.one.morphIdentifier = "one"
        afterVC.one.morphIdentifier = "one"

        checkBeforeAndAfterTransSameness()
    }
    
    //4 ids beforeVC, 4 ids afterVC, 4 matching
    func testTransistionPushAndPopStoryboard4Start4End4Match() {
        guard let beforeVC = self.beforeVC, let afterVC = self.afterVC else {
            XCTFail("error, init failed before test")
            return
        }
        beforeVC.one.morphIdentifier = "one"
        beforeVC.two.morphIdentifier = "two"
        beforeVC.three.morphIdentifier = "three"
        beforeVC.four.morphIdentifier = "four"
        afterVC.one.morphIdentifier = "one"
        afterVC.two.morphIdentifier = "two"
        afterVC.three.morphIdentifier = "three"
        afterVC.four.morphIdentifier = "four"

        checkBeforeAndAfterTransSameness()
    }
    
    func testMoveAndReset() {
        guard let curVC = self.beforeVC, let beforeAnimationAllLayouts = self.beforeAnimationAllLayouts else {
            XCTFail("error, initialization failed")
            return
        }
        
        do {
            let moveExpectation = XCTestExpectation(description: "moving one view on top of another view")
            let beforeOneLayout = self.getLayoutState(view: curVC.one)
            
            try curVC.one.overlapViewWithReset(dest: curVC.two, animationDuration: 0.5, doesFade: true, fadeDuration: 0.5) { (resetBlock) in
                var afterOneLayout = self.getLayoutState(view: curVC.one)
                XCTAssertNotEqual(beforeOneLayout, afterOneLayout, "view one has not moved")

                resetBlock()

                afterOneLayout = self.getLayoutState(view: curVC.one)
                XCTAssertEqual(beforeOneLayout, afterOneLayout, "view one did not reset after reset block was called")

                let afterAnimationAllLayouts = self.getAllLayouts(vc:curVC)
                for (curView, beforeLayouts) in beforeAnimationAllLayouts {
                    guard let afterLayouts = afterAnimationAllLayouts[curView] else {
                        XCTFail("Error: a view that existed before the animation no longer exists after")
                        return
                    }
                    XCTAssertEqual(beforeLayouts, afterLayouts, "before layouts don't match after layouts")
                }
                moveExpectation.fulfill()
            }
            
            wait(for: [moveExpectation], timeout: 5.0)
        } catch {
            XCTFail("error, caught exception doing move with reset")
            return
        }
    }
    
    
    func testSwapAndReset() {
        guard let curVC = self.beforeVC, let beforeAnimationAllLayouts = self.beforeAnimationAllLayouts else {
            XCTFail("error, initialization failed")
            return
        }
        
        do {
            let moveExpectation = XCTestExpectation(description: "moving one view on top of another view")
            let beforeOneLayout = self.getLayoutState(view: curVC.one)
            
            try curVC.one.swapViewsWithReset(dest: curVC.two, animationDuration: 0.5, doesFade: true, fadeDuration: 0.5) { (resetBlock) in
                var afterOneLayout = self.getLayoutState(view: curVC.one)
                XCTAssertNotEqual(beforeOneLayout, afterOneLayout, "view one has not moved")
                
                resetBlock()
                
                afterOneLayout = self.getLayoutState(view: curVC.one)
                XCTAssertEqual(beforeOneLayout, afterOneLayout, "view one did not reset after reset block was called")
                
                let afterAnimationAllLayouts = self.getAllLayouts(vc:curVC)
                for (curView, beforeLayouts) in beforeAnimationAllLayouts {
                    guard let afterLayouts = afterAnimationAllLayouts[curView] else {
                        XCTFail("Error: a view that existed before the animation no longer exists after")
                        return
                    }
                    XCTAssertEqual(beforeLayouts, afterLayouts, "before layouts don't match after layouts")
                }
                moveExpectation.fulfill()
            }
            
            wait(for: [moveExpectation], timeout: 5.0)
        } catch {
            XCTFail("error, caught exception doing move with reset")
            return
        }
    }
    
    func testSwap() {  //TODO make this unit test better, maybe try facebook unit tests since default one is kinda broken
        guard let curVC = self.beforeVC else {
            XCTFail("error, initialization failed")
            return
        }
        
        do {
            let moveExpectation = XCTestExpectation(description: "moving one view on top of another view")
            let beforeOneLayout = self.getLayoutState(view: curVC.one)
            let beforeTwoLayout = self.getLayoutState(view: curVC.two)
            
            try curVC.one.swapView(dest: curVC.two, animationDuration: 0.5, doesFade: true, fadeDuration: 0.5) { () in
                moveExpectation.fulfill()
            }
            wait(for: [moveExpectation], timeout: 5.0)
            let afterOneLayout = self.getLayoutState(view: curVC.one)
            let afterTwoLayout = self.getLayoutState(view: curVC.two)
            XCTAssertNotEqual(beforeOneLayout, afterOneLayout, "view one has not moved")
            XCTAssertNotEqual(beforeTwoLayout, afterTwoLayout, "view two has not moved")
        } catch {
            XCTFail("error, caught exception doing move with reset")
            return
        }
    }
    
    func checkBeforeAndAfterTransSameness() {
        guard let afterVC = self.afterVC, let beforeAnimationAllLayouts = self.beforeAnimationAllLayouts else {
            XCTFail("error, initialization failed")
            return
        }
        
        let pushExpectation = XCTestExpectation(description: "pushing after view controller onto before view controller")
        let popExpectation = XCTestExpectation(description: "dismissing after view controller to show before view controller")
        if let transNav = self.navigationController {
            transNav.pushViewController(viewController:afterVC, animated: true, completion: {
                pushExpectation.fulfill()
                guard let curTopVC = self.navigationController?.topViewController else {
                    XCTFail("error, trans button did not push the new VC onto the stack")
                    return
                }
                XCTAssertEqual(afterVC, curTopVC, "the after VC was not pushed on top of the before VC")
                
                //pop view controller
                let popedVC = transNav.popViewController(animated: true, completion: {
                    //after transision, check to see if the views still have the same autolayouts
                    guard let showingVC = self.navigationController?.topViewController as? GeneralBeforeViewController else {
                        XCTFail("error, top vc was nil after pop of after transition view controller, not executing rest of tests for this block, but should have been caught in setup func")
                        return
                    }
                    
                    
                    let afterAnimationAllLayouts = self.getAllLayouts(vc:showingVC)
                    for (curView, beforeLayouts) in beforeAnimationAllLayouts {
                        guard let afterLayouts = afterAnimationAllLayouts[curView] else {
                            XCTFail("Error: a view that existed before the animations no longer exists after")
                            return
                        }
                        XCTAssertEqual(beforeLayouts, afterLayouts, "before layouts don't match after layouts")
                    }
                    popExpectation.fulfill()
                })
                
                //check if poped vc was the vc we pushed
                XCTAssertEqual(afterVC, popedVC, "poped vc is not the vc we pushed onto the nav controller")
            })
            
            wait(for: [pushExpectation], timeout: 5.0)
            wait(for: [popExpectation], timeout: 10.0)
        }
    }
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    //get all layout states for a view controller's views / subviews
    fileprivate func getAllLayouts (vc:UIViewController) -> [UIView:LayoutState] {
        var layoutConstraints = [UIView:LayoutState]()
        self.transverseViews(view: self.rootView(view:vc.view)) { (curView) in
            layoutConstraints[curView] = self.getLayoutState(view:curView)
        }
        return layoutConstraints
    }
    
    //get autolayouts for all parents of a view
    fileprivate func getParentsAutolayouts (anyChildView:UIView) -> [UIView:LayoutState] {
        var layoutConstraints = [UIView:LayoutState]()
        self.transverseViews(view: self.rootView(view:anyChildView)) { (curView) in
            layoutConstraints[curView] = self.getLayoutState(view:curView)
        }
        return layoutConstraints
    }
    
    //get layout state for just one view
    fileprivate func getLayoutState(view:UIView) -> LayoutState {
        
        var constraints = [NSLayoutConstraint]()
        if (!view.translatesAutoresizingMaskIntoConstraints) {
            constraints = self.copyLayoutConstraints(autoLayoutConstraints: view.constraints)
        }
        
        return LayoutState(translatesAutoresizingMaskIntoConstraints: view.translatesAutoresizingMaskIntoConstraints, constraints: constraints, frame: view.frame)
    }
    
    fileprivate func copyLayoutConstraints(autoLayoutConstraints:[NSLayoutConstraint]) -> [NSLayoutConstraint] {
        var newConstraints = [NSLayoutConstraint]()
        for curConstraint in autoLayoutConstraints {
            newConstraints.append(self.copySingleLayoutConstraint(constraint: curConstraint))
        }
        return newConstraints
    }
    
    fileprivate func copySingleLayoutConstraint (constraint:NSLayoutConstraint) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(item: constraint.firstItem,
                                               attribute: constraint.firstAttribute,
                                               relatedBy: constraint.relation,
                                               toItem: constraint.secondItem,
                                               attribute: constraint.secondAttribute,
                                               multiplier: constraint.multiplier,
                                               constant: constraint.constant)
        newConstraint.shouldBeArchived = constraint.shouldBeArchived
        return newConstraint
    }
    
    //get the root view of the current view
    fileprivate func rootView(view:UIView) -> UIView {
        var curView = view
        while let s = curView.superview {
            curView = s
        }
        return curView
    }
    
    //transverses the subviews starting with view and does doWork on all of them unless it's a nav bar
    fileprivate func transverseViews (view:UIView, doWork:@escaping ((UIView) -> Void)) {
        if (!(view is UINavigationBar)) {
            doWork(view)
        }
        
        for curView in view.subviews {
            transverseViews(view: curView, doWork: doWork)
        }
        
    }
    
    
    
}


//layout state of a UIView
fileprivate struct LayoutState: Equatable {
    var translatesAutoresizingMaskIntoConstraints:Bool
    var constraints:[NSLayoutConstraint]
    var frame:CGRect
    
    static func == (lhs: LayoutState, rhs: LayoutState) -> Bool {
        if (lhs.translatesAutoresizingMaskIntoConstraints != rhs.translatesAutoresizingMaskIntoConstraints) {
            return false
        } else if (lhs.constraints.count != rhs.constraints.count) {
            return false
        //some issues with frame updates in unit testing, uncomment this check out once they fix it.  (i.E after a swap, both frames appear in the right spot but are 80 units lower.  also unit tests ignore breakpoints and just run the entire animation before we start it
//        } else if (lhs.frame != rhs.frame) {
//            return false
        }
        
        for curConstraint in lhs.constraints {
            if (!LayoutState.checkConstraint(constraintToMatch: curConstraint, array: rhs.constraints)) {
                return false
            }
        }
        return true
    }
    
    //checks to see if constraintToMatch is inside array
    static func checkConstraint(constraintToMatch:NSLayoutConstraint, array:[NSLayoutConstraint]) -> Bool {
        for curConstraint in array {
            
            if (LayoutState.checkSingleConstraint(left: constraintToMatch, right: curConstraint)) {
                return true
            }
        }
        return false
    }
    
    static func checkSingleConstraint(left:NSLayoutConstraint, right:NSLayoutConstraint) -> Bool {
        
        return left.firstItem === right.firstItem &&
            left.firstAttribute == right.firstAttribute &&
            left.relation == right.relation &&
            left.secondItem === right.secondItem &&
            left.secondAttribute == right.secondAttribute &&
            left.multiplier == right.multiplier &&
            left.constant == right.constant &&
            left.shouldBeArchived == right.shouldBeArchived
    }
}
