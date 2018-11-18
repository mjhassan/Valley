//
//  ValleyCache.swift
//  Valley
//
//  Created by Jahid Hassan on 11/16/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import UIKit

///A closure typealias with an optional `Data` type, which return `Void`
public typealias CacheCompletion = (Data?) -> Void

// MARK: - Cache Class
/// The class responsible for caching images. Images will be cached in memory only.
public final class Cache {
    // MARK: - properties
    
    /// The default `Cache` singleton
    public static let `default` = Cache(name: "default")
    
    // This is not a strict limit, and if the cache goes over the limit, an object in the cache could be evicted instantly, at a later point in time, or possibly never, all depending on the implementation details of the cache.
    /// The maximum total cost that the cache can hold before it starts evicting objects.
    /// If 0, there is no total cost limit. The default value is 0.
    public var totalCostLimit: Int = 0 {
        didSet {
            memory.totalCostLimit = totalCostLimit
        }
    }
    
    // This is not a strict limit—if the cache goes over the limit, an object in the cache could be evicted instantly, later, or possibly never, depending on the implementation details of the cache.
    /// The maximum number of objects the cache should hold.
    /// If 0, there is no count limit. The default value is 0.
    public var countLimit: Int = 0 {
        didSet {
            memory.countLimit = countLimit
        }
    }
    
    /// This is a default prefix, which is used to make cache key
    private static let prefix = "com.valley.cache."
    
    /// A mutable collection you use to temporarily store transient key-value pairs in memory that are subject to eviction when resources are low.
    private let memory = NSCache<NSString, AnyObject>()
    
    /**
        Construct a new instance of the cache
        - Parameter name: The name of the cache. Used to construct a unique path on disk to store images in
     */
    public init(name: String) {
        let cacheName = Cache.prefix + name
        memory.name = cacheName
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clearMemory),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
    }
    
    /**
        Stores an image in the cache as data. Images will be added to the memory.
        - parameter image: The image to cache
        - parameter key: The unique identifier of the image
     */
    public func store(_ image: UIImage, forKey key: String) {
        let cacheKey = makeCacheKey(key)
        memory.setObject(image, forKey: cacheKey as NSString)
    }
    
    /**
     Stores a data in the cache. Data will be added to the memory.
     - parameter data: The data to cache
     - parameter key: The unique identifier of the image
     */
    public func store(_ data: Data?, forKey key: String) {
        let cacheKey = makeCacheKey(key)
        memory.setObject(data as AnyObject, forKey: cacheKey as NSString)
    }
    
    /**
     Create a key by replacing unsupported characters in a string
     - parameter key: The unique identifier string
     - Returns : A string replacing unsupported characters
     */
    private func makeCacheKey(_ key: String) -> String {
        return key.replacingOccurrences(of: "/", with: "-")
    }
    
    /**
     Retrieve an image from memory cache.
     
     - parameter key: The unique identifier of the object
     - parameter completion: The `ImageCompletion` called once the object has been retrieved from the cache.
     
     `public typealias ImageCompletion = (UIImage?, Error?) -> Void`
     */
    public func retrieveImage(forKey key: String, completion: ImageCompletion) {
        let cacheKey = makeCacheKey(key)
        
        guard let image = memory.object(forKey: cacheKey as NSString) as? UIImage else {
            completion(nil, ValleyError.imageNotFound(key))
            return
        }
        
        completion(image, nil)
    }
    
    /**
        Retrieve an object from memory cache and send as Data.
     
        - parameter key: The unique identifier of the object
        - parameter completion: The `CacheCompletion` called once the object has been retrieved from the cache.
     
            `public typealias CacheCompletion = (Data?) -> Void`
     */
    public func retrieveObject(forKey key: String, completion: CacheCompletion) {
        let cacheKey = makeCacheKey(key)
        
        guard let data = memory.object(forKey: cacheKey as NSString) else {
            completion(nil)
            return
        }
        
        completion(data as? Data)
    }
    
    /// Clear the memory cache.
    @objc
    public func clearMemory() {
        memory.removeAllObjects()
    }
}
