//
//  UIViewExtensions.swift
//  ValleyDemo
//
//  Created by Jahid Hassan on 11/18/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import UIKit

extension UIView {
    func origin (_ point : CGPoint) {
        frame.origin.x = point.x
        frame.origin.y = point.y
    }
}
