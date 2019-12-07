//
//  UsersTableViewDataSource.swift
//  Random Users
//
//  Created by Jon Bash on 2019-12-06.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import UIKit

class UsersTableViewDataSource: NSObject, UITableViewDataSource {
    var userController: UserController?

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int
    {
        return userController?.users.count ?? 0
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "UserCell", for: indexPath) as? UserTableViewCell,
            let user = userController?.users[indexPath.row]
            else { return UITableViewCell() }
        cell.user = user
        userController?.loadThumbnail(forCell: cell, forUser: user)

        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt indexPath: IndexPath)
    {
        guard let cell = cell as? UserTableViewCell else { return }
        cell.userImageView.image = nil
        userController?.thumbnailFetchOps[indexPath.row]?.cancel()
    }
}
