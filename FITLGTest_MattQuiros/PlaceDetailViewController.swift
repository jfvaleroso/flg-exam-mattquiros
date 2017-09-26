//
//  PlaceDetailViewController.swift
//  FITLGTest_MattQuiros
//
//  Created by Matt Quiros on 21/09/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import UIKit
import CoreLocation

class PlaceDetailViewController: UIViewController {
    
    let placeDetailView = PlaceDetailView()
    var placeId: String?
    var userCoordinate: CLLocationCoordinate2D?
    var place: Place?
    let operationQueue = OperationQueue()
    
    init(placeId: String, userCoordinate: CLLocationCoordinate2D) {
        self.placeId = placeId
        self.userCoordinate = userCoordinate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        view = placeDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        
        fetchPlaceDetails()
    }
    
    func fetchPlaceDetails() {
        guard let placeId = placeId,
            let userCoordinate = userCoordinate
            else {
                return
        }
        
        let getOp = GetPlaceDetailOperation(placeId: placeId, userCoordinate: userCoordinate) {[weak self] (result) in
            guard let weakSelf = self
                else {
                    return
            }
            MDDispatcher.asyncRunInMainThread {
                switch result {
                case .error(let error):
                    weakSelf.placeDetailView.state = .error(error)
                case .success(let place):
                    weakSelf.place = place
                    weakSelf.updateDataViewForPlace()
                    weakSelf.placeDetailView.state = .data
                    weakSelf.fetchPlacePhoto()
                    weakSelf.fetchPlaceStaticMap()
                case .none:
                    return
                }
            }
        }
        
        placeDetailView.state = .loading
        operationQueue.addOperation(getOp)
    }
    
    func updateDataViewForPlace() {
        guard let place = place
            else {
                return
        }
        
        placeDetailView.nameLabel.text = place.name ?? "(No name)"
        placeDetailView.addressLabel.text = place.address ?? "(No address)"
        
        if let distanceInMetres = place.distanceAwayInMetres {
            let distanceInKm = distanceInMetres / 1000
            placeDetailView.distanceLabel.text = String(format: "%.2f km away", distanceInKm)
        } else {
            placeDetailView.distanceLabel.text = "(No distance info)"
        }
        
        placeDetailView.fullJsonLabel.text = place.fullJson
    }
    
    func fetchPlacePhoto() {
        guard let photoId = place?.photoId
            else {
                placeDetailView.placeImageView.contentMode = .scaleAspectFit
                placeDetailView.placeImageView.image = UIImage(named: "noPhoto")
                return
        }
        
        let scale = UIScreen.main.scale
        let width = placeDetailView.placeImageView.bounds.size.width * scale
        let height = placeDetailView.placeImageView.bounds.size.height * scale
        let getOp = GetPhotoOperation(photoId: photoId, width: width, height: height) {[weak self] (result) in
            guard let weakSelf = self
                else {
                    return
            }
            MDDispatcher.asyncRunInMainThread {
                switch result {
                case .success(let image):
                    weakSelf.placeDetailView.placeImageView.image = image
                default:
                    weakSelf.placeDetailView.placeImageView.image = UIImage(named: "noPhoto")
                }
            }
        }
        operationQueue.addOperation(getOp)
    }
    
    func fetchPlaceStaticMap() {
        guard let coordinate = place?.coordinate
            else {
                return
        }
        
        let scale = UIScreen.main.scale
        let width = placeDetailView.placeImageView.bounds.size.width * scale
        let height = placeDetailView.placeImageView.bounds.size.height * scale
        let getOp = GetStaticMapOperation(coordinate: coordinate, width: width, height: height) {[weak self] (result) in
            guard let weakSelf = self
                else {
                    return
            }
            MDDispatcher.asyncRunInMainThread {
                switch result {
                case .success(let image):
                    weakSelf.placeDetailView.mapImageView.image = image
                default:
                    weakSelf.placeDetailView.mapImageView.image = UIImage(named: "noPhoto")
                }
            }
        }
        operationQueue.addOperation(getOp)
    }
    
    deinit {
        operationQueue.cancelAllOperations()
    }
    
}
