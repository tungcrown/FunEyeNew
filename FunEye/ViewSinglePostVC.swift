//
//  ViewSinglePostVC.swift
//  FunEye
//
//  Created by Lê Thanh Tùng on 4/10/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire

class ViewSinglePostVC: ViewController {

    var postId: String!
    var isViewNextComment: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if postId != nil {
            print("postId \(postId)")
        }
        
        if isViewNextComment == true {
            if postId != nil {
                print("isViewNextComment \(isViewNextComment)")
                //self.performSegueWithIdentifier("ViewCommentVC", sender: postId)
                if let viewCommentVC = storyboard!.instantiateViewControllerWithIdentifier("ViewCommentVC") as? ViewCommentVC {
                    viewCommentVC.post_id = postId
                    self.navigationController?.showViewController(viewCommentVC, sender: nil)
                }
            }
        } else {
            print("isViewNextComment \(isViewNextComment)")
        }
    }
    
    
    var data: String!
    var cateName: String!
    
    override func getPostFromAlamofire(url: String) {
        if postId != nil {
            let url = URL_GET_SINGLE_POST(postId)
            let nsUrl = NSURL(string: url)!
            Alamofire.request(.GET, nsUrl).responseJSON { response in
                if let res = response.result.value as? Dictionary<String, AnyObject> {
                    self.indicator.stopAnimating()
                    self.posts = [Post]()
                    let post = Post(dictionary: res)
                    DataService.instance.addPost(post)
                    self.posts.insert(post, atIndex: 0)
                    self.tableView.reloadData()
                } else {
                    print(response)
                }
            }
        } else {
            indicator.stopAnimating()
            
            let alert = UIAlertController(title: "Có lỗi mất rồi :(", message: "Bài đăng đã bị xóa hoặc không tồn tại!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
