//
//  ImageManager.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 27/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//


import UIKit
import RealmSwift


class ImageManager {
    
    var numberOfImagesToDownload: Int = 0
    var numberOfImagesDownloaded: Int = 0
    var hasFinishedSync: Bool = false
    let realm = FactoryRealm.getRealmImages()
	
    func sync(){
        self.hasFinishedSync = false
        self.numberOfImagesToDownload = 0
        self.numberOfImagesDownloaded = 0
		self.getUploads({ (data) -> Void in
			var onlineUploads = [Image]()
			// dictionary
			for (id, size) in data {
				let upload = Image()
				upload.id = Int((id as! String))!
				upload.size = (size as! Int)
				onlineUploads.append(upload)
			}
			self.compare(onlineUploads)
		})
	}
    
    private func getUploads(callback: (NSDictionary) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.imageUrl!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = NSTimeInterval(5)
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print("error : no connexion in getUploads")
                    FactorySync.errorNetwork = true
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        
                        if let result = jsonResult {
                            callback(result as NSDictionary)
                        } else {
                            print("error : NSArray nil in getUploads")
                            FactorySync.errorNetwork = true
                        }
                    } else {
                        print("header status = \(statusCode)  in getUploads")
                        FactorySync.errorNetwork = true
                    }
                }
            }
            
        }
        task.resume()
    }
	
	private func compare(onlineUploads: [Image]){
        
		// Query a Realm
		let offlineUploads = self.realm.objects(Image)
		
		
		// we check what has been removed
        var idsToRemove = [Int]()
		for offlineUpload in offlineUploads {
			var willBeRemoved = true
			for onlineUpload in onlineUploads {
				if onlineUpload.id == offlineUpload.id {
					willBeRemoved = false
				}
			}
			if willBeRemoved {
                idsToRemove.append(offlineUpload.id)
			}
		}
        self.deleteImages(idsToRemove)
		
		
		// we check what we have to add
        var objectsToAdd = [Image]()
		for onlineUpload in onlineUploads {
			var willBeAdded = true
			for offlineUpload in offlineUploads {
				if onlineUpload.id == offlineUpload.id {
					willBeAdded = false
				}
			}
			if willBeAdded {
                objectsToAdd.append(onlineUpload)
			}
		}
        self.numberOfImagesToDownload = objectsToAdd.count
        if self.numberOfImagesToDownload == 0 {
            self.hasFinishedSync = true
            print("Nothing new to download (images)")
        }
        self.fetchImages(objectsToAdd)

	}
    
    private  func fetchImages(objectsToAdd: [Image]){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            for objectToAdd in objectsToAdd {
                if FactorySync.errorNetwork == false {
                    let url = NSURL(string: "\(FactorySync.uploadsUrl!)/\(objectToAdd.id).png")
                    self.saveFile(url!, imageName: "/\(objectToAdd.id).png", objectToAdd: objectToAdd)
                }
            }
        }
        
    }
    
    private func saveFile(url: NSURL, imageName: String, objectToAdd: Image){
        
        let request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = NSTimeInterval(120)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    if FactorySync.errorNetwork == false {
                        FactorySync.errorNetwork = true
                        print(error)
                    }
                    
                } else {
                    if !FactorySync.errorNetwork {
                        
                        let imagesPath = FactorySync.path + "/images"
                        do {
                            try NSFileManager.defaultManager().createDirectoryAtPath(imagesPath, withIntermediateDirectories: false, attributes: nil)
                        } catch _ {
                        }
                        let imagePath = imagesPath + imageName
                        if let _ = UIImage(data: data!) {
                            
                            NSFileManager.defaultManager().createFileAtPath(imagePath, contents: data, attributes: nil)
                            self.numberOfImagesDownloaded++
                            //image saved in directory, we updrade Realm DB
                            try! self.realm.write {
                                self.realm.add(objectToAdd)
                            }
                        }
                    } else {
                        print("FactorySync stopped sync due to error in ImageManager")
                    }
                }
                
                if self.numberOfImagesDownloaded == self.numberOfImagesToDownload && self.numberOfImagesToDownload != 0 {
                    self.hasFinishedSync = true
                    print("images downloaded")
                }
            }
            
        }
        task.resume()
    }

	private func deleteImages(idsToRemove: [Int]){
        for idToRemove in idsToRemove {
            let objectToRemove = realm.objects(Image).filter("id=\(idToRemove)")
            try! self.realm.write {
                self.realm.delete(objectToRemove)
            }
            self.removeFile("/\(idToRemove).png")
        }
		
	}
	
	private func removeFile(imageName: String){
		let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
		let imagesPath = path + "/images"
		let imagePath = imagesPath + imageName
		print("image removed = \(imagePath)")
		do {
            try NSFileManager.defaultManager().removeItemAtPath(imagePath)
        } catch _ {
        }
		
	}
    
}
