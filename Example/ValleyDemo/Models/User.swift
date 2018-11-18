//
//  User.swift
//  ValleyDemo
//
//  Created by Jahid Hassan on 11/17/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import Foundation

struct User: Codable {
    struct ProfileImage: Codable {
        var small: String
        var medium: String
        var large: String
    }
    
    var id: String
    var username: String
    var name: String
    var profileImage: ProfileImage
    var links: Links
    
    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case name
        case profileImage = "profile_image"
        case links
    }
}
