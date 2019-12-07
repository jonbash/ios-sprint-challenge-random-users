//
//  UserImageInfo.swift
//  Random Users
//
//  Created by Jon Bash on 2019-12-06.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import Foundation

struct UserImageInfo: Decodable {
    let thumbnailURL: URL?
    let fullImageURL: URL?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let thumbnailURLString = try container.decode(String.self, forKey: .thumbnailURL)
        let fullImageURLString = try container.decode(String.self, forKey: .fullImageURL)
        
        self.thumbnailURL = URL(string: thumbnailURLString)
        self.fullImageURL = URL(string: fullImageURLString)
    }
    
    enum CodingKeys: String, CodingKey {
        case thumbnailURL = "thumbnail"
        case fullImageURL = "large"
    }
}
