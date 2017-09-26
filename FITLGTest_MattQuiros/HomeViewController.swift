//
//  HomeViewController.swift
//  FITLGTest_MattQuiros
//
//  Created by Matt Quiros on 20/09/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    
    let searchBar = UISearchBar()
    let loadableView = LoadableView()
    let nearbyViewController = NearbyViewController()
    let locationManager = CLLocationManager()
    
    override func loadView() {
        loadableView.retryButton.isHidden = true
        view = loadableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        
        searchBar.delegate = self
        searchBar.isUserInteractionEnabled = false
        navigationItem.titleView = searchBar
        
        embedChildViewController(nearbyViewController, toView: loadableView.dataView, fillSuperview: true)
        
        locationManager.distanceFilter = 300
        locationManager.delegate = self
        checkForGeolocationAccess()
    }
    
    func checkForGeolocationAccess() {
        loadableView.state = .loading
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            requestGeolocationAccess()
            
        case .denied, .restricted:
            showErrorForNoGeolocationAccess()
            
        case .authorizedWhenInUse, .authorizedAlways:
            unlockAppForGeolocationAccess()
        }
    }
    
    func requestGeolocationAccess() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func showErrorForNoGeolocationAccess() {
        loadableView.state = .error(MDError("We have no access to your geolocation.\nPlease enable Location Services for this app in your device settings."))
    }
    
    func unlockAppForGeolocationAccess() {
        searchBar.isUserInteractionEnabled = true
        loadableView.state = .data
        
        locationManager.startUpdatingLocation()
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
    
}

extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last
            else {
                return
        }
        nearbyViewController.userCoordinate = location.coordinate
        nearbyViewController.fetchResults()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted:
            showErrorForNoGeolocationAccess()
            
        case .authorizedAlways, .authorizedWhenInUse:
            unlockAppForGeolocationAccess()
            
        default:
            break
        }
    }
    
}

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
