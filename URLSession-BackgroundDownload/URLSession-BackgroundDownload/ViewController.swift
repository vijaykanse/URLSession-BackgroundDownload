//
//  ViewController.swift
//  BackgroundURLSession
//
//  Created by Vijay Kanse on 4/11/18.
//  Copyright © 2018 vkanse. All rights reserved.
//

import UIKit
import UserNotifications


class ViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    private let downloadController = BGDownloadController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in }
        
        downloadController.onDownloadCompleted = { (location) in
            print("Download finished: \(location.absoluteString)")
            
            self.postDownloadCompletedNotification()
            self.progressLabel.text = location.absoluteString
        }
        
        downloadController.onDownloadProgress = { (progress) in
            self.progressView.progress = Float(progress)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onDownloadClicked(_ sender: UIButton) {
        downloadController.startDownload(stringUrl: "https://speed.hetzner.de/1GB.bin")
    }
    
    func postDownloadCompletedNotification()  {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Download completed !"
        notificationContent.body = "Background Task completed !!"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "TransferCompleteRequest", content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

