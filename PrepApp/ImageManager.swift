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
    
    var sizeToDownload: Int = 0
    var sizeDownloaded: Int = 0
    var hasFinishedSync: Bool = false
    let realm = FactoryRealm.getRealmImages()
       
	
    func sync(){
		
		self.getUploads({ (data) -> Void in
			var onlineUploads = [Image]()
			// dictionary
			for (id, size) in data! {
				let upload = Image()
				upload.id = (id as! String).toInt()!
				upload.size = (size as! String).toInt()!
				onlineUploads.append(upload)
			}
			self.compare(onlineUploads)
		})
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
        self.computeSize(objectsToAdd)
        self.fetchImages(objectsToAdd)

	}
	
    private func computeSize(objectsToAdd: [Image]) {
        for objectToAdd in objectsToAdd {
            self.sizeToDownload += objectToAdd.size
        }
        //println("Size of images to download = \(self.sizeToDownload/1000) KB")
        
        if self.sizeToDownload == 0 {
            self.hasFinishedSync = true
            println("Nothing new to upload (images)")
        }
    }
    
	private func deleteImages(idsToRemove: [Int]){
        for idToRemove in idsToRemove {
            var objectToRemove = realm.objects(Image).filter("id=\(idToRemove)")
            self.realm.write {
                self.realm.delete(objectToRemove)
            }
            self.removeFile("/\(idToRemove).png")
        }
		
	}

	private  func fetchImages(objectsToAdd: [Image]){
        
        for objectToAdd in objectsToAdd {
            if Factory.errorNetwork == false {
                let url = NSURL(string: "\(Factory.uploadsUrl!)/\(objectToAdd.id).png")
                self.saveFile(url!, imageName: "/\(objectToAdd.id).png", objectToAdd: objectToAdd)
            }
        }
	}

	private func removeFile(imageName: String){
		let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
		let imagesPath = path + "/images"
		let imagePath = imagesPath + imageName
		println(imagePath)
		NSFileManager.defaultManager().removeItemAtPath(imagePath, error: nil)
		
	}
    
    private func saveFile(url: NSURL, imageName: String, objectToAdd: Image){
        
        let timeout: NSTimeInterval = 30
        let urlRequest = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy,timeoutInterval: timeout)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if error != nil {
                if Factory.errorNetwork == false {
                    Factory.errorNetwork = true
                    println(error)
                }
                
            } else {
                self.sizeDownloaded += data.length
                //println("size downloaded = \(self.sizeDownloaded/1000) KB")

                let imagesPath = Factory.path + "/images"
                NSFileManager.defaultManager().createDirectoryAtPath(imagesPath, withIntermediateDirectories: false, attributes: nil, error: nil)
                let imagePath = imagesPath + imageName
                if let fetchedImage = UIImage(data: data) {
                    NSFileManager.defaultManager().createFileAtPath(imagePath, contents: data, attributes: nil)
                    //image saved in directory, we updrade Realm DB
                    self.realm.write {
                        self.realm.add(objectToAdd)
                    }
                }
            }
            
            if self.sizeToDownload == self.sizeDownloaded {
                self.hasFinishedSync = true
                println("images downloaded")
            }
        }
    }
	
	private func getUploads(callback: (NSDictionary?) -> Void) {
		let request = NSMutableURLRequest(URL: Factory.imageUrl!)
		request.HTTPMethod = "POST"
		let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
			(data, response, error) in
			
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    println("error : no connexion in getUploads")
                    Factory.errorNetwork = true
                } else {
                    
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
                        
                        if let result = jsonResult {
                            if err != nil {
                                println("error : parsing JSON in getUploads")
                                Factory.errorNetwork = true
                            } else {
                                callback(result as NSDictionary)
                            }
                        } else {
                            println("error : NSArray nil in getUploads")
                            Factory.errorNetwork = true
                        }
                        
                        
                    } else {
                        println("error : != 200 in getUploads")
                        Factory.errorNetwork = true
                    }
                }
            }

		}
		task.resume()
        
        
		
		
	}
    
    



	
}
