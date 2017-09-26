//
//  UIView.swift
//  Mold
//
//  Created by Matt Quiros on 4/15/15.
//  Copyright (c) 2015 Matt Quiros. All rights reserved.
//

import UIKit

public extension UIView {
    
    public class func disableAutoresizingMasksInViews(_ views: UIView...) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    /**
    Adds multiple subviews in order. Later arguments are placed on top of the views
    preceding them.
    */
    public func addSubviews(_ views: UIView ...) {
        for view in views {
            self.addSubview(view)
        }
    }
    
    /**
     Add subviews and fill the superview. Subviews are placed on top of the preding subviews.
     */
    public func addSubviewsAndFill(_ views: UIView ...) {
        for view in views {
            self.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        }
    }
    
    public func fillSuperview() {
        if let superview = self.superview {
            translatesAutoresizingMaskIntoConstraints = false
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        }
    }
    
    public class func instantiateFromNib() -> Self {
        return self.instantiateFromNibInBundle(Bundle.main)
    }
    
    public class func clearBackgroundColors(_ views: UIView...) {
        for view in views {
            view.backgroundColor = UIColor.clear
        }
    }
    
    public class func clearBackgroundColors(_ views: [UIView]) {
        for view in views {
            view.backgroundColor = UIColor.clear
        }
    }
    
    public func clearAllBackgroundColors() {
        UIView.clearAllBackgroundColors(from: self)
    }
    
    public class func clearAllBackgroundColors(from view: UIView) {
        if #available(iOS 9.0, *),
            let stackView = view as? UIStackView {
            for arrangedSubview in stackView.arrangedSubviews {
                clearAllBackgroundColors(from: arrangedSubview)
            }
        } else {
            view.backgroundColor = .clear
            for subview in view.subviews {
                clearAllBackgroundColors(from: subview)
            }
        }
    }
    
    public class func nib() -> UINib {
        return UINib(nibName: md_getClassName(self), bundle: Bundle.main)
    }
    
    public func viewFromOwnedNib(nibName: String? = nil) -> UIView {
        let bundle = Bundle(for: self.classForCoder)
        return {
            if let nibName = nibName {
                return bundle.loadNibNamed(nibName, owner: self, options: nil)!.last as! UIView
            }
            return bundle.loadNibNamed(md_getClassName(self), owner: self, options: nil)!.last as! UIView
        }()
    }
    
}

// MARK: - Private functions
extension UIView {
    
    class func instantiateFromNibInBundle<T: UIView>(_ bundle: Bundle) -> T {
        let objects = bundle.loadNibNamed(md_getClassName(self), owner: self, options: nil)!
        let view = objects.last as! T
        return view
    }
    
}
