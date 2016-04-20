//
//  ViewFollowVC.swift
//  FunEye
//
//  Created by Lê Thanh Tùng on 4/12/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire

class ViewFollowVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sgmChooseView: UISegmentedControl!
    
    var userId: String!
    var isFollowerTab: Bool!
    
    var friends = [Friend]()
    var userFollower = [Friend]()
    var userFollowing = [Friend]()
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        if userId != nil {
            if isFollowerTab == true {
                loadDataFollower()
            } else {
                loadDataFollowing()
                sgmChooseView.selectedSegmentIndex = 1
            }
        }
    }
    
    func loadDataFollowing() {
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
        let url = URL_GET_FOLLOWING(userId)
        print("url \(url)")
        Alamofire.request(.GET, url).responseJSON { response in
            print("res \(response)")
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                    if jsons.count == 0 {
                        self.friends = self.userFollowing
                    } else {
                        for json in jsons {
                            let friend = Friend(dictionary: json)
                            self.userFollowing.append(friend)
                            self.friends = self.userFollowing
                        }
                    }
                    self.tableView.reloadData()
                }
                self.indicator.stopAnimating()
            }
        }
    }
    
    func loadDataFollower() {
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
        let url = URL_GET_FOLLOWERS(userId)
        print("url \(url)")
        Alamofire.request(.GET, url).responseJSON { response in
            print("res \(response)")
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                    print("jsons \(jsons)")
                    if jsons.count == 0 {
                        self.friends = self.userFollower
                    } else {
                        for json in jsons {
                            let friend = Friend(dictionary: json)
                            self.userFollower.append(friend)
                            self.friends = self.userFollower
                        }
                    }
                    self.tableView.reloadData()
                }
                self.indicator.stopAnimating()
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("FollowCell") as? FollowCell {
            let friend = friends[indexPath.row]
            
            cell.btnFollowFriends.tag = indexPath.row
            cell.btnFollowFriends.addTarget(self, action: #selector(self.unfollowFriendsACTION(_:)), forControlEvents: .TouchUpInside)
            
            cell.lblUserFriendName.tag = indexPath.row
            cell.lblUserFriendName.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfileACTION(_:)))
            tap.numberOfTapsRequired = 1
            cell.lblUserFriendName.addGestureRecognizer(tap)
            
            //print("friend.arrayFollower \(friend.arrayFollower)")
            
            cell.configureCell(friend)
            return cell
        } else {
            return FollowCell()
        }
    }
    
    func unfollowFriendsACTION(sender: UIButton) {
        let tag = sender.tag
        friends[tag].followFriends()
        tableView.reloadData()
    }
    
    func viewProfileACTION(sender: UITapGestureRecognizer) {
        let tag = sender.view?.tag
        friends[tag!].viewProfileDetail(self)
    }
    @IBAction func sgmChangeValue(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            if userFollower.count == 0 {
                loadDataFollower()
            } else {
                friends = userFollower
                tableView.reloadData()
            }
        } else {
            if userFollowing.count == 0 {
                loadDataFollowing()
            } else {
                friends = userFollowing
                tableView.reloadData()
            }
        }
    }
    
}
