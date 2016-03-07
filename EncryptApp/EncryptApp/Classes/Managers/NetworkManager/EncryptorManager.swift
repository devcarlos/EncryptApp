//
//  EncryptorManager.swift
//  EncryptApp
//
//  Created by Carlos Alcala on 3/1/16.
//  Copyright (c) 2016 Carlos Alcala. All rights reserved.
//

import UIKit
import Foundation

enum DownloadFileType: String {
    case Video = "mp4"
    case Image = "jpg"
    case Document = "pdf"
}

class EncryptorManager: NSObject {
    
    let password:String = "123456789"
    
    class var sharedInstance: EncryptorManager {
        get{
            struct StaticObject {
                static var instance: EncryptorManager? = nil
                static var onceToken: dispatch_once_t = 0
            }
            
            dispatch_once(&StaticObject.onceToken) {
                StaticObject.instance = EncryptorManager()
            }
            
            return StaticObject.instance!
        }
    }
    
    //using AFHTTPRequestOperation
    func downloadWithFinalEncryption(fileURL: String, filename: String, progress: (total: CGFloat) -> Void, completion: (filePath: String) -> Void, failure: (error: NSError) -> Void){
        
        if let url = NSURL(string: fileURL) {
            
            //generate download request operation
            let requestURL: NSURLRequest = NSURLRequest(URL: url)
            let operation: AFHTTPRequestOperation = AFHTTPRequestOperation(request: requestURL)
            let paths: NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let filePath:String = paths.objectAtIndex(0).stringByAppendingPathComponent(filename)
            
            NSLog("FILEURL: \(fileURL)")
            NSLog("FILEPATH: \(filePath)")
            
            operation.outputStream = NSOutputStream(toFileAtPath: filePath, append: false)
            
            
            operation.setDownloadProgressBlock({(bytesRead, totalBytesRead, totalBytesExpectedToRead) -> Void in
                let total:CGFloat = CGFloat(totalBytesRead) / CGFloat(totalBytesExpectedToRead)
                
                
                NSLog("TOTAL BYTES READ: \(totalBytesRead)")
                NSLog("TOTAL BYTES EXP: \(totalBytesExpectedToRead)")
                NSLog("BYTES READ: \(bytesRead)")
                
                progress(total: total)
            })
            
            operation.setCompletionBlockWithSuccess(
                { (requestOperation: AFHTTPRequestOperation!, result : AnyObject!) -> Void in
                    
                    //encrypt downloaded file
                    self.encrypt(filePath,
                        completion: {(filePath: String) -> Void in
                            completion(filePath: filePath)
                        },
                        failure: {(error: NSError) -> Void in
                            failure(error: error)
                    })
                },failure: { (requestOperation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    failure(error: error)
            })
            
            operation.start()
            
        } else {
            let error = NSError(domain: "com.crowdvac.EncryptApp.errorURL", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Error: URL is not valid for download"])
            failure(error: error)
        }
    }
    
    //using AFNEtworking+Streaming class (https://github.com/deanWombourne/AFNetworking-streaming)
    func downloadWithStreamEncryption(fileURL: String, filename: String, progress: (total: CGFloat) -> Void, completion: (filePath: String) -> Void, failure: (error: NSError) -> Void){
        
        if let url = NSURLComponents(string: fileURL) {
            let manager = DWHTTPStreamSessionManager(baseURL: url.URL)
            
            let encryptor = RNCryptor.Encryptor(password: self.password)
            let cipherdata = NSMutableData()
            
            manager.GET(fileURL,
                parameters: [],
                data: {(task: NSURLSessionDataTask!, data: AnyObject!) -> Void in
                    NSLog("stream encryption")
                    cipherdata.appendData(encryptor.updateWithData(data as! NSData))
                },
                success: {(task: NSURLSessionDataTask!) -> Void in
                    cipherdata.appendData(encryptor.finalData())
                    
                    self.saveFile(cipherdata, filename: "EncryptedStream.file",
                        completion: {(filePath: String) -> Void in
                            completion(filePath: filePath)
                        },
                        failure: {(error: NSError) -> Void in
                            failure(error: error)
                    })
                    
                },
                failure: {(task: NSURLSessionDataTask!, error: NSError!) -> Void in
                    failure(error: error)
            })
        } else {
            let error = NSError(domain: "com.crowdvac.EncryptApp.errorURL", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Error: URL is not valid for download"])
            failure(error: error)
        }
    }
    
    
    func saveFile(data: NSData, filename: String, completion: (filePath: String) -> Void, failure: (error: NSError) -> Void){
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let filepath = dir.stringByAppendingPathComponent(filename);
            
            //write data to file
            do {
                try data.writeToFile(filepath, options: NSDataWritingOptions.DataWritingAtomic)
                completion(filePath: filepath)
            } catch let error as NSError {
                print(error.localizedDescription)
                failure(error: error)
            }
        }
        
    }
    
    func encrypt(path: String, completion: (filePath: String) -> Void, failure: (error: NSError) -> Void){
        
            //Execute Encryption
            do {
                let data = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                let cipherdata:NSData = RNCryptor.encryptData(data, password: self.password)

                print("CIPHER DATA: \(cipherdata)")
                
                
                //SAVE ENCRYPTED FILE
                EncryptorManager.sharedInstance.saveFile(cipherdata,
                    filename: "EncryptedFile.data",
                    completion: {(filePath: String) -> Void in
                        
                        NSLog("ENCRYPTED FILEPATH: \(filePath)")
                        print("ENCRYPTED: \(cipherdata)")
                        completion(filePath: filePath)
                        
                    },
                    failure: {(error: NSError) -> Void in
                        failure(error: error)
                    })
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
    }
    
    func decrypt(path: String, filename: String, completion: (filePath: String) -> Void, failure: (error: NSError) -> Void){
        
        //Execute Decryption
        do {
            print("ENCRYPTED PATH: \(path)")
            let cipherdata = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            print("CIPHER DATA: \(cipherdata)")
            let originalData = try RNCryptor.decryptData(cipherdata, password: self.password)
            
            //save decrypted filePath
            EncryptorManager.sharedInstance.saveFile(originalData,
                filename: filename,
                completion: {(filePath: String) -> Void in
                    NSLog("DECRYPTED FILEPATH: \(filePath)")
                    completion(filePath: filePath)
                },
                failure: {(error: NSError) -> Void in
                    failure(error: error)
            })
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
}//end
