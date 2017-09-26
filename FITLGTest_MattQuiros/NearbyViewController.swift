//
//  NearbyViewController.swift
//  FITLGTest_MattQuiros
//
//  Created by Matt Quiros on 20/09/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import UIKit
import CoreLocation

fileprivate enum ViewId: String {
    case searchResultCell = "searchResultCell"
}

class NearbyViewController: UIViewController {
    
    var userCoordinate: CLLocationCoordinate2D?
    
    fileprivate let operationQueue = OperationQueue()
    fileprivate var nextPageToken: String?
    fileprivate var results = [SearchResult]()
    fileprivate var hasReachedEndOfResults = false
    
    fileprivate let loadableView = LoadableView()
    fileprivate let tableView = UITableView(frame: .zero, style: .plain)
    
    override func loadView() {
        loadableView.dataView.addSubviewsAndFill(tableView)
        view = loadableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: ViewId.searchResultCell.rawValue)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 96
    }
    
    func fetchResults() {
        fetchResults(shouldStartOver: true)
    }
    
    fileprivate func fetchResults(shouldStartOver: Bool) {
        guard let userCoordinate = userCoordinate
            else {
                return
        }
        
        if shouldStartOver {
            operationQueue.cancelAllOperations()
            results = []
            nextPageToken = nil
            loadableView.state = .loading
            hasReachedEndOfResults = false
        } else if operationQueue.operationCount > 0 || hasReachedEndOfResults == true {
            return
        }
        
        let getOp = GetNearbyRestaurantsOperation(userCoordinate: userCoordinate, pageToken: nextPageToken) {[weak self] (result) in
            guard let weakSelf = self
                else {
                    return
            }
            
            switch result {
            case .error(let error):
                MDDispatcher.asyncRunInMainThread {
                    weakSelf.loadableView.state = .error(error)
                }
                
            case .success(let models, let nextPageToken):
                MDDispatcher.asyncRunInMainThread {
                    if models.isEmpty && weakSelf.loadableView.dataView.isHidden {
                        weakSelf.loadableView.state = .noData
                    } else {
                        weakSelf.results.append(contentsOf: models)
                        weakSelf.nextPageToken = nextPageToken
                        if weakSelf.hasReachedEndOfResults == false && nextPageToken == nil {
                            weakSelf.hasReachedEndOfResults = true
                        }
                        
                        weakSelf.tableView.reloadData()
                        weakSelf.loadableView.state = .data
                    }
                }
                
            case .none:
                return
            }
        }
        
        operationQueue.addOperation(getOp)
    }
    
}

extension NearbyViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewId.searchResultCell.rawValue) as! SearchResultCell
        cell.showSearchResult(results[indexPath.row])
        return cell
    }
    
}

extension NearbyViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let navigationController = navigationController,
            let placeId = results[indexPath.row].placeId,
            let userCoordinate = userCoordinate {
            let detailViewController = PlaceDetailViewController(placeId: placeId, userCoordinate: userCoordinate)
            navigationController.pushViewController(detailViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == results.count - 1 {
            fetchResults(shouldStartOver: false)
        }
    }
    
}
