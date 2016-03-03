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
    
    var cipherPath: String?
    
    let password = "123456789Password"
    
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
            
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Determinate
            loadingNotification.labelText = "Downloading"
            
            NetworkManager.sharedInstance.downloadFileWithProgress(self.fileURL!,
                filename: "original.mp4",
                progress: {(total: CGFloat) -> Void in
                    NSLog("PROGRESS: \(total)")
                    loadingNotification.progress = Float(total)
                },
                completion: {(filePath: String) -> Void in
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    NSLog("COMPLETION: \(filePath)")
                },
                failure: {(error: NSError) -> Void in
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    let message = "file cannot be downloaded."
                    NSLog("COMPLETION: \(message)")
                    let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil));
                    
                    self.presentViewController(alert, animated: false, completion: nil)
                })
        }
    }
    
    @IBAction func encryptPressed(sender: AnyObject) {
        //Encryption Example
        self.encryptExample()
    }
    
    @IBAction func decryptPressed(sender: AnyObject) {
        //Decryption Example
        self.decryptExample()
    }
    
    @IBAction func testNormalPressed(sender: AnyObject) {
    }
    
    
    @IBAction func testDecryptPressed(sender: AnyObject) {
    }
    
    // MARK: encryption/decryption example functions
    
    func encryptExample() {
        
        // ENCRYPTION FILE
        if let path = NSBundle.mainBundle().pathForResource("example", ofType: "txt") {
            do {
                let data = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                
                let text = String(data: data, encoding: NSUTF8StringEncoding)
                let cipherdata:NSData = RNCryptor.encryptData(data, password: self.password)
                print("CIPHER DATA1: \(cipherdata)")
                
                
                //SAVE ENCRYPTED FILE
                NetworkManager.sharedInstance.saveFile(cipherdata,
                    filename: "EncryptedFile",
                    completion: {(filePath: String) -> Void in
                        NSLog("ENCRYPTED FILEPATH: \(filePath)")
                        self.cipherPath = filePath
                        
                        
                        print("TEXT: \(text!)")
                        print("ENCRYPTED: \(cipherdata)")
                        
                        // DECRYPTION
                        do {
                            print("ENCRYPTED PATH: \(self.cipherPath!)")
                            let cipherdata2 = try NSData(contentsOfFile: self.cipherPath!, options: .DataReadingMappedIfSafe)
                            print("CIPHER DATA2: \(cipherdata2)")
                            let originalData = try RNCryptor.decryptData(cipherdata2, password: self.password)
                            let originaltext = String(data: originalData, encoding: NSUTF8StringEncoding)
                            print("DECRYPTED: \(originalData)")
                            print("ORIGINAL TEXT: \(originaltext!)")
                        } catch {
                            print(error)
                        }
                        
                    },
                    failure: {(error: NSError) -> Void in
                        let message = error.localizedDescription
                        NSLog("ERROR: \(message)")
                        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil));
                        
                        self.presentViewController(alert, animated: false, completion: nil)
                })

            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func decryptExample() {
        
        // DECRYPTION
        do {
            print("ENCRYPTED PATH: \(self.cipherPath!)")
            let cipherdata2 = try NSData(contentsOfFile: self.cipherPath!, options: .DataReadingMappedIfSafe)
            print("CIPHER DATA2: \(cipherdata2)")
            let originalData = try RNCryptor.decryptData(cipherdata2, password: self.password)
            let originaltext = String(data: originalData, encoding: NSUTF8StringEncoding)
            print("DECRYPTED: \(originalData)")
            print("ORIGINAL TEXT: \(originaltext!)")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

