//
//  GetStaticMapOperation.swift
//  FITLGTest_MattQuiros
//
//  Created by Matt Quiros on 21/09/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import UIKit
import CoreLocation

enum GetStaticMapError: LocalizedError {
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

class GetStaticMapOperation: MDAsynchronousOperation<UIImage, GetStaticMapError> {
    
    let coordinate: CLLocationCoordinate2D
    let width: CGFloat
    let height: CGFloat
    var urlTask: URLSessionTask?
    
    init(coordinate: CLLocationCoordinate2D, width: CGFloat, height: CGFloat, completionBlock: MDOperationCompletionBlock?) {
        self.coordinate = coordinate
        self.width = width
        self.height = height
        super.init(completionBlock: completionBlock)
    }
    
    override func main() {
        let session = URLSession(configuration: .default)
        let request = makeRequest()
        let dataTask = session.dataTask(with: request) {[unowned self] (someData, someResponse, someError) in
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
        var urlComponents = URLComponents(string: "https://maps.googleapis.com/maps/api/staticmap")!
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: "AIzaSyB7hkvpYo4zR_Zwtx2GLmhWX4K_e8UfIMk"),
            URLQueryItem(name: "center", value: "\(coordinate.latitude),\(coordinate.longitude)"),
            URLQueryItem(name: "size", value: "\(Int(width))x\(Int(height))"),
            URLQueryItem(name: "markers", value: "color:red|\(coordinate.latitude),\(coordinate.longitude)")
        ]
        let request = URLRequest(url: urlComponents.url!)
        return request
    }
    
}
