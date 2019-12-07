//
//  User.swift
//  Random Users
//
//  Created by Jon Bash on 2019-12-06.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import Foundation

class User: Decodable {
    // MARK: - Properties
    
    var id: Int! // set by UserController immediately after fetched from server
    
    let name: String
    let phoneNumber: String
    let emailAddress: String
    
    let imageInfo: UserImageInfo
    
    // MARK: - Codable
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nameContainer = try container.nestedContainer(keyedBy: CodingKeys.NameKeys.self, forKey: .name)
        
        let title = try nameContainer.decode(String.self, forKey: .title).capitalized
        let first = try nameContainer.decode(String.self, forKey: .first).capitalized
        let last = try nameContainer.decode(String.self, forKey: .last).capitalized
        
        self.name = "\(title). \(first) \(last)"
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        self.emailAddress = try container.decode(String.self, forKey: .email)
        self.imageInfo = try container.decode(UserImageInfo.self, forKey: .imageInfo)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case phoneNumber = "phone"
        case email = "email"
        
        case imageInfo = "picture"
        
        enum NameKeys: String, CodingKey {
            case title, first, last
        }
    }
}

// MARK: - Equatable

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs === rhs
    }
}
