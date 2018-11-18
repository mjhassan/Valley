//
//  MockHelper.swift
//  ValleyTests
//
//  Created by Jahid Hassan on 11/17/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import UIKit

final class MockHelper {
    var image: UIImage {
        return UIImage(named: "MindValley", in: Bundle(for: type(of: self).self), compatibleWith: nil)!
    }
    
    func imageResponseData() -> Data {
        return image.pngData()!
    }
}
