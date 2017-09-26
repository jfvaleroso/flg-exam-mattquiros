//
//  SearchResult.swift
//  FITLGTest_MattQuiros
//
//  Created by Matt Quiros on 20/09/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import Foundation
import CoreLocation

struct SearchResult {
    
    var placeId: String?
    var coordinate: CLLocationCoordinate2D?
    var name: String?
    var photoId: String?
    var address: String?
    var distanceAwayInMetres: Double?
    
}
