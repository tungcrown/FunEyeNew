//
//  DataService.swift
//  MyHood App
//
//  Created by Lê Thanh Tùng on 3/15/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import AVFoundation
import Foundation
import Alamofire

class DataService {
    static let instance = DataService()
    
    let KEY_POSTS = "posts"
    
    private var _loadingPost = [Post]()
    
    var loadingPost: [Post] {
        return _loadingPost
    }
    
    func savePosts(post: Post) {
        var checkPostExist = false
        for (index, checkPost) in _loadingPost.enumerate() {
            if checkPost.postId == post.postId {
                print("load lai post")
                checkPostExist = true
                _loadingPost[index] = post
                _loadingPost[index].videoPath = checkPost.videoPath
                
                let postsData = NSKeyedArchiver.archivedDataWithRootObject(_loadingPost)
                NSUserDefaults.standardUserDefaults().setObject(postsData, forKey: KEY_POSTS)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self.loadPosts()
            }
        }
        
        if checkPostExist == false {
            print("Moi toanh")
            
            let videoUrl = post.videoUrl
            var localPath: NSURL?
            var pathComponent: String?
            Alamofire.download(.GET, videoUrl, destination: { (temporaryURL, response) in
                let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                //let pathComponent = response.suggestedFilename
                pathComponent = "video\(NSDate.timeIntervalSinceReferenceDate()).mp4"
                
                localPath = directoryURL.URLByAppendingPathComponent(pathComponent!)
                
                return localPath!
            }).response { (request, response, data, error) in
                
                if localPath != nil {
                    
                    print("Downloaded file to \(localPath!)")
                    post.videoPath = pathComponent!
                    /*if self._loadingPost.count > 3 {
                        self._loadingPost.removeLast()
                    }*/
                    //self._loadingPost.insert(post, atIndex:0)
                    self._loadingPost.append(post)
                    
                    
                    let postsData = NSKeyedArchiver.archivedDataWithRootObject(self._loadingPost)
                    NSUserDefaults.standardUserDefaults().setObject(postsData, forKey: self.KEY_POSTS)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    self.loadPosts()
                }
                
                if error != nil {
                    print("error download: \(error.debugDescription)")
                }
                
            }
        }
    }
    
    func loadPosts() {
        if let postsData = NSUserDefaults.standardUserDefaults().objectForKey(KEY_POSTS) as? NSData {
            if let postsArray = NSKeyedUnarchiver.unarchiveObjectWithData(postsData) as? [Post] {
                _loadingPost = postsArray
            } else {
                _loadingPost = [Post]()
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "PostsLoaded", object: nil))
    }
    
    func addPost(post: Post) {
        savePosts(post)
        loadPosts()
    }
    
    func VideoForPath(path: String) -> AVPlayer? {
        let fullPath = documentPathForFilename(path)
        let nsUrl = NSURL(string: fullPath)
        
        return AVPlayer(URL: nsUrl!)
    }
 
    
    func documentPathForFilename(name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let fullPath = paths[0] as NSString
        
        return "file://" + fullPath.stringByAppendingPathComponent(name)
    }
    
    func downloadAndSetImageFromUrl(url: String, imgView: UIImageView, imageCache: NSCache) {
        let img = imageCache.objectForKey(url) as? UIImage
        if img != nil {
            imgView.image = img
        } else {
            Alamofire.request(.GET, url).validate(contentType: ["image/*"]).response(completionHandler: { (request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) -> Void in
            
                if error == nil {
                    let img = UIImage(data: data!)!
                    imgView.image = img
                    //save cache
                    imageCache.setObject(img, forKey: url)
                }
            })
        }
    }
}