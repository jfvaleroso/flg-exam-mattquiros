//
//  GetPhotoOperation.swift
//  FITLGTest_MattQuiros
//
//  Created by Matt Quiros on 20/09/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import UIKit

enum GetPhotoError: LocalizedError {
    case invalidImageData
    case noData
    case requestError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "The returned data is not a valid image."
        case .noData:
            return "Google didn't return any data."
        case .requestError(let error):
            return "Google returned the following error:\n\(error.localizedDescription)"
        }
    }
}

fileprivate let kSharedSession = URLSession(configuration: .default)

class GetPhotoOperation: MDAsynchronousOperation<UIImage, GetPhotoError> {
    
    let photoId: String
    let width: CGFloat
    let height: CGFloat
    
    var urlTask: URLSessionTask?
    
    init(photoId: String, width: CGFloat, height: CGFloat, completionBlock: MDOperationCompletionBlock?) {
        self.photoId = photoId
        self.width = width
        self.height = height
        super.init(completionBlock: completionBlock)
    }
    
    override func main() {
        let request = makeRequest()
        let dataTask = kSharedSession.dataTask(with: request) {[unowned self] (someData, someResponse, someError) in
            defer {
                self.finish()
            }
            
            if self.isCancelled {
                return
            }
            
            if let error = someError {
                self.result = .error(.requestError(error))
                return
            }
            
            guard let data = someData
                else {
                    self.result = .error(.noData)
                    return
            }
            
            guard let image = UIImage(data: data)
                else {
                    self.result = .error(.invalidImageData)
                    return
            }
            
            self.result = .success(image)
        }
        
        dataTask.resume()
        urlTask = dataTask
    }
    
    func makeRequest() -> URLRequest {
        let baseUrl = "https://maps.googleapis.com/maps/api/place/photo"
        var urlComponents = URLComponents(string: baseUrl)!
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: "AIzaSyCafbJyRHSMn7CDCKPwgim_NNRuvX6B2zI"),
            URLQueryItem(name: "photo_reference", value: photoId),
            URLQueryItem(name: "maxwidth", value: "\(Int(width))"),
            URLQueryItem(name: "maxheight", value: "\(Int(height))")
        ]
        let request = URLRequest(url: urlComponents.url!)
        return request
    }
    
}
