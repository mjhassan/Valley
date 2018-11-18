//
//  ValleyDownloaderTests.swift
//  ValleyTests
//
//  Created by Jahid Hassan on 11/17/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import XCTest
@testable import Valley

class ValleyDownloaderTests: XCTestCase {
    private var mock: MockHelper!
    
    override func setUp() {
        mock = MockHelper()
    }
    
    override func tearDown() {
        mock = nil
    }

    func testDownload() {
        URLProtocolMock.requestHandler = { request in
            return (HTTPURLResponse(), self.mock.imageResponseData())
        }
        
        let configuration = URLProtocolMock.mockedURLSessionConfiguration()
        let downloader = ValleyDownloader(sessionConfiguration: configuration)
        
        let expectation = self.expectation(description: "Download image")
        
        let url = URL(string: "https://www.google.com/MindValley.png")!
        downloader.download(url) { data, _ in
            XCTAssertNotNil(data)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }

    func testMultipleDownloads() {
        URLProtocolMock.requestHandler = { request in
            return (HTTPURLResponse(), self.mock.imageResponseData())
        }
        
        let configuration = URLProtocolMock.mockedURLSessionConfiguration()
        let downloader = ValleyDownloader(sessionConfiguration: configuration)
        
        let expectation = self.expectation(description: "Download image")
        
        let url1 = URL(string: "https://www.google.com/MindValley.png")!
        downloader.download(url1) { data, _ in
            XCTAssertNotNil(data)
        }
        
        let url2 = URL(string: "https://www.google.com/MindValley.png")!
        downloader.download(url2) { data, _ in
            XCTAssertNotNil(data)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testFailedDownload() {
        URLProtocolMock.requestHandler = { request in
            let anyError = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
            throw anyError
        }
        
        let configuration = URLProtocolMock.mockedURLSessionConfiguration()
        let downloader = ValleyDownloader(sessionConfiguration: configuration)
        
        let expectation = self.expectation(description: "Download image")
        let url = URL(string: "https://www.google.com/MindValley.png")!
        downloader.download(url) { data, _ in
            XCTAssertNil(data)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
