//
//  UserController.swift
//  Random Users
//
//  Created by Jon Bash on 2019-12-06.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import Foundation

// MARK: - User Image Delegate

protocol UserImageDelegate: class {
    func userController(
        _ userController: UserController,
        didCacheImageData imageData: Data?,
        forCell cell: UserTableViewCell?,
        forUser user: User)
}

class UserController: Decodable {
    // MARK: - Properties
    
    var users: [User]
    
    typealias ImageDataCache = Cache<Int, Data>
    
    lazy private var thumbnailCache = ImageDataCache()
    lazy private var fullImageCache = ImageDataCache()
    
    lazy private var thumbnailFetchQueue = OperationQueue()
    lazy private(set) var thumbnailFetchOps = Cache<Int, ImageFetchOperation>()
    
    lazy private var fullImageFetchQueue = OperationQueue()
    lazy private var fullImageFetchOps = Cache<Int, ImageFetchOperation>()
    
    weak var thumbnailDelegate: UserImageDelegate?
    weak var fullImageDelegate: UserImageDelegate?
    
    // MARK: - Decodable
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.users = try container.decode([User].self, forKey: .users)
        for i in 0 ..< users.count {
            users[i].id = i
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case users = "results"
    }
    
    // MARK: - Image Loading
    
    func loadThumbnail(forCell cell: UserTableViewCell, forUser user: User) {
        // check first if image is already cached
        if let imageData = thumbnailCache[user.id] {
            thumbnailDelegate?.userController(
                self, didCacheImageData: imageData,
                forCell: cell,
                forUser: user)
            return
        }
        
        fetchThumbnail(user, cell)
    }
    
    func loadFullImage(forUser user: User) {
        let imageFetchOp = ImageFetchOperation(user.imageInfo, forFullImage: true)
        let imageSetOp = BlockOperation {
            let data = imageFetchOp.imageData
            self.fullImageCache[user.id] = data
            self.fullImageDelegate?.userController(
                self, didCacheImageData: data,
                forCell: nil,
                forUser: user)
        }
        imageSetOp.addDependency(imageFetchOp)
        
        fullImageFetchQueue.addOperations([imageFetchOp, imageSetOp], waitUntilFinished: false)
        fullImageFetchOps[user.id] = imageFetchOp
    }
    
    // MARK: - Private Methods
    
    private func fetchThumbnail(_ user: User, _ cell: UserTableViewCell) {
        // otherwise, fetch the image
        let thumbnailFetchOp = ImageFetchOperation(user.imageInfo)
        let storeImageToCacheOp = BlockOperation {
            let fetchOp = self.thumbnailFetchOps[user.id]
            guard let imageData = fetchOp?.imageData else {
                return
            }
            self.thumbnailCache[user.id] = imageData
        }
        let postCacheOp = BlockOperation {
            guard let data = self.thumbnailCache[user.id] else { return }
            self.thumbnailDelegate?.userController(
                self, didCacheImageData: data,
                forCell: cell,
                forUser: user)
            self.thumbnailFetchOps[user.id]?.cancel()
        }
        
        postCacheOp.addDependency(storeImageToCacheOp)
        storeImageToCacheOp.addDependency(thumbnailFetchOp)
        
        thumbnailFetchQueue.addOperations(
            [thumbnailFetchOp, storeImageToCacheOp],
            waitUntilFinished: false)
        OperationQueue.main.addOperation(postCacheOp)
        
        thumbnailFetchOps[user.id] = thumbnailFetchOp
    }
}

// MARK: - User Detail Delegate

extension UserController: UserDetailDelegate {
    func userDetailView(
        _ userDetailView: UserDetailViewController,
        willDisappearWithoutImageForUser user: User)
    {
        fullImageFetchOps[user.id]?.cancel()
    }
}
