//
//  SearchResultCell.swift
//  FITLGTest_MattQuiros
//
//  Created by Matt Quiros on 20/09/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var thumbnailImageViewHeight: NSLayoutConstraint!
    
    fileprivate let downloadQueue = OperationQueue()
    fileprivate var currentPhotoId: String?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        let viewFromNib = viewFromOwnedNib()
        viewFromNib.isUserInteractionEnabled = false
        contentView.addSubviewsAndFill(viewFromNib)
        
        thumbnailImageView.backgroundColor = .hex(0xeeeeee)
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.font = .boldSystemFont(ofSize: 17)
        
        addressLabel.numberOfLines = 0
        addressLabel.lineBreakMode = .byWordWrapping
        addressLabel.font = .systemFont(ofSize: 14)
        
        distanceLabel.numberOfLines = 0
        distanceLabel.lineBreakMode = .byWordWrapping
        distanceLabel.font = .systemFont(ofSize: 14)
        distanceLabel.textColor = .hex(0xaaaaaa)
    }
    
    func showSearchResult(_ searchResult: SearchResult?) {
        guard let searchResult = searchResult
            else {
                currentPhotoId = nil
                
                thumbnailImageView.image = nil
                nameLabel.text = nil
                addressLabel.text = nil
                distanceLabel.text = nil
                return
        }
        
        if let photoId = searchResult.photoId {
            currentPhotoId = photoId
            
            let dimension = thumbnailImageViewHeight.constant * UIScreen.main.scale
            let getOp = GetPhotoOperation(photoId: photoId, width: dimension, height: dimension) {[weak self] result in
                guard let weakSelf = self,
                    weakSelf.currentPhotoId == photoId
                    else {
                        return
                }
                
                MDDispatcher.asyncRunInMainThread {
                    switch result {
                    case .success(let image):
                        weakSelf.thumbnailImageView.image = image
                    default:
                        weakSelf.thumbnailImageView.image = nil
                    }
                }
            }
            downloadQueue.addOperation(getOp)
        } else {
            thumbnailImageView.image = UIImage(named: "noPhoto")
        }
        
        nameLabel.text = {
            if let name = searchResult.name {
                return name
            }
            return "(No name)"
        }()
        
        addressLabel.text = {
            if let address = searchResult.address {
                return address
            }
            return "(No address)"
        }()
        
        distanceLabel.text = {
            if let distanceInMetres = searchResult.distanceAwayInMetres {
                let distanceInKilometres = distanceInMetres / 1000
                return String(format: "%0.2f km away", distanceInKilometres)
            }
            return "(No distance info)"
        }()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        currentPhotoId = nil
        thumbnailImageView.image = nil
        nameLabel.text = nil
        addressLabel.text = nil
        distanceLabel.text = nil
    }
    
}
