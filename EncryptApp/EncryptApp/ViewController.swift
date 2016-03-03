//
//  ViewController.swift
//  EncryptApp
//
//  Created by Carlos Alcala on 2/29/16.
//  Copyright © 2016 Carlos Alcala. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    //IBOutlets
    @IBOutlet weak var URLField: UITextField!
    @IBOutlet weak var downloadProgress: UILabel!
    @IBOutlet weak var encryptProgress: UILabel!
    @IBOutlet weak var decryptProgress: UILabel!
    
    // Properties
    
    var fileURL: String?
    
    // MARK: Base Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
    
    @IBAction func downloadPressed(sender: AnyObject) {
        
        if let url = self.URLField.text where url != "" {
            self.fileURL = url            
            NetworkManager.sharedInstance.downloadFileWithProgress(self.fileURL!,
                filename: "original.mp4",
                progress: {(total: CGFloat) -> Void in
                    NSLog("PROGRESS: \(total)")
                },
                completion: {(filePath: String) -> Void in
                    NSLog("COMPLETION: \(filePath)")
                },
                failure: {(error: NSError) -> Void in
                    let message = "file cannot be downloaded."
                    NSLog("COMPLETION: \(message)")
                    let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(alert, animated: false, completion: nil)
                    
//                    UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "OK").show()
                })
        }
    }
    
    @IBAction func encryptPressed(sender: AnyObject) {
        
    }
    
    @IBAction func decryptPressed(sender: AnyObject) {
        
    }
    
    @IBAction func testNormalPressed(sender: AnyObject) {
    }
    
    
    @IBAction func testDecryptPressed(sender: AnyObject) {
    }
    
}

