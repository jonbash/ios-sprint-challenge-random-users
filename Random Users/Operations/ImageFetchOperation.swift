//
//  ImageFetchOperation.swift
//  Astronomy
//
//  Created by Jon Bash on 2019-12-05.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class ImageFetchOperation: ConcurrentOperation {
    
    // MARK: - Properties
    
    var imageInfo: UserImageInfo
    var forFullImage: Bool = false
    
    var imageData: Data?
    
    private var url: URL? {
        return forFullImage ? imageInfo.fullImageURL : imageInfo.thumbnailURL
    }
    
    lazy private var dataTask: URLSessionDataTask? = {
        guard let url = url else { return nil }
        let task = URLSession.shared.dataTask(
            with: url,
            completionHandler: dataTaskDidComplete(with:_:_:))
        return task
    }()
    
    // MARK: - Init
    
    init(_ imageInfo: UserImageInfo, forFullImage: Bool = false) {
        self.imageInfo = imageInfo
        self.forFullImage = forFullImage
    }
    
    // MARK: - Methods
    
    override func start() {
        state = .isExecuting
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
        state = .isFinished
    }
    
    private func dataTaskDidComplete(
        with possibleData: Data?,
        _ possibleResponse: URLResponse?,
        _ possibleError: Error?
    ) {
        defer {
            self.imageData = possibleData
            self.state = .isFinished
        }
        
        if let error = possibleError as NSError?,
            error.code == -999 {
            return
        } else if let error = possibleError {
            print("Error fetching image: \(error)")
            if let response = possibleResponse {
                print("Response:\n\(response)")
            }
            return
        }
    }
}
