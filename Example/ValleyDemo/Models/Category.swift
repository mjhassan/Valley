//
//  Category.swift
//  ValleyDemo
//
//  Created by Jahid Hassan on 11/17/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import Foundation

struct Category: Codable {
    var id: Int
    var title: String
    var photoCount: Int
    var links: Links
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case photoCount = "photo_count"
        case links
    }
}
