//
//  URLProtocolMock.swift
//  ValleyTests
//
//  Created by Jahid Hassan on 11/17/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import Foundation

final class URLProtocolMock: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))!
    
    static func mockedURLSessionConfiguration() -> URLSessionConfiguration {
        let configuration: URLSessionConfiguration = .ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        
        return configuration
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        do {
            let (response, data) = try URLProtocolMock.requestHandler(request)
            
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
