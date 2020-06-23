//
//  BaseTabBarController.swift
//  TestTabBarGesture
//
//  Created by george on 17/06/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {
    enum PanDirection {
        case left, right, center
    }
    
    var panLockedDirection: PanDirection?
    var lockedToView: UIView?
    var shouldAddToView: Bool = false
    
    var panDirection: PanDirection? = .center
    var pans: [CGFloat] = []
    var panCounter = 0

    lazy var panGesture: UIPanGestureRecognizer = {
        let s = UIPanGestureRecognizer(target: self, action: #selector(panToChangeTabTriggered(_:)))
        s.delegate = self
        return s
    }()
    
    var isFirstTimeLoadingController: [Bool] = [false]


    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// init array to adjust content insets on first loading of tableviews
        if let vcs = viewControllers, vcs.count > 1 {
            for _ in 1..<vcs.count {
                isFirstTimeLoadingController.append(true)
            }
        }
    }
    
    
    
    
    @objc func panToChangeTabTriggered(_ pan: UIPanGestureRecognizer) {
        guard var fromView = selectedViewController?.view else { return }
        
        /// take only the last view if it is a navigationViewController
        if let navCtrlr = selectedViewController as? UINavigationController,
            let v = navCtrlr.viewControllers.last?.view {
            fromView = v
        }
        
        let translation = pan.translation(in: view)
        let velocity = pan.velocity(in: view)
        
        if panLockedDirection == nil {
            panLockedDirection = velocity.x > 0 ? .left : .right
        }
        
        if lockedToView == nil {
            lockedToView = getNextView()
        }
        
        guard let toView = lockedToView else {
            initPanRelatedVariables()
            pan.setTranslation(.zero, in: view)
            removeAllSubviewsExceptTheFirst(from: fromView)
            return
        }
        let screenWidth = UIScreen.main.bounds.size.width
        let offset = panLockedDirection == .right ? -screenWidth : screenWidth
        
        /// add toView subview to show transition when panning
        if shouldAddToView && !(fromView.superview?.subviews.contains(toView) ?? true) {
            fromView.superview?.addSubview(toView)
            toView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y)
            shouldAddToView = false
        }
        
        switch pan.state {
        case .began: break
            
        case .changed:
            followPanExcludingInstantChanges(velocity)
            
            /// check whether pan direction should change in order to show toView from the other direction
            if (panLockedDirection == .left && fromView.center.x < screenWidth / 2) ||
                (panLockedDirection == .right && fromView.center.x > screenWidth / 2) {
                panLockedDirection = panLockedDirection == .left ? .right : .left
                /// reset views' positions and prepare for adding the other direction's view
                fromView.center.x = screenWidth / 2
                toView.center = CGPoint(x: fromView.center.x - offset, y: toView.center.y)
                pan.setTranslation(.zero, in: view)
                lockedToView = nil /// to trigger its change
                return
            }
            fromView.center.x += translation.x
            toView.center.x += translation.x
            pan.setTranslation(.zero, in: view)
            
        case .ended, .failed:
            /// smoothly settle to the correct tab
            let rangeForTransitionPermission: ClosedRange<CGFloat> = (screenWidth * 0.35)...(screenWidth * 0.65)
            let didSwipeFast = abs(velocity.x) > 400 /// trial and error
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                /// return to initial view or view of direction
                let halfScreenWidth = screenWidth / 2
                if !didSwipeFast &&
                    (fromView.superview?.subviews.count ?? 2) >= 2 &&
                    rangeForTransitionPermission.contains(fromView.center.x) {
                    self.panLockedDirection = .center
                    fromView.center.x = halfScreenWidth
                    toView.center.x = toView.center.x < screenWidth ? -halfScreenWidth : (screenWidth + halfScreenWidth)
                } else {
                    /// if direction changed do not change tab
                    if self.panDirection != self.panLockedDirection && self.panDirection != .center {
                        self.panLockedDirection = .center
                        fromView.center.x = halfScreenWidth
                        toView.center.x = self.panDirection == .right ? -halfScreenWidth : (screenWidth + halfScreenWidth)
                    } else {
                        toView.center.x = halfScreenWidth
                        fromView.center.x = self.panLockedDirection == .right ?
                            -halfScreenWidth : (screenWidth + halfScreenWidth)
                    }
                }
            }, completion: { _ in
                let toIndex = self.panLockedDirection == .right ? self.selectedIndex + 1 :
                    self.panLockedDirection == .left ? self.selectedIndex - 1 : self.selectedIndex
                self.initPanRelatedVariables()
                
                if toIndex == self.selectedIndex {
                    fromView.superview?.subviews.forEach({
                        if $0 != fromView { $0.removeFromSuperview() }
                    })
                } else {
                    fromView.removeFromSuperview()
                    self.selectedIndex = toIndex
                }
            })
            
        default: break
        }
    }
    
    func initPanRelatedVariables() {
        panLockedDirection = nil
        lockedToView = nil
        shouldAddToView = false
        
        panDirection = .center
        pans = []
        panCounter = 0
    }
    
    func removeAllSubviewsExceptTheFirst(from fromView: UIView) {
        for i in (0..<(fromView.superview?.subviews.count ?? 0)).reversed() {
            if fromView.superview?.subviews[i] != fromView.superview?.subviews.first {
                fromView.superview?.subviews[i].removeFromSuperview()
            }
        }
    }
    
    func followPanExcludingInstantChanges(_ velocity: CGPoint) {
        panCounter += 1
        if panCounter % 2 == 0 { /// append every 3
            pans.append(velocity.x)
        }
        if pans.count >= 2 && ((pans[pans.count - 1] < CGFloat(0)) == (pans[pans.count - 2] < 0)) { /// same sign
            panDirection = velocity.x > 0 ? .left : .right
        }
    }


    
    func animateToTab(withIndex toIndex: Int) {
        guard let viewControllers = viewControllers,
            let fromView = selectedViewController?.view,
            let toView = viewControllers[toIndex].view else { return }
        
        let fromIndex = selectedIndex
        guard fromIndex != toIndex else { return }
        
        fromView.superview?.addSubview(toView)
        
        /// Position toView off screen (to the left/right of fromView)
        let screenWidth = UIScreen.main.bounds.size.width
        let scrollRight = toIndex > fromIndex
        let offset = scrollRight ? screenWidth : -screenWidth
        toView.center = CGPoint(x: fromView.center.x + offset, y: toView.center.y)
        
        /// Disable interaction during animation
        view.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            /// Slide the views by -offset
            fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y)
            toView.center = CGPoint(x: toView.center.x - offset, y: toView.center.y)
        }, completion: { _ in
            /// Remove the old view from the tabbar view.
            fromView.removeFromSuperview()
            self.selectedIndex = toIndex
            self.view.isUserInteractionEnabled = true
        })
    }
    
    
    func getNextView() -> UIView? {
        guard let viewControllers = viewControllers else { return selectedViewController?.view }
        /// change the selectedVC to load its view and then change it back
        let currentIndex = selectedIndex
        var nextView: UIView?
        
        switch panLockedDirection {
        case .left:
            if selectedIndex > 0 {
                selectedIndex = selectedIndex - 1
                nextView = viewControllers[selectedIndex].view
                nextView?.alpha = 0
                shouldAddToView = true
            }
        case .right:
            if selectedIndex < viewControllers.count - 1 {
                selectedIndex = selectedIndex + 1
                nextView = viewControllers[selectedIndex].view
                nextView?.alpha = 0
                shouldAddToView = true
            }
        case .center:
            nextView = selectedViewController?.view
        case .none: break
        }
        
        if selectedIndex != currentIndex {
            self.selectedIndex = currentIndex
            nextView?.alpha = 1
        }
        
        return nextView
    }
}






// MARK: - UITabBarControllerDelegate

extension BaseTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let viewControllers = tabBarController.viewControllers,
            let toIndex = viewControllers.firstIndex(of: viewController) else {
                return false
        }
        animateToTab(withIndex: toIndex)
        return true
    }
}







// MARK: - UIGestureRecognizerDelegate

extension BaseTabBarController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
             shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
       /// Don't recognize pan until the default back gesture fails
        if gestureRecognizer == panGesture &&
        otherGestureRecognizer == (selectedViewController as? UINavigationController)?.interactivePopGestureRecognizer {
            return true
        }
        return false
    }
}
