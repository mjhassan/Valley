//
//  ValleyNavigationController.swift
//  ValleyDemo
//
//  Created by Jahid Hassan on 11/18/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import UIKit

class ValleyNavigationController: UINavigationController {
    override func popViewController(animated: Bool) -> UIViewController {
        let childrenCount = self.viewControllers.count
        let toViewController = self.viewControllers[childrenCount-2] as! ValleyWaterFallViewControllerProtocol
        let toView = toViewController.transitionCollectionView()
        let popedViewController = self.viewControllers[childrenCount-1] as! UICollectionViewController
        let popView  = popedViewController.collectionView!;
        let indexPath = popView.fromPageIndexPath()
        toViewController.viewWillAppearWithPageIndex(indexPath.row)
        toView?.setToIndexPath(indexPath)
        
        return super.popViewController(animated: animated)!
    }
}

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        
        let fromVCConfromA = (fromVC as? ValleyTransitionProtocol)
        let fromVCConfromB = (fromVC as? ValleyWaterFallViewControllerProtocol)
        let fromVCConfromC = (fromVC as? ValleyDetailViewControllerProtocol)
        
        let toVCConfromA = (toVC as? ValleyTransitionProtocol)
        let toVCConfromB = (toVC as? ValleyWaterFallViewControllerProtocol)
        let toVCConfromC = (toVC as? ValleyDetailViewControllerProtocol)
        if((fromVCConfromA != nil)&&(toVCConfromA != nil)&&(
            (fromVCConfromB != nil && toVCConfromC != nil)||(fromVCConfromC != nil && toVCConfromB != nil))){
            let transition = ValleyTransition()
            transition.presenting = operation == .pop
            return  transition
        }else{
            return nil
        }
        
    }
}
