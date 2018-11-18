//
//  UIImageView+Valley.swift
//  Valley
//
//  Created by Jahid Hassan on 11/16/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import UIKit

// MARK: - UIImageView Extension
public extension UIImageView {
    
    // MARK: - Associated Object properties
    // See: http://stackoverflow.com/questions/25907421/associating-swift-things-with-nsobject-instances
    final private var imageUrl: URL? {
        get {
            return objc_getAssociatedObject(self, &imageUrlCacheAssociationKey) as? URL
        }
        set {
            objc_setAssociatedObject(self, &imageUrlCacheAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    final private var activityIndicator: UIActivityIndicatorView? {
        get {
            return objc_getAssociatedObject(self, &indicatorAssociationKey) as? UIActivityIndicatorView
        }
        set {
            objc_setAssociatedObject(self, &indicatorAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Image Loading Methods
    /**
     Asynchronously downloads an image and loads it into the `UIImageView` using a URL `String`.
     
     - parameter urlString: The image URL in the form of a `String`.
     - parameter placeholder: `AnyObject?` representing a placeholder of either an instance of UIImage or UIActivityIndicatorView that is loaded into the view while the asynchronous download takes place. The default value is `nil`.
     - parameter completion: An optional closure that is called to indicate completion of the intended purpose of this method. It returns two values: the first is a `UIImage`, and the second is an `Error?` which will be non-nil should an error occur. The default value is `nil`.
     */
    final public func setImage(from urlString: String,
                   placeholder: AnyObject? = nil,
                   completion: ImageCompletion? = nil) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion?(nil, ValleyError.invalidURL(urlString))
            }
            
            return
        }
        
        setImage(from: url, placeholder: placeholder, completion: completion)
    }
    
    /**
     Asynchronously downloads an image and loads it into the `UIImageView` using a URL `URL`.
     
     - parameter url: The image `URL`.
     - parameter placeholder: `AnyObject?` representing a placeholder of either an instance of UIImage or UIActivityIndicatorView that is loaded into the view while the asynchronous download takes place. The default value is `nil`.
     - parameter completion: An optional closure that is called to indicate completion of the intended purpose of this method. It returns two values: the first is a `UIImage`, and the second is an `Error?` which will be non-nil should an error occur. The default value is `nil`.
     */
    final public func setImage(from url: URL,
                          placeholder: AnyObject? = nil,
                          completion: ImageCompletion? = nil)
    {
        imageUrl = url
        
        if let image = placeholder as? UIImage {
            self.image = image
        } else if let indicator = placeholder as? UIActivityIndicatorView {
            indicator.center = self.center
            indicator.startAnimating()
            self.addSubview(indicator)
            
            activityIndicator = indicator
        }
        
        Valley.shared.image(from: url) { [weak self] image, error in
            guard let self = self, self.imageUrl == url else { return }
            
            if let indecator = self.activityIndicator {
                indecator.stopAnimating()
                indecator.removeFromSuperview()
            }
            
            UIView.transition(with: self, duration: fadeAnimationDuration, options: .transitionCrossDissolve, animations: {
                self.image = image
            })
            
            completion?(image, error)
        }
    }
}

// MARK: - UIImageView Associated Object Keys
private var imageUrlCacheAssociationKey: UInt8 = 0
private var indicatorAssociationKey: UInt8 = 0
