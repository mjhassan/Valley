//
//  ValleyDataModel.swift
//  ValleyDemo
//
//  Created by Jahid Hassan on 1/1/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import Foundation

struct PostDataModel: Codable {
    struct Urls: Codable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
    
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let color: String
    let likes: Int
    let isSelfLiked: Bool
    let user: User
    let urls: Urls
    let categories: [Category]
    let links: Links
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case color
        case likes
        case isSelfLiked = "liked_by_user"
        case user
        case urls
        case categories
        case links
    }
}
