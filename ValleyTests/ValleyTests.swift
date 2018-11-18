//
//  ValleyTests.swift
//  ValleyTests
//
//  Created by Jahid Hassan on 11/16/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import XCTest
@testable import Valley

class ValleyTests: XCTestCase {

    private var mock: MockHelper!
    
    override func setUp() {
        mock = MockHelper()
        
        URLProtocolMock.requestHandler = { request in
            return (HTTPURLResponse(), self.mock.imageResponseData())
        }
    }
    
    override func tearDown() {
        Cache.default.clearMemory()
        mock = nil
    }

    func testItDownloadImageWithUrlString() {
        let configuration = URLProtocolMock.mockedURLSessionConfiguration()
        let downloader = ValleyDownloader(sessionConfiguration: configuration)
        let valley = Valley(cache: .default, downloader: downloader)
        
        let expectation = self.expectation(description: "Download image")
        
        let urlString = "https://www.google.com/MindValley.png"
        valley.image(from: urlString, progress: nil) { image, _ in
            XCTAssertNotNil(image)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testItReturnsErrorOnInvalidUrlString() {
        let configuration = URLProtocolMock.mockedURLSessionConfiguration()
        let downloader = ValleyDownloader(sessionConfiguration: configuration)
        let valley = Valley(cache: .default, downloader: downloader)
        
        let expectation1 = self.expectation(description: "Failed retrieving image")
        let expectation2 = self.expectation(description: "Invalid url error")
        
        let urlString = "https:\\www.google.com/MindValley.png"
        valley.image(from: urlString, progress: nil) { image, error in
            XCTAssertNil(image)
            expectation1.fulfill()
            
            XCTAssertNotNil(error)
            expectation2.fulfill()
        }
        
        wait(for: [expectation1, expectation2], timeout: 5)
    }
    
    func testItDownloadImageWithUrl() {
        let configuration = URLProtocolMock.mockedURLSessionConfiguration()
        let downloader = ValleyDownloader(sessionConfiguration: configuration)
        let valley = Valley(cache: .default, downloader: downloader)
        
        let expectation = self.expectation(description: "Download image")
        
        let url = URL(string: "https://www.google.com/MindValley.png")!
        valley.image(from: url, progress: nil) { image, _ in
            XCTAssertNotNil(image)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testItDownloadDataWithUrlString() {
        let configuration = URLProtocolMock.mockedURLSessionConfiguration()
        let downloader = ValleyDownloader(sessionConfiguration: configuration)
        let valley = Valley(cache: .default, downloader: downloader)
        
        let expectation = self.expectation(description: "Download data")
        
        let urlString = "https://www.google.com/MindValley.json"
        valley.fetchData(from: urlString,
                         progress: { (progress, total) in
                            
                         },
                         forceCaching: false) { data, error in
                            XCTAssertNotNil(data)
                            expectation.fulfill()
                         }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testItDownloadDataWithUrl() {
        let configuration = URLProtocolMock.mockedURLSessionConfiguration()
        let downloader = ValleyDownloader(sessionConfiguration: configuration)
        let valley = Valley(cache: .default, downloader: downloader)
        
        let expectation = self.expectation(description: "Download data")
        
        let url = URL(string: "https://www.google.com/MindValley.json")!
        valley.fetchData(from: url,
                         forceCaching: false) { data, error in
                            XCTAssertNotNil(data)
                            expectation.fulfill()
                         }
        
        wait(for: [expectation], timeout: 5)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
