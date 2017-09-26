//
//  GetNearbyRestaurantsOperation.swift
//  FITLGTest_MattQuiros
//
//  Created by Matt Quiros on 20/09/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import Foundation
import CoreLocation

enum GetNearbyRestaurantsError: LocalizedError {
    case invalidJson
    case noData
    case requestError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidJson:
            return "The returned data is not a valid JSON."
        case .noData:
            return "Google didn't return any data."
        case .requestError(let error):
            return "Google returned the following error:\n\(error.localizedDescription)"
        }
    }
}

class GetNearbyRestaurantsOperation: MDAsynchronousOperation<([SearchResult], String?), GetNearbyRestaurantsError> {
    
    let baseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    let userCoordinate: CLLocationCoordinate2D
    let pageToken: String?
    var urlTask: URLSessionTask?
    
    init(userCoordinate: CLLocationCoordinate2D, pageToken: String?, completionBlock: MDOperationCompletionBlock?) {
        self.userCoordinate = userCoordinate
        self.pageToken = pageToken
        super.init(completionBlock: completionBlock)
    }
    
    override func main() {
        let session = URLSession(configuration: .default)
        let request = makeUrlRequest()
        
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
            
            guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : AnyHashable],
                let results = json["results"] as? [[String : AnyHashable]]
                else {
                    self.result = .error(.invalidJson)
                    return
            }
            
            if self.isCancelled {
                return
            }
            
            let models = self.makeModels(from: results)
            let nextPageToken = json["next_page_token"] as? String
            
            if self.isCancelled {
                return
            }
            
            self.result = .success(models, nextPageToken)
        }
        
        dataTask.resume()
        urlTask = dataTask
    }
    
    func makeUrlRequest() -> URLRequest {
        var urlComponents = URLComponents(string: baseUrl)!
        
        var queryItems = [URLQueryItem(name: "key", value: "AIzaSyCafbJyRHSMn7CDCKPwgim_NNRuvX6B2zI")]
        if let nextPageToken = pageToken {
            queryItems.append(URLQueryItem(name: "pagetoken", value: nextPageToken))
        } else {
            queryItems.append(contentsOf: [
                URLQueryItem(name: "location", value: "\(userCoordinate.latitude),\(userCoordinate.longitude)"),
                URLQueryItem(name: "rankby", value: "distance"),
                URLQueryItem(name: "type", value: "restaurant")
                ]
            )
        }
        
        urlComponents.queryItems = queryItems
        let request = URLRequest(url: urlComponents.url!)
        return request
    }
    
    func makeModels(from results: [[String : AnyHashable]]) -> [SearchResult] {
        var models = [SearchResult]()
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        
        for json in results {
            if self.isCancelled {
                break
            }
            
            var newModel = SearchResult()
            
            newModel.placeId = json["place_id"] as? String
            newModel.name = json["name"] as? String
            newModel.address = json["vicinity"] as? String
            
            if let geometry = json["geometry"] as? [String : AnyHashable],
                let location = geometry["location"] as? [String : AnyHashable],
                let latitude = location["lat"] as? Double,
                let longitude = location["lng"] as? Double {
                let resultCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                newModel.coordinate = resultCoordinate
                
                let resultLocation = CLLocation(latitude: latitude, longitude: longitude)
                newModel.distanceAwayInMetres = resultLocation.distance(from: userLocation)
            }
            
            if let photos = json["photos"] as? [[String : AnyHashable]],
                let firstPhoto =  photos.first,
                let photoId = firstPhoto["photo_reference"] as? String {
                newModel.photoId = photoId
            }
            
            models.append(newModel)
        }
        
        return models
    }
    
}
