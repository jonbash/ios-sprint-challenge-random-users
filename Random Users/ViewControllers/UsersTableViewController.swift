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
    
    private var users = [RandomUser]()
    private var apiController = APIController()
    
    lazy private var thumbnailCache = Cache<Int, Data>()
    
    lazy private var thumbnailFetchQueue = OperationQueue()
    lazy private var thumbnailFetchOps = [Int: FetchThumbnailOperation]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "UserCell", for: indexPath) as? UserTableViewCell
            else { return UITableViewCell() }
        
        cell.user = users[indexPath.row]
        loadThumbnail(forCell: cell, forItemAt: indexPath)

        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        apiController.fetchUsers(completion: didFetchUsers(with:))
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

    // MARK: - Private Methods
    
    private func didFetchUsers(with result: Result<[RandomUser], Error>) {
        do {
            users = try result.get()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error fetching users: \(error)")
        }
    }
    
    private func loadThumbnail(forCell cell: UserTableViewCell, forItemAt indexPath: IndexPath) {
        let imageInfo = users[indexPath.row].imageInfo
        
        // check first if image is already cached
        if let imageData = thumbnailCache[indexPath.row] {
            cell.userImageView.image = UIImage(data: imageData)
            return
        }
        
        // otherwise, fetch the image
        let thumbnailFetchOp = FetchThumbnailOperation(imageInfo)
        let storeImageToCacheOp = BlockOperation {
            guard let imageData = thumbnailFetchOp.thumbnailData else {
                return
            }
            self.thumbnailCache[indexPath.row] = imageData
        }
        let checkCellReuseOp = BlockOperation {
            // if present, use cached image for cell & return
            if let imageData = self.thumbnailCache[indexPath.row],
                let image = UIImage(data: imageData)
            {
                thumbnailFetchOp.cancel()
                cell.userImageView.image = image
            }
        }
        
        checkCellReuseOp.addDependency(storeImageToCacheOp)
        storeImageToCacheOp.addDependency(thumbnailFetchOp)
        
        thumbnailFetchQueue.addOperations([thumbnailFetchOp, storeImageToCacheOp], waitUntilFinished: false)
        OperationQueue.main.addOperation(checkCellReuseOp)
        
        thumbnailFetchOps[indexPath.row] = thumbnailFetchOp
    }
}
