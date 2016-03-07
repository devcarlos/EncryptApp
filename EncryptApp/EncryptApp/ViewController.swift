//
//  ViewController.swift
//  EncryptApp
//
//  Created by Carlos Alcala on 2/29/16.
//  Copyright © 2016 Carlos Alcala. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    //IBOutlets
    @IBOutlet weak var URLField: UITextField!
    @IBOutlet weak var downloadProgress: UILabel!
    @IBOutlet weak var encryptProgress: UILabel!
    @IBOutlet weak var decryptProgress: UILabel!
    
    // Properties
    var fileURL: String?
    var encryptedFilePath: String?
    var decryptedFilePath: String?
    
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
    
    @IBAction func encryptFinalPressed(sender: AnyObject) {
        //Downloaded File Encryption Example
        if let url = self.URLField.text where url != "" {
            self.fileURL = url
            
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Determinate
            loadingNotification.labelText = "Downloading"
            
            EncryptorManager.sharedInstance.downloadWithFinalEncryption(self.fileURL!,
                filename: "EncryptedFinal.file",
                progress: {(total: CGFloat) -> Void in
                    NSLog("PROGRESS: \(total)")
                    loadingNotification.progress = Float(total)
                    let totalPercent = trunc(Float(total) * 100)
                    loadingNotification.detailsLabelText = "\(totalPercent)%"
                },
                completion: {(filePath: String) -> Void in
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    NSLog("ENCRYPTED FILEPATH: \(filePath)")
                    self.encryptedFilePath = filePath
                },
                failure: {(error: NSError) -> Void in
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    let message = "File cannot be downloaded and encrypted: Error: \(error.localizedDescription)."
                    NSLog("COMPLETION: \(message)")
                    let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil));
                    
                    self.presentViewController(alert, animated: false, completion: nil)
            })
        }
    }
    
    @IBAction func encryptStreamPressed(sender: AnyObject) {
        //Stream Encryption Example
        if let url = self.URLField.text where url != "" {
            self.fileURL = url
            
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.AnnularDeterminate
            loadingNotification.labelText = "Downloading"
            
            EncryptorManager.sharedInstance.downloadWithStreamEncryption(self.fileURL!,
                filename: "OriginalFileStream",
                progress: {(total: CGFloat) -> Void in
                    NSLog("PROGRESS: \(total)")
                    loadingNotification.progress = Float(total)
                    let totalPercent = trunc(Float(total) * 100)
                    loadingNotification.detailsLabelText = "\(totalPercent)%"
                },
                completion: {(filePath: String) -> Void in
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    NSLog("ENCRYPTED FILEPATH: \(filePath)")
                    self.encryptedFilePath = filePath
                },
                failure: {(error: NSError) -> Void in
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    let message = "File cannot be downloaded and encrypted: Error: \(error.localizedDescription)."
                    NSLog("COMPLETION: \(message)")
                    let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil));
                    
                    self.presentViewController(alert, animated: false, completion: nil)
            })
        }
    }
    
    @IBAction func decryptPressed(sender: AnyObject) {
        //Decryption Example
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Determinate
        loadingNotification.labelText = "Decrypting"
        
        EncryptorManager.sharedInstance.decrypt(self.encryptedFilePath!,
            filename: "DecryptedFile",
            completion: {(filePath: String) -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                NSLog("DECRYPTED FILEPATH: \(filePath)")
                self.decryptedFilePath = filePath
            },
            failure: {(error: NSError) -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                let message = "file cannot be decrypted: \(error.localizedDescription)."
                NSLog("Error: \(message)")
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil));
                
                self.presentViewController(alert, animated: false, completion: nil)
        })
        
    }
    
    // MARK: test function
    
    @IBAction func testDecryptPressed(sender: AnyObject) {
        
        //NOTE: OLNY FOR  TESTING 
        //try to open with a document interaction
        
        let decryptedURL = NSURL(fileURLWithPath:self.decryptedFilePath!)
        let doc = UIDocumentInteractionController(URL: decryptedURL)
        doc.delegate = self
        doc .presentOpenInMenuFromRect(CGRect.zero, inView: self.view, animated: true)
    }
}

