//
//  ValleyTransition.swift
//  ValleyDemo
//
//  Created by Jahid Hassan on 11/18/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import UIKit

@objc protocol ValleyTransitionProtocol {
    func transitionCollectionView() -> UICollectionView!
}

@objc protocol ValleyTansitionWaterfallGridViewProtocol {
    func snapShotForTransition() -> UIView!
}

@objc protocol ValleyWaterFallViewControllerProtocol: ValleyTransitionProtocol {
    func viewWillAppearWithPageIndex(_ pageIndex : NSInteger)
}

@objc protocol ValleyDetailViewControllerProtocol: ValleyTransitionProtocol{
    func pageViewCellScrollViewContentOffset() -> CGPoint
}

private let animationDuration = 0.35
private let animationScale = screenWidth / gridWidth

class ValleyTransition : NSObject , UIViewControllerAnimatedTransitioning{
    var presenting = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        
        if presenting {
            let toView = toViewController.view!
            containerView.addSubview(toView)
            toView.isHidden = true
            
            let waterFallView = (toViewController as! ValleyTransitionProtocol).transitionCollectionView()!
            let pageView = (fromViewController as! ValleyTransitionProtocol).transitionCollectionView()!
            waterFallView.layoutIfNeeded()
            let indexPath = pageView.fromPageIndexPath()
            let gridView = waterFallView.cellForItem(at: indexPath)
            let leftUpperPoint = gridView!.convert(CGPoint.zero, to: toViewController.view)
            
            let snapShot = (gridView as! ValleyTansitionWaterfallGridViewProtocol).snapShotForTransition()
            snapShot?.transform = CGAffineTransform(scaleX: animationScale, y: animationScale)
            let pullOffsetY = (fromViewController as! ValleyDetailViewControllerProtocol).pageViewCellScrollViewContentOffset().y
            let offsetY : CGFloat = fromViewController.navigationController!.isNavigationBarHidden ? 0.0 : navigationHeaderAndStatusbarHeight
            snapShot?.origin(CGPoint(x: 0, y: -pullOffsetY+offsetY))
            containerView.addSubview(snapShot!)
            
            toView.isHidden = false
            toView.alpha = 0
            toView.transform = (snapShot?.transform)!
            toView.frame = CGRect(x: -(leftUpperPoint.x * animationScale),y: -((leftUpperPoint.y-offsetY) * animationScale+pullOffsetY+offsetY),
                                  width: toView.frame.size.width, height: toView.frame.size.height)
            let whiteViewContainer = UIView(frame: screenBounds)
            whiteViewContainer.backgroundColor = UIColor.white
            containerView.addSubview(snapShot!)
            containerView.insertSubview(whiteViewContainer, belowSubview: toView)
            
            UIView.animate(withDuration: animationDuration, animations: {
                snapShot?.transform = CGAffineTransform.identity
                snapShot?.frame = CGRect(x: leftUpperPoint.x, y: leftUpperPoint.y, width: (snapShot?.frame.size.width)!, height: (snapShot?.frame.size.height)!)
                toView.transform = CGAffineTransform.identity
                toView.frame = CGRect(x: 0, y: 0, width: toView.frame.size.width, height: toView.frame.size.height);
                toView.alpha = 1
            }, completion:{finished in
                if finished {
                    snapShot?.removeFromSuperview()
                    whiteViewContainer.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
            })
        }
        else {
            let fromView = fromViewController.view!
            let toView = toViewController.view
            
            let waterFallView : UICollectionView = (fromViewController as! ValleyTransitionProtocol).transitionCollectionView()
            let pageView : UICollectionView = (toViewController as! ValleyTransitionProtocol).transitionCollectionView()
            
            containerView.addSubview(fromView)
            containerView.addSubview(toView!)
            
            let indexPath = waterFallView.toIndexPath()
            let gridView = waterFallView.cellForItem(at: indexPath as IndexPath)
            
            let leftUpperPoint = gridView!.convert(CGPoint.zero, to: nil)
            pageView.isHidden = true
            pageView.scrollToItem(at: indexPath as IndexPath, at:.centeredHorizontally, animated: false)
            
            let offsetY : CGFloat = fromViewController.navigationController!.isNavigationBarHidden ? 0.0 : navigationHeaderAndStatusbarHeight
            let offsetStatuBar : CGFloat = fromViewController.navigationController!.isNavigationBarHidden ? 0.0 :
            statubarHeight;
            let snapShot = (gridView as! ValleyTansitionWaterfallGridViewProtocol).snapShotForTransition()
            containerView.addSubview(snapShot!)
            snapShot?.origin(leftUpperPoint)
            
            UIView.animate(withDuration: animationDuration, animations: {
                snapShot?.transform = CGAffineTransform(scaleX: animationScale, y: animationScale)
                snapShot?.frame = CGRect(x: 0, y: offsetY, width: (snapShot?.frame.size.width)!, height: (snapShot?.frame.size.height)!)
                
                fromView.alpha = 0
                fromView.transform = (snapShot?.transform)!
                fromView.frame = CGRect(x: -(leftUpperPoint.x)*animationScale,
                                        y: -(leftUpperPoint.y-offsetStatuBar)*animationScale+offsetStatuBar,
                                        width: fromView.frame.size.width,
                                        height: fromView.frame.size.height)
            },completion:{finished in
                if finished {
                    snapShot?.removeFromSuperview()
                    pageView.isHidden = false
                    fromView.transform = CGAffineTransform.identity
                    transitionContext.completeTransition(true)
                }
            })
        }
    }
}
