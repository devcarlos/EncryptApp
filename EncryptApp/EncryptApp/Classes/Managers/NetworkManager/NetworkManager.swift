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
        
        operation.outputStream = NSOutputStream(toFileAtPath: filePath, append: false)
        
        operation.setDownloadProgressBlock({(bytesRead, totalBytesRead, totalBytesExpectedToRead) -> Void in
            var total:CGFloat = CGFloat(totalBytesRead) / CGFloat(totalBytesExpectedToRead)
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
    
//    func downloadFile(fileURL: String, type:DownloadFileType, saveToAlbum: Bool, completion: ((asset: PHAsset?, error: NSError?) -> Void)? = nil){
//        if (saveToAlbum) {
//            Utilities.checkPhotoAlbumPermissions({[unowned self](authorized: Bool)->Void in
//                if authorized {
//                    self.download(fileURL, type: type, saveToAlbum: saveToAlbum, completion: completion)
//                }
//                })
//        } else {
//            self.download(fileURL, type: type, saveToAlbum: saveToAlbum, completion: completion)
//        }
//    }
//    
//    func download(fileURL: String, type:DownloadFileType, saveToAlbum: Bool, completion: ((asset: PHAsset?, error: NSError?) -> Void)?) -> Void {
//        
//        //show progress HUD downloading
//        MBProgressHUDCustom.showDeterminateWithStatus("DOWNLOADING")
//        var filename = "filename." + type.rawValue
//        //download video URL to local filePath
//        Networking.sharedInstance.downloadFileWithProgress(fileURL, filename: filename,
//            progress: {(total: CGFloat) -> Void in
//                printlnDB("PROGRESS: \(total)")
//                MBProgressHUDCustom.sharedView.progress = Float(total)
//            },
//            completion: {(filePath: String) -> Void in
//                if (saveToAlbum) {
//                    printlnDB("FILEPATH: \(filePath)")
//                    
//                    //save to album by type
//                    if (type == DownloadFileType.Image) {
//                        Utilities.savePhotoAlbumImage(filePath)
//                    } else if (type == DownloadFileType.Video) {
//                        if completion != nil {
//                            Utilities.savePhotoAlbumVideo(filePath, completion:{ (asset, error) -> Void in
//                                if error != nil {
//                                    let message = "Media file cannot be saved."
//                                    UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "OK").show()
//                                    MBProgressHUDCustom.dismiss()
//                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
//                                        completion?(asset: asset, error: error)
//                                    }
//                                } else {
//                                    //show completed HUD with animation (will dissmiss automatically)
//                                    UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
//                                        MBProgressHUDCustom.showCompletedWithStatus("DOWNLOADED")
//                                        }, completion: nil)
//                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
//                                        completion?(asset: asset, error: error)
//                                    }
//                                    
//                                }
//                            })
//                            return
//                        } else {
//                            Utilities.savePhotoAlbumVideo(filePath)
//                        }
//                    }
//                }
//                
//                //show completed HUD with animation (will dissmiss automatically)
//                UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
//                    MBProgressHUDCustom.showCompletedWithStatus("DOWNLOADED")
//                    }, completion: nil)
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
//                    completion?(asset: nil, error: nil)
//                }
//                
//            },
//            failure: {(error: NSError) -> Void in
//                let message = "Media file cannot be downloaded."
//                UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "OK").show()
//                MBProgressHUDCustom.dismiss()
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
//                    completion?(asset: nil, error: error)
//                }
//        })
//    }
    
}//end