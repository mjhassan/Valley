//
//  Valley.swift
//  Valley
//
//  Created by Jahid Hassan on 11/16/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import UIKit

/// Image retrieval closure typealias
///
/// - Parameters:
///     - UIImage: optional anonymous UIImage
///     - Error: optional anonymous Error type
/// - Returns:
///     - Void
public typealias ImageCompletion = (UIImage?, Error?) -> Void

/// Image replacement animation duration; Public constant
public let fadeAnimationDuration = 0.1 as TimeInterval

// MARK: - Valley Class
/// The class responsible for downloading and caching images and data
final public class Valley {
    /// The shared `Valley` singleton
    public static let shared = Valley()
    
    /// read-only `Cache` property
    public let cache: Cache
    
    /// read-only `downloader` property
    public let downloader: ValleyDownloader
    
    /**
        Default Valley class initializer
     
        - parameter cache: The cache to use. Uses the `default` instance if nothing is passed
        - parameter downloader: The downloader to use. Users the `default` instance if nothing is passed
     */
    public init(cache: Cache = .default, downloader: ValleyDownloader = .default) {
        self.cache = cache
        self.downloader = downloader
    }
    
    /**
        Download or retrieve an image from cache
     
        - parameter urlString: The image URL in the form of a `String`
        - parameter progress: An optional closure to track the download progress
        - parameter forceCaching: An optional boolean value to ensure caching. For image defaul value is `true`
        - parameter completion: The closure to call once the download is done
     */
    public func image(from urlString: String,
                      progress: DownloadProgress? = nil,
                      forceCaching: Bool? = true,
                      completion: @escaping ImageCompletion)
    {
        guard let url = URL(string: urlString) else {
            completion(nil, ValleyError.invalidURL(urlString))
            return
        }
        
        image(from: url, progress: progress, forceCaching: forceCaching, completion: completion)
    }
    
    /**
     Download or retrieve an image from cache
     
     - parameter url: The URL to load an image from
     - parameter progress: An optional closure to track the download progress
     - parameter forceCaching: An optional boolean value to ensure caching. For image defaul value is `true`
     - parameter completion: The closure to call once the download is done
     */
    public func image(from url: URL,
                      progress: DownloadProgress? = nil,
                      forceCaching: Bool? = true,
                      completion: @escaping ImageCompletion)
    {
        let key = url.absoluteString
        
        cache.retrieveImage(forKey: key) { [weak self] image, _ in
            guard let image = image else {
                self?.downloader.download(url, progress: progress, completion: { data, _  in
                    guard let self = self, let data = data, let image = UIImage(data: data) else {
                        completion(nil, ValleyError.imageNotFound(key))
                        return
                    }
                    
                    self.cache.store(image, forKey: url.absoluteString)
                    completion(image, nil)
                })
                return
            }
            
            completion(image, nil)
        }
    }
    
    /**
     Download or retrieve data from cache
     
     - parameter urlString: The image URL in the form of a `String`
     - parameter progress: An optional closure to track the download progress
     - parameter forceCaching: An optional boolean value to ensure caching. The defaul value is `true` for any data other than image
     - parameter completion: The closure to call once the download is done
     */
    public func fetchData(from urlString: String,
                          progress: DownloadProgress? = nil,
                          forceCaching: Bool?,
                          completion: @escaping DownloadCompletion)
    {
        guard let url = URL(string: urlString) else {
            completion(nil, ValleyError.invalidURL(urlString))
            return
        }
        
        fetchData(from: url, progress: progress, forceCaching: forceCaching, completion: completion)
    }
    
    /**
     Download or retrieve data from cache
     
     - parameter url: The URL to load an image from
     - parameter progress: An optional closure to track the download progress
     - parameter forceCaching: An optional boolean value to ensure caching. The defaul value is `true` for any data other than image
     - parameter completion: The closure to call once the download is done
     */
    public func fetchData(from url: URL,
                          progress: DownloadProgress? = nil,
                          forceCaching: Bool?,
                          completion: @escaping DownloadCompletion)
    {
        let key = url.absoluteString
        
        cache.retrieveObject(forKey: key) { [weak self] data in
            guard let data = data else {
                self?.downloader.download(url, progress: progress, completion: { data, _ in
                    guard let self = self, let data = data else {
                        completion(nil, ValleyError.imageNotFound(key))
                        return
                    }
                    
                    if forceCaching == true {
                        self.cache.store(data, forKey: key)
                    }
                    
                    completion(data, nil)
                })
                return
            }
            completion(data, nil)
        }
    }
}
