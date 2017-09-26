//
//  TBLoadableView.swift
//  Mold
//
//  Created by Matt Quiros on 21/08/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import Foundation

enum TBLoadableViewState: Equatable {
    
    case initial, loading, data, noData, error(Error)
    
    static func ==(lhs: TBLoadableViewState, rhs: TBLoadableViewState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial),
             (.loading, .loading),
             (.data, .data),
             (.noData, .noData),
             (.error(_), .error(_)):
            return true
            
        default:
            return false
        }
    }
    
}

protocol TBLoadableView {
    
    var state: TBLoadableViewState { get set }
    
}
