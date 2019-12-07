//
//  APIController.swift
//  Random Users
//
//  Created by Jon Bash on 2019-12-06.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import Foundation

class APIController {
    // MARK: - Properties
    
    typealias FetchTaskCompletionHandler = (Result<UserController, Error>) -> ()
    
    private let baseURL = URL(string: "https://randomuser.me/api/")!
    private lazy var defaultURL: URL = {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "inc", value: "name,email,phone,picture"),
            URLQueryItem(name: "results", value: "1000")
        ]
        return components?.url ?? baseURL
    }()
    
    private weak var fetchTask: URLSessionDataTask?
    private var fetchCompletion: FetchTaskCompletionHandler?

    // MARK: - Fetch Methods
    
    func fetchUsers(completion: @escaping FetchTaskCompletionHandler) {
        var request = URLRequest(url: defaultURL)
        request.httpMethod = "GET"
        
        fetchCompletion = completion
        
        fetchTask = URLSession.shared.dataTask(
            with: request,
            completionHandler: fetchTaskDidFinish(with:_:_:))
        fetchTask?.resume()
    }
    
    private func fetchTaskDidFinish(with data: Data?, _ response: URLResponse?, _ error: Error?) {
        if let error = error {
            print("ERROR FETCHING USERS\nERROR:\n\(error)")
            if let response = response {
                print("RESPONSE:\n\(response)")
            }
            fetchCompletion?(.failure(error))
            return
        }
        
        guard let data = data else {
            print("ERROR FETCHING USERS\nNO DATA")
            fetchCompletion?(.failure(NSError()))
            return
        }
        
        do {
            let userController = try JSONDecoder().decode(UserController.self, from: data)
            fetchCompletion?(.success(userController))
        } catch {
            print("ERROR DECODING FETCHED USERS\nERROR:\n\(error)")
            if let rawData = String(data: data, encoding: .utf8) {
                print("DATA:\n\(rawData)")
            }
            fetchCompletion?(.failure(error))
        }
    }
}
