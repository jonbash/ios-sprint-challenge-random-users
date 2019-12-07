//
//  UsersTableViewController.swift
//  Random Users
//
//  Created by Jon Bash on 2019-12-06.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {
    // MARK: - Properties
    
    private var apiController = APIController()
    private var dataSource = UsersTableViewDataSource()
    
    private var userController: UserController? {
        get {
            return dataSource.userController
        } set {
            dataSource.userController = newValue
            dataSource.userController?.thumbnailDelegate = self
            if newValue != nil {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.dataSource = dataSource
    }
    
    // MARK: - Actions
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        userController = nil
        tableView.reloadData()
        apiController.fetchUsers(completion: didFetchUsers(with:))
    }
    
    private func didFetchUsers(with result: Result<UserController, Error>) {
        do {
            userController = try result.get()
            print("got user data set")
        } catch {
            print("Error fetching users: \(error)")
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowUserDetailSegue" {
            guard let detailVC = segue.destination as? UserDetailViewController,
                let index = tableView.indexPathForSelectedRow?.row,
                let user = userController?.users[index]
                else { return }
            
            userController?.fullImageDelegate = detailVC
            detailVC.user = user
            detailVC.delegate = userController
            userController?.loadFullImage(forUser: user)
        }
    }
}

// MARK: - User Image Delegate

extension UsersTableViewController: UserImageDelegate {
    func userController(
        _ userController: UserController,
        didCacheImageData data: Data?,
        forCell cell: UserTableViewCell?,
        forUser user: User)
    {
        guard let data = data, cell?.user == user else {
            userController.thumbnailFetchOps[user.id]?.cancel()
            return
        }
        
        cell?.userImageView.image = UIImage(data: data)
    }
}
