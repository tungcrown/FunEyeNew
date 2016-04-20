//
//  FirstFollowVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/30/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire

class FirstFollowVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var uitableViewFollow: UITableView!
    @IBOutlet weak var uitableViewTopic: UITableView!
    
    @IBOutlet weak var lblTitleFollow: UILabel!
    
    @IBOutlet weak var lblCountSelectTopic: UILabel!
    @IBOutlet weak var btnNextOutlet: UIButton!
    
    var friends = [Friend]()
    var topics = [Dictionary<String, AnyObject?>]()
    
    var user_id: String!
    var isNextSlide = true
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uitableViewFollow.delegate = self
        uitableViewFollow.dataSource = self
        
        uitableViewTopic.delegate = self
        uitableViewTopic.dataSource = self
        
        if user_id != nil {
            print("user_id \(user_id)")
        }
        
        print("ACCESS_TOKEN \(ACCESS_TOKEN)")
        Alamofire.request(.GET, URL_GET_FRIEND_FOLLOW).responseJSON { response in
            if response.result.error != nil {
                print("error load follow \(response.result.error)")
            } else {
                if let res = response.result.value as? Dictionary<String, AnyObject> {
                    if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                        for json in jsons {
                            let friend = Friend(dictionary: json)
                            self.friends.append(friend)
                        }
                        self.uitableViewFollow.reloadData()
                    }
                } else {
                    print("Load Friend Follow Nil")
                }
            }
        }
        
        Alamofire.request(.GET, URL_GET_CATEGORIES).responseJSON { response in
            if response.result.error != nil {
                print("error load follow \(response.result.error)")
            } else {
                if let res = response.result.value as? Dictionary<String, AnyObject> {
                    if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                        for json in jsons {
                            if let id = json["_id"] as? Int {
                                let topic = ["_id": id, "image" : "https://graph.facebook.com/246809342331820/picture", "name": json["name"], "backgroundColor": json["color"]]
                                self.topics.append(topic)
                            }
                        }
                        self.uitableViewFollow.reloadData()
                    }
                } else {
                    print("Load topic follow \(response)")
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.uitableViewFollow {
            return friends.count
        }
        return topics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("FirstFollowCell") as? FirstFollowCell {
            let friend = friends[indexPath.row]
            cell.btnFollowFriends.tag = indexPath.row
            cell.btnFollowFriends.addTarget(self, action: #selector(FirstFollowVC.followFriendsACTION(_:)), forControlEvents: .TouchUpInside)
            cell.configureCell(friend)
            return cell
        }else if let cell = tableView.dequeueReusableCellWithIdentifier("FirstTopicFollowCell") as? FirstTopicFollowCell {
            let topic = topics[indexPath.row]
            cell.imgIconCheck.tag = indexPath.row + 1
            cell.configureCell(topic)
            
            return cell
            
        } else {
            return FirstFollowCell()
        }
    }
    /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.uitableViewTopic {
            let height: CGFloat = self.view.layer.frame.height / CGFloat(topics.count)
            return height
        }
        return nil
    }
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == self.uitableViewTopic {
            if let theImage = self.view.viewWithTag(indexPath.row + 1) as? UIImageView {
                theImage.hidden = false
            }
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.contentView.backgroundColor = UIColor(red: 100/255, green: 53/255, blue: 201/255, alpha: 0.15)
            isSelectTopic(indexPath.row, isFollow: true)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.uitableViewTopic {
            if let theLabel = self.view.viewWithTag(indexPath.row + 1) as? UIImageView {
                theLabel.hidden = true
            }
            isSelectTopic(indexPath.row, isFollow: false)
        }
    }
    
    /*
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.contentView.backgroundColor = UIColor.orangeColor()
        cell?.backgroundColor = UIColor.orangeColor()
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.contentView.backgroundColor = UIColor.blackColor()
        cell?.backgroundColor = UIColor.blackColor()
    }
    */
    
    func isSelectTopic(indexPath: Int, isFollow: Bool) {
        if uitableViewTopic.indexPathsForSelectedRows != nil  {
            let arraySelectTopic = uitableViewTopic.indexPathsForSelectedRows!
            if arraySelectTopic.count >= 3 {
                btnNextOutlet.hidden = false
            } else {
                btnNextOutlet.hidden = true
            }
            lblCountSelectTopic.text = "Bạn đã theo dõi \(arraySelectTopic.count)/3 chủ đề"
        } else {
            lblCountSelectTopic.text = "Vui lòng theo dõi ít nhất 3 chủ đề"
        }
        
        let topicId = topics[indexPath]["_id"] as! Int
        Alamofire.request(.PUT, URL_PUT_FOLLOW_TOPIC("\(topicId)", isFollow: isFollow))
    }
    
    func followFriendsACTION(sender: UIButton) {
        let btnTag = sender.tag
        let friendId = friends[btnTag].id
        print("friends id \(friendId)")
        sender.setTitle("...", forState: .Normal)
        let indexPath = NSIndexPath(forRow: btnTag, inSection: 0) //NSIndexPath(index: btnTag)
        
        if let cell = uitableViewFollow.cellForRowAtIndexPath(indexPath) {
            UIView.animateWithDuration(0.5, animations: {
                cell.alpha = 0.0
            }) { (true) in
                
                Alamofire.request(.PUT, URL_PUT_FOLLOW_FRIEND(friendId, isFollow: true))
                self.friends.removeAtIndex(btnTag)
                self.uitableViewFollow.reloadData()
            }
        } else {
            print("error")
        }
    }
    
    @IBAction func btnNext() {
        if isNextSlide {
            lblTitleFollow.text = "Khám phá FunEye"
            self.uitableViewTopic.center.x = self.view.frame.width * 2
            UIView.animateWithDuration(0.5) {
                self.isNextSlide = false
                self.uitableViewFollow.center.x = -self.view.frame.width
                self.uitableViewTopic.center.x = self.view.center.x
                self.uitableViewTopic.hidden = false
                
                self.uitableViewTopic.reloadData()
                self.lblCountSelectTopic.text = "Vui lòng theo dõi ít nhất 3 chủ đề"
            }
        } else {
            self.performSegueWithIdentifier("FollowVCToNewfeedsVC", sender: nil)
        }
    }
}
