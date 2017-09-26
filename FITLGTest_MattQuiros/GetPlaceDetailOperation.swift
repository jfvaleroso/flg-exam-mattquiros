//
//  GetPlaceDetailOperation.swift
//  FITLGTest_MattQuiros
//
//  Created by Matt Quiros on 21/09/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import Foundation
import CoreLocation

enum GetPlaceDetailError: LocalizedError {
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

class GetPlaceDetailOperation: MDAsynchronousOperation<Place, GetPlaceDetailError> {
    
    let placeId: String
    let userCoordinate: CLLocationCoordinate2D
    var urlTask: URLSessionTask?
    
    init(placeId: String, userCoordinate: CLLocationCoordinate2D, completionBlock: MDOperationCompletionBlock?) {
        self.placeId = placeId
        self.userCoordinate = userCoordinate
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
            
            guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : AnyHashable],
                let result = json["result"] as? [String : AnyHashable]
                else {
                    self.result = .error(.invalidJson)
                    return
            }
            
            var place = Place()
            
            place.placeId = result["place_id"] as? String
            place.name = result["name"] as? String
            place.address = result["formatted_address"] as? String
            
            if let geometry = result["geometry"] as? [String : AnyHashable],
                let location = geometry["location"] as? [String : AnyHashable],
                let latitude = location["lat"] as? Double,
                let longitude = location["lng"] as? Double {
                let placeLocation = CLLocation(latitude: latitude, longitude: longitude)
                place.coordinate = placeLocation.coordinate
                
                let userLocation = CLLocation(latitude: self.userCoordinate.latitude, longitude: self.userCoordinate.longitude)
                place.distanceAwayInMetres = placeLocation.distance(from: userLocation)
            }
            
            if let photos = result["photos"] as? [[String : AnyHashable]],
                let firstPhotoId = photos.first?["photo_reference"] as? String {
                place.photoId = firstPhotoId
            }
            
            place.fullJson = String(data: data, encoding: .utf8)
            
            self.result = .success(place)
        }
        
        dataTask.resume()
        urlTask = dataTask
    }
    
    fileprivate func makeRequest() -> URLRequest {
        var urlComponents = URLComponents(string: "https://maps.googleapis.com/maps/api/place/details/json")!
        urlComponents.queryItems = [
            URLQueryItem(name: "placeid", value: placeId),
            URLQueryItem(name: "key", value: "AIzaSyCRUFUMPWkjtStT9KWi7ewl2HJjqQ85SIo")
        ]
        let request = URLRequest(url: urlComponents.url!)
        return request
    }
    
}
