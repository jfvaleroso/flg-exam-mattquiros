//
//  PlaceDetailView.swift
//  FITLGTest_MattQuiros
//
//  Created by Matt Quiros on 21/09/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import UIKit

class PlaceDetailView: LoadableView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var fullJsonLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func setup() {
        super.setup()
        let viewFromNib = viewFromOwnedNib()
        dataView.addSubviewsAndFill(viewFromNib)
        
        clearAllBackgroundColors()
        backgroundColor = .white
        
        scrollView.alwaysBounceVertical = true
        
        placeImageView.backgroundColor = .hex(0xeeeeee)
        placeImageView.contentMode = .scaleAspectFill
        placeImageView.clipsToBounds = true
        
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.font = .boldSystemFont(ofSize: 24)
        
        addressLabel.numberOfLines = 0
        addressLabel.lineBreakMode = .byWordWrapping
        addressLabel.font = .systemFont(ofSize: 17)
        
        distanceLabel.numberOfLines = 0
        distanceLabel.lineBreakMode = .byWordWrapping
        distanceLabel.font = .systemFont(ofSize: 14)
        
        mapImageView.backgroundColor = .hex(0xeeeeee)
        mapImageView.contentMode = .scaleAspectFill
        mapImageView.clipsToBounds = true
        
        fullJsonLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: UIFontWeightRegular)
        fullJsonLabel.numberOfLines = 0
        fullJsonLabel.lineBreakMode = .byWordWrapping
    }
    
}
