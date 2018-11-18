//
//  ValleyDownloader.swift
//  Valley
//
//  Created by Jahid Hassan on 11/16/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import Foundation

/// Download progress closure typealias
///
/// - Parameters:
///     - received: type Int64
///     - total: type Int64
/// - Returns:
///     - Void
public typealias DownloadProgress = (_ received: Int64, _ total: Int64) -> Void

/// Download completion closure typealias
///
/// - Parameters:
///     - Data: optional anonymous Data type
///     - Error: optional anonymous Error type
/// - Returns:
///     - Void
public typealias DownloadCompletion = (Data?, Error?) -> Void

protocol SessionDataDelegate: AnyObject {
    func progress(for url: URL) -> DownloadProgress?
    func completions(for url: URL) -> [DownloadCompletion]?
    func clearDownload(for url: URL?)
    func download(for url: URL) -> Download?
}

class Download {
    let task: URLSessionDataTask
    let progress: DownloadProgress?
    var completions: [DownloadCompletion]
    var data: Data
    
    init(task: URLSessionDataTask, progress: DownloadProgress?, completion: @escaping DownloadCompletion,
         data: Data) {
        self.task = task
        self.progress = progress
        self.completions = [completion]
        self.data = data
    }
}

/// The class responsible for downloading data. Access it through the `default` singleton.
public class ValleyDownloader {
    /// The default `ValleyDownloader` singleton
    public static let `default` = ValleyDownloader()
    
    private let queueLabel = "com.valley.downloader.queue"
    
    private let queue: DispatchQueue
    private let sessionDelegate: SessionDelegate
    private let session: URLSession
    
    private var downloads: [URL: Download]
    
    /**
     Default ValleyDownloader class initializer
     
     - parameter sessionConfiguration: A URLSessionConfiguration property, initializes with default
     */
    public init(sessionConfiguration: URLSessionConfiguration = .default) {
        queue = DispatchQueue(label: queueLabel, attributes: .concurrent)
        sessionDelegate = SessionDelegate()
        session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: .main)
        downloads = [:]
    }
    
    /**
     Download an asset.
     
     - parameter url: The URL to download from
     - parameter progress: An optional download progress closure
     - parameter completion: The completion closure called once the download is done
     */
    public func download(_ url: URL, progress: DownloadProgress? = nil, completion: @escaping DownloadCompletion) {
        sessionDelegate.delegate = self
        
        queue.sync(flags: .barrier) {
            let task: URLSessionDataTask
            
            if let download = downloads[url] {
                task = download.task
                download.completions.append(completion)
            } else {
                let newTask = session.dataTask(with: url)
                let download = Download(task: newTask, progress: progress, completion: completion, data: Data())
                downloads[url] = download
                task = newTask
            }
            
            task.resume()
        }
    }
    
}

extension ValleyDownloader: SessionDataDelegate {
    func progress(for url: URL) -> DownloadProgress? {
        return downloads[url]?.progress
    }
    
    func completions(for url: URL) -> [DownloadCompletion]? {
        return downloads[url]?.completions
    }
    
    func clearDownload(for url: URL?) {
        guard let url = url else { return }
        
        queue.sync(flags: .barrier) {
            downloads[url] = nil
        }
    }
    
    func download(for url: URL) -> Download? {
        var download: Download? = nil
        
        queue.sync(flags: .barrier) {
            download = downloads[url]
        }
        
        return download
    }
}

private class SessionDelegate: NSObject, URLSessionDataDelegate {
    weak var delegate: SessionDataDelegate?
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let url = dataTask.originalRequest?.url,
            let download = delegate?.download(for: url),
            let total = dataTask.response?.expectedContentLength else { return }
        
        download.data.append(data)
        
        delegate?.progress(for: url)?(numericCast(download.data.count), total)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let requestUrl = task.originalRequest?.url,
            let download = delegate?.download(for: requestUrl) else { return }
        
        let data = error == nil ? download.data : nil
        delegate?.completions(for: requestUrl)?.forEach { completion in
            completion(data, error)
        }
        
        delegate?.clearDownload(for: requestUrl)
    }
}

