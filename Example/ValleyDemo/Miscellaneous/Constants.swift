//
//  Constants.swift
//  ValleyDemo
//
//  Created by Jahid Hassan on 11/18/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import UIKit

public let navigationHeight: CGFloat = 44.0
public let statubarHeight: CGFloat = 20.0
public let navigationHeaderAndStatusbarHeight: CGFloat = navigationHeight + statubarHeight
public let maxImageHeight: CGFloat = 400.0

public var screenBounds: CGRect {
    return UIScreen.main.bounds
}

public var screenWidth: CGFloat {
    return screenBounds.width
}

public var screenHeight: CGFloat {
    return screenBounds.height
}

public var gridWidth: CGFloat {
    return (screenWidth / 2) - 5.0
}
