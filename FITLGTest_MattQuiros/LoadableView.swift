//
//  LoadableView.swift
//  FITLGTest_MattQuiros
//
//  Created by Matt Quiros on 20/09/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import UIKit

@IBDesignable
class LoadableView: UIView, TBLoadableView {
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: MDButton!
    @IBOutlet weak var retryButtonLabel: UILabel!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var dataView: UIView!
    
    var state = TBLoadableViewState.initial {
        didSet {
            updateView(forState: state)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    func setup() {
        let nibView = viewFromOwnedNib(nibName: md_getClassName(LoadableView.self))
        addSubviewsAndFill(nibView)
        
        clearAllBackgroundColors()
        backgroundColor = .white
        updateView(forState: .initial)
        
        errorLabel.numberOfLines = 0
        errorLabel.lineBreakMode = .byWordWrapping
        errorLabel.textAlignment = .center
        retryButtonLabel.text = "Retry"
        
        noDataLabel.text = "No data found."
        noDataLabel.textAlignment = .center
        noDataLabel.numberOfLines = 0
        noDataLabel.lineBreakMode = .byWordWrapping
    }
    
    func updateView(forState state: TBLoadableViewState) {
        if case .loading = state {
            loadingView.startAnimating()
            loadingView.isHidden = false
        } else {
            loadingView.stopAnimating()
            loadingView.isHidden = true
        }
        
        if case .error(let error) = state {
            errorView.isHidden = false
            if let localizedError = error as? LocalizedError {
                errorLabel.text = localizedError.errorDescription
            } else {
                errorLabel.text = error.localizedDescription
            }
        } else {
            errorView.isHidden = true
            errorLabel.text = nil
        }
        
        if case .noData = state {
            noDataLabel.isHidden = false
        } else {
            noDataLabel.isHidden = true
        }
        
        if case .data = state {
            dataView.isHidden = false
        } else {
            dataView.isHidden = true
        }
    }
    
}
