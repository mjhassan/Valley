//
//  CacheTests.swift
//  ValleyTests
//
//  Created by Jahid Hassan on 11/17/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import XCTest
@testable import Valley

class CacheTests: XCTestCase {

    private var mock: MockHelper!
    
    override func setUp() {
        mock = MockHelper()
    }

    override func tearDown() {
        Cache.default.clearMemory()
        mock = nil
    }

    func testItCachesInMemory() {
        let cache = Cache.default
        let image = mock.image
        let cacheKey = "http://\(#function)"
        
        let expectation1 = self.expectation(description: "Retrieved image from cache")
        let expectation2 = self.expectation(description: "Retrieved image and actual images are same")
        
        cache.store(image, forKey: cacheKey)
        cache.retrieveImage(forKey: cacheKey) { img, _ in
            XCTAssertNotNil(img)
            expectation1.fulfill()
            
            XCTAssertEqual(image.size, img!.size)
            expectation2.fulfill()
        }
        
        wait(for: [expectation1, expectation2], timeout: 10.0)
    }
    
    func testItReturnsNoImageForDataCaching() {
        let cache = Cache.default
        let image = mock.image
        let cacheKey = "http://\(#function)"
        
        let expectation1 = self.expectation(description: "Image and image data are not inter-changable")
        let expectation2 = self.expectation(description: "Retrieved image from cache")
        
        cache.store(image, forKey: cacheKey)
        
        cache.retrieveObject(forKey: cacheKey, completion: { data in
            XCTAssertNil(data)
            expectation1.fulfill()
        })
        
        cache.retrieveImage(forKey: cacheKey, completion: { image, _ in
            XCTAssertNotNil(image)
            expectation2.fulfill()
        })
        
        wait(for: [expectation1, expectation2], timeout: 10.0)
    }
    
    func testItRetrieveNoDataForImageCaching() {
        let cache = Cache.default
        let data = mock.imageResponseData()
        let cacheKey = "http://\(#function)"
        
        let expectation1 = self.expectation(description: "Retrieved data from cache")
        let expectation2 = self.expectation(description: "No image in cache")
        
        cache.store(data, forKey: cacheKey)
        
        cache.retrieveObject(forKey: cacheKey, completion: { data in
            XCTAssertNotNil(data)
            expectation1.fulfill()
        })
        
        cache.retrieveImage(forKey: cacheKey, completion: { image, _ in
            XCTAssertNil(image)
            expectation2.fulfill()
        })
        
        wait(for: [expectation1, expectation2], timeout: 10.0)
    }

    func testItDistinctCacheByName() {
        let defaultCache = Cache.default
        let namedCache = Cache(name: "named")
        let image = mock.image
        let key = #function
        
        let expectation1 = self.expectation(description: "No image in cache to retrieve")
        let expectation2 = self.expectation(description: "Retrieved image from cache")
        
        defaultCache.store(image, forKey: key)
        namedCache.retrieveImage(forKey: key, completion: { image, _ in
            XCTAssertNil(image)
            expectation1.fulfill()
        })
        
        defaultCache.retrieveImage(forKey: key, completion: { image, _ in
            XCTAssertNotNil(image)
            expectation2.fulfill()
        })
        
        wait(for: [expectation1, expectation2], timeout: 10)
    }
    
    func testItReturnsNoImageForUnknownKey() {
        let cache = Cache.default
        let image = mock.image
        
        let expectation = self.expectation(description: "Retrieve no image from cache")
        
        cache.store(image, forKey: "key1")
        cache.retrieveImage(forKey: "key2") { image, _ in
            XCTAssertNil(image)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testItClearsCache() {
        let cache = Cache.default
        let image = mock.imageResponseData()
        let cacheKey = "http://\(#function)"
        
        let expectation = self.expectation(description: "Clear disk cache")
        
        cache.store(image, forKey: cacheKey)
        cache.clearMemory()
        cache.retrieveObject(forKey: cacheKey, completion: { data in
            XCTAssertNil(data)
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
