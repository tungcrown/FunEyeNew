//
//  NotificationsVC.swift
//  FunEye
//
//  Created by Lê Thanh Tùng on 4/9/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire

class NotificationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var notificationsTable: UITableView!
    
    var notifications = [Notification]()
    var nextCmtPage = 1
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var refreshControl: UIRefreshControl!
    
    var notificationsType = ["comment", "like", "follow", "post"]
    let threshold: CGFloat = 100.0 // threshold from bottom of tableView
    var isLoadingMore = false // flag
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationsTable.delegate = self
        notificationsTable.dataSource = self
        
        setupRefreshConrol()
        
        loadDataViaAPI(1)
        putNotificationRead()
    }
    
    override func viewDidAppear(animated: Bool) {
        for item in self.tabBarController!.tabBar.items! {
            if item.tag == 1 {
                if item.badgeValue != nil {
                    item.badgeValue = nil
                    loadDataViaAPI(1)
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell") as? NotificationCell {
            let noti = notifications[indexPath.row]
            if noti.type == notificationsType[2] {
                let tap = UITapGestureRecognizer(target: self, action: #selector(NotificationsVC.myMethodToHandleTap(_:)))
                tap.numberOfTapsRequired = 1
                cell.messageTxt.tag = indexPath.row
                cell.messageTxt.addGestureRecognizer(tap)
                //let friend = noti.userSender
                cell.configureCellFollow(noti, tag: indexPath.row)
                
            } else {
                let tap = UITapGestureRecognizer(target: self, action: #selector(NotificationsVC.myMethodToHandleTap(_:)))
                tap.numberOfTapsRequired = 1
                cell.messageTxt.tag = indexPath.row
                cell.messageTxt.addGestureRecognizer(tap)
                
                cell.imgVideoThumb.tag = indexPath.row
                let tapImg = UITapGestureRecognizer(target: self, action: #selector(NotificationsVC.showViewSingleVC(_:)))
                tapImg.numberOfTapsRequired = 1
                cell.imgVideoThumb.userInteractionEnabled = true
                cell.imgVideoThumb.addGestureRecognizer(tapImg)
                
                cell.configureCell(noti)
            }
            return cell
        } else {
            return NotificationCell()
        }
    }
    
    func putNotificationRead() {
        Alamofire.request(.PUT, URL_PUT_READ_NOTIFICATION)
    }
    
    func loadDataViaAPI(page: Int?) {
        indicator.startAnimating()
        isLoadingMore = true
        var url: String!
        if page == nil {
            url =  URL_GET_NOTIFICATION("\(nextCmtPage)")
        } else {
            notifications = []
            url =  URL_GET_NOTIFICATION("1")
        }
        print("url page \(page) \(url)")
        Alamofire.request(.GET, url).responseJSON { response in
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                    for json in jsons {
                        let noti = Notification(dictionary: json)
                        self.notifications.append(noti)
                        //self.notifications.insert(noti, atIndex:0)
                    }
                    self.notificationsTable.reloadData()
                }
                
                if let isNext = res["isNext"] as? Bool where isNext == true {
                    self.nextCmtPage += 1
                    self.refreshControl.endRefreshing()
                    self.isLoadingMore = false
                } else {
                    if page != nil {
                        self.refreshControl.endRefreshing()
                    } else {
                        self.refreshControl.removeFromSuperview()
                    }
                    //self.refreshControl.endRefreshing()
                }
                self.indicator.stopAnimating()
            }
        }
    }
    func setupRefreshConrol() {
        indicator.center = view.center
        view.addSubview(indicator)
        
        refreshControl = UIRefreshControl()
        //refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        notificationsTable.addSubview(self.refreshControl)
    }

    func refresh(sender:AnyObject)
    {
        print("load new data refresh")
        loadDataViaAPI(1)
    }
    
    func setupTapOnNotification() {
        
    }
    
    func myMethodToHandleTap(sender: UITapGestureRecognizer) {
        print("taptap")
        
        let myTextView = sender.view as! UITextView
        let layoutManager = myTextView.layoutManager
        let tag = myTextView.tag
        // location of tap in myTextView coordinates and taking the inset into account
        var location = sender.locationInView(myTextView)
        location.x -= myTextView.textContainerInset.left;
        location.y -= myTextView.textContainerInset.top;
        
        // character index at tap location
        let characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: myTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // if index is valid then do something.
        if characterIndex < myTextView.textStorage.length {
            
            // print the character index
            print("character index: \(characterIndex)")
            
            // print the character at the index
            let myRange = NSRange(location: characterIndex, length: 1)
            let substring = (myTextView.attributedText.string as NSString).substringWithRange(myRange)
            print("character at index: \(substring)")
            
            // check if the tap location has a certain attribute
            let attributeName = "notification"
            let attributeValue = myTextView.attributedText.attribute(attributeName, atIndex: characterIndex, effectiveRange: nil) as? String
            if attributeValue != nil {
                let friend = self.notifications[tag].userSender
                friend.viewProfileDetail(self)
            }
        }
    }
    
    func showViewSingleVC(sender: UITapGestureRecognizer) {
        let tag = sender.view!.tag
        let dataPass = notifications[tag].id
        print("dataPass \(dataPass)")
        self.performSegueWithIdentifier("ViewSinglePostVC", sender: dataPass)
        /*
        if let notificationsVC = storyboard!.instantiateViewControllerWithIdentifier("ViewSinglePostVC") as? ViewSinglePostVC {
            notificationsVC.postId = notifications[tag].posId
            notificationsVC.isViewNextComment = true
            self.navigationController?.showViewController(notificationsVC, sender: nil)
        }*/
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ViewSinglePostVC" {
            if let notificationsVC = segue.destinationViewController as? ViewSinglePostVC {
                if let dctUrl = sender as? String {
                    for noti in notifications {
                        if noti.id == dctUrl {
                            if (noti.posId != nil) {
                                if noti.type == "comment" {
                                    notificationsVC.postId = noti.posId
                                    notificationsVC.isViewNextComment = true
                                } else {
                                    notificationsVC.postId = noti.posId
                                    notificationsVC.isViewNextComment = false
                                }
                            }
                            break
                        }
                    }
                }
            }
        }
    }
    
    func followFriendsACTION(sender: UIButton) {
        print("tap tap follow")
        let tag = sender.tag
        let friend = notifications[tag].userSender
        friend.followFriends()
        notificationsTable.reloadData()
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if !isLoadingMore && (maximumOffset - contentOffset <= threshold) {
            loadDataViaAPI(nil)
        }
    }
    
    @IBAction func viewFollowVC(sender: AnyObject) {
        print("ta folowvc")
        
        if let followVC = storyboard?.instantiateViewControllerWithIdentifier("FollowVC") as? FollowVC {
            self.navigationController?.showViewController(followVC, sender: nil)
        }
    }
    
}
