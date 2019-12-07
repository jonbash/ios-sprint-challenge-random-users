//
//  UserDetailViewController.swift
//  Random Users
//
//  Created by Jon Bash on 2019-12-06.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import UIKit

protocol UserDetailDelegate: class {
    func userDetailView(_ userDetailView: UserDetailViewController, willDisappearWithoutImageForUser user: User)
}

class UserDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var user: User?
    
    weak var delegate: UserDetailDelegate?
    
    // MARK: - Outlets

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSubViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let user = user, userImageView.image == nil {
            delegate?.userDetailView(self, willDisappearWithoutImageForUser: user)
        }
    }
    
    private func setUpSubViews() {
        userNameLabel.text = user?.name
        phoneNumberLabel.text = user?.phoneNumber
        emailAddressLabel.text = user?.emailAddress
    }
}

// MARK: - User Image Delegate

extension UserDetailViewController: UserImageDelegate {
    func userController(
        _ userController: UserController,
        didCacheImageData imageData: Data?,
        forCell cell: UserTableViewCell?,
        forUser user: User)
    {
        guard let data = imageData,
            user == self.user
            else { return }
        
        DispatchQueue.main.async {
            self.userImageView.image = UIImage(data: data)
        }
    }
}
