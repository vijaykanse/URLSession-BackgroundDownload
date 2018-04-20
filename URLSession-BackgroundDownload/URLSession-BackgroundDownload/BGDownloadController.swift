//
//  BGDownloadController.swift
//  BackgroundURLSession
//
//  Created by Vijay Kanse on 4/11/18.
//  Copyright © 2018 vkanse. All rights reserved.
//

import UIKit
enum Constants: String {
    case backgroundSessionId = "com.vkanse.BackGroudDownloadDemo.backgroundSession"
}
class BGDownloadController: NSObject {
    
    var onDownloadCompleted : ((URL) -> ())?
    var onDownloadProgress : ((Double) -> ())?
    func startDownload(stringUrl: String) {
        if let url = URL(string: stringUrl){
            let config = URLSessionConfiguration.background(withIdentifier: Constants.backgroundSessionId.rawValue)
            config.sessionSendsLaunchEvents = true
            let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
            let task = session.downloadTask(with: url)
            task.countOfBytesClientExpectsToSend = 512
            task.countOfBytesClientExpectsToReceive = 1 * 1024 * 1024 * 1024 // size of file (1 gb)
            task.resume()
        }
    }
}

extension BGDownloadController: URLSessionDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                    appDelegate.backgroundSessionCompletionHandler = nil
                    completionHandler()
                }
            }
        }
    }
}

extension BGDownloadController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("didFinishDownloading: \(location.absoluteString)")
        DispatchQueue.main.async {
            self.onDownloadCompleted?(location)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("bytesWritten",bytesWritten)
        if  totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown {
            let progress = Double(Double(totalBytesWritten)/Double(totalBytesExpectedToWrite))
            DispatchQueue.main.async {
                self.onDownloadProgress?(progress)
            }
        }
    }
}
