//
//  UIButton+Valley.swift
//  Valley
//
//  Created by Jahid Hassan on 11/16/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import UIKit

// MARK: - UIButton Extension
extension UIButton {
    // MARK: - Associated Objects
    // See: http://stackoverflow.com/questions/25907421/associating-swift-things-with-nsobject-instances
    final private var imageUrl: URL? {
        get {
            return objc_getAssociatedObject(self, &imageUrlCacheAssociationKey) as? URL
        }
        set {
            objc_setAssociatedObject(self, &imageUrlCacheAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    final private var isBackgroundImage: Bool! {
        get {
            return objc_getAssociatedObject(self, &isBackgroundImageAssociationKey) as? Bool
        }
        set {
            objc_setAssociatedObject(self, &isBackgroundImageAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Image Loading Methods
    /**
     Asynchronously downloads an image and loads it into the `UIButton` using a URL `String`.
     
     - parameter urlString: The image URL in the form of a `String`.
     - parameter state: `UIControl.state` to be used when loading the image. The default value is `normal`.
     - parameter placeholder: `UIImage?` representing a placeholder image that is loaded into the view while the asynchronous download takes place. The default value is `nil`.
     - parameter isBackgroundImage: `Bool` indicating whether or not the image is intended for the button's background. The default value is `false`.
     - parameter completion: An optional closure that is called to indicate completion of the intended purpose of this method. It returns two values: the first is a `UIImage`, and the second is an `Error?` which will be non-nil should an error occur. The default value is `nil`.
     */
    final public func setImage(from urlString: String,
                         for state: UIControl.State = .normal,
                         placeholder: UIImage? = nil,
                         isBackgroundImage: Bool = false,
                         completion: ImageCompletion? = nil) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion?(nil, ValleyError.invalidURL(urlString))
            }
            
            return
        }
        
        setImage(from: url, for: state, placeholder: placeholder, isBackgroundImage: isBackgroundImage, completion: completion)
    }
    
    /**
     Asynchronously downloads an image and loads it into the `UIButton` using a URL `String`.
     
     - parameter url: The image `URL`.
     - parameter state: `UIControl.state` to be used when loading the image. The default value is `normal`.
     - parameter placeholder: `UIImage?` representing a placeholder image that is loaded into the view while the asynchronous download takes place. The default value is `nil`.
     - parameter isBackgroundImage: `Bool` indicating whether or not the image is intended for the button's background. The default value is `false`.
     - parameter completion: An optional closure that is called to indicate completion of the intended purpose of this method. It returns two values: the first is a `UIImage`, and the second is an `Error?` which will be non-nil should an error occur. The default value is `nil`.
     */
    final public func setImage(from url: URL,
                                for state: UIControl.State,
                                placeholder: UIImage? = nil,
                                isBackgroundImage: Bool = false,
                                completion: ImageCompletion? = nil)
    {
        self.imageUrl = url
        self.isBackgroundImage = isBackgroundImage
        
        if isBackgroundImage == true {
            self.setBackgroundImage(placeholder, for: state)
        }
        else {
            self.setImage(placeholder, for: state)
        }
        
        setImage(placeholder, for: state)
        
        Valley.shared.image(from: url) { [weak self] image, error in
            guard let self = self, self.imageUrl == url else { return }
            
            UIView.transition(with: self, duration: fadeAnimationDuration, options: .transitionCrossDissolve, animations: {
                
                if self.isBackgroundImage == true {
                    self.setBackgroundImage(image, for: state)
                }
                else {
                    self.setImage(image, for: state)
                }
                
            })
            
            completion?(image, error)
        }
    }
}

// MARK: - UIButton Associated Object Keys
private var imageUrlCacheAssociationKey: UInt8 = 0
private var isBackgroundImageAssociationKey: UInt8 = 0
