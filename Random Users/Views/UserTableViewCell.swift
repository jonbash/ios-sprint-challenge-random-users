//
//  UserTableViewCell.swift
//  Random Users
//
//  Created by Jon Bash on 2019-12-06.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    weak var user: User? {
        didSet {
            userNameLabel.text = user?.name
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func prepareForReuse() {
        userImageView.image = nil
        super.prepareForReuse()
    }
}
