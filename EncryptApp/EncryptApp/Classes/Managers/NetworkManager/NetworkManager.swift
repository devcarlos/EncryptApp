//
//  NetworkManager.swift
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

class NetworkManager: NSObject {
    
    class var sharedInstance: NetworkManager {
        get{
            struct StaticObject {
                static var instance: NetworkManager? = nil
                static var onceToken: dispatch_once_t = 0
            }
            
            dispatch_once(&StaticObject.onceToken) {
                StaticObject.instance = NetworkManager()
            }
            
            return StaticObject.instance!
        }
    }
    
    func downloadFileWithProgress(fileURL: String, filename: String, progress: (total: CGFloat) -> Void, completion: (filePath: String) -> Void, failure: (error: NSError) -> Void){
        
        //generate download request operation
        let requestURL: NSURLRequest = NSURLRequest(URL: NSURL(string: fileURL)!)
        let operation: AFHTTPRequestOperation = AFHTTPRequestOperation(request: requestURL)
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let filePath:String = paths.objectAtIndex(0).stringByAppendingPathComponent(filename)
        
        NSLog("FILEURL: \(fileURL)")
        NSLog("FILEPATH: \(filePath)")
        
        operation.outputStream = NSOutputStream(toFileAtPath: filePath, append: false)
        
        operation.setDownloadProgressBlock({(bytesRead, totalBytesRead, totalBytesExpectedToRead) -> Void in
            let total:CGFloat = CGFloat(totalBytesRead) / CGFloat(totalBytesExpectedToRead)

//            NSLog("TOTAL BYTES READ: \(totalBytesRead)")
//            NSLog("TOTAL BYTES EXP: \(totalBytesExpectedToRead)")
//            NSLog("BYTES READ: \(bytesRead)")
            
            progress(total: total)
        })
        
        operation.setCompletionBlockWithSuccess(
            { (requestOperation: AFHTTPRequestOperation!, result : AnyObject!) -> Void in
                completion(filePath: filePath)
            },failure: { (requestOperation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                failure(error: error)
        })
        
        operation.start()
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
    
}//end