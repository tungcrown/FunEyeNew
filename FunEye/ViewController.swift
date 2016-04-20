//
//  ViewController.swift
//  funeye
//
//  Created by Lê Thanh Tùng on 3/21/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import SocketIOClientSwift

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var posts = [Post]()
    var videoPlayNow: Int = -1
    
    static var imageCache = NSCache()
    static var imageCacheVideo = NSCache()
    
    private var Observer: NSObjectProtocol!
    
    let socket = SocketIOClient(socketURL: NSURL(string: "http://funeye.net:8080")!, options: [.Log(false), .ForcePolling(true)])
    
    let playerController = AVPlayerViewController()
    var uiviewVideo =  UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 550
        tableView.rowHeight = setHeightCell()
        
        getDataAccess()
    
        getPostFromAlamofire(URL_GET_NEW_FEED)
        setupSocketIO()
        setupRefreshControl()
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setHeightCell() -> CGFloat {
        let height: CGFloat = 45 + self.view.frame.size.width + 65 + 30 + 45
        print("height \(height)")
        return height
    }
    
    func setupRefreshControl() {
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Load new post")
        refreshControl.addTarget(self, action: #selector(ViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(self.refreshControl)
    }
    
    func refresh(sender:AnyObject)
    {
        print("load new data refresh")
        self.refreshControl.endRefreshing()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        videoPlayNow = -1
        update()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        pauseAllVideo()
    }
    
    func getPostFromAlamofire(url: String) {
        
        let img = UIImage(named: "logo")
        self.navigationItem.titleView = UIImageView(image: img)
        
        DataService.instance.loadPosts()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onPostsLoaded), name: "PostsLoaded", object: nil)
        
        posts = DataService.instance.loadingPost
        
        print("url load data \(url)")
        let nsUrl = NSURL(string: url)!
        Alamofire.request(.GET, nsUrl).responseJSON { response in
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                    print("load new data")
                    self.indicator.stopAnimating()
                    for json in jsons {
                        let post = Post(dictionary: json)
                        DataService.instance.addPost(post)
                    }
                }
            } else {
                print(response)
            }
        }
    }
    
    func getDataAccess() {
        if NSUserDefaults.standardUserDefaults().valueForKey(ACCESS_TOKEN_KEY) != nil {
            ACCESS_TOKEN = NSUserDefaults.standardUserDefaults().valueForKey(ACCESS_TOKEN_KEY)! as! String
        } else {
            ACCESS_TOKEN = ""
        }
        
        if NSUserDefaults.standardUserDefaults().valueForKey(USER_ID_KEY) != nil {
            USER_ID = NSUserDefaults.standardUserDefaults().valueForKey(USER_ID_KEY)! as! String
        } else {
            USER_ID = ""
        }
    }
    
    func setupSocketIO() {
        socket.on("viewed") {data, ack in
            print("nhay view ")
            if let postId = data as? [Dictionary<String, AnyObject>] {
                if let str = postId[0]["id"] as? Int {
                    for (index, post) in self.posts.enumerate() {
                        if Int(post.postId) ==  str {
                            if let view = postId[0]["views"] as? Int {
                                self.posts[index].views = view
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                
            }
        }
        socket.on("liked") {data, ack in
            if let postId = data as? [Dictionary<String, AnyObject>] {
                if let str = postId[0]["id"] as? Int {
                    for (index, post) in self.posts.enumerate() {
                        if Int(post.postId) ==  str {
                            print("socket like \(data)")
                            if let likes = postId[0]["likesCount"] as? Int {
                                self.posts[index].likes = likes
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                
            }
        }
        /*
        socket.on("notification") {data, ack in
            
            if self.tabBarController != nil {
                if let items = self.tabBarController!.tabBar.items {
                    for item in items {
                        if item.tag == 1 {
                            item.badgeValue = "1"
                        }
                    }
                }
            }
        }
        
        socket.on("connect") {data, ack in
            self.socket.emit("username", USER_ID)
        }*/
        socket.connect()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            let post = posts[indexPath.row]
            
            cell.imgCommentButton.tag = indexPath.row
            cell.imgCommentButton.addTarget(self, action: #selector(ViewController.viewComment(_:)), forControlEvents: .TouchUpInside)
            
            cell.btnLike.tag = indexPath.row
            cell.btnLike.addTarget(self, action: #selector(ViewController.likePost(_:)), forControlEvents: .TouchUpInside)
            
            cell.btnShare.tag = indexPath.row
            cell.btnShare.addTarget(self, action: #selector(ViewController.sharePost(_:)), forControlEvents: .TouchUpInside)
        /*
            cell.btnViewProfile.tag = indexPath.row
            cell.btnViewProfile.addTarget(self, action: #selector(ViewController.viewProfileUser(_:)), forControlEvents: .TouchUpInside)
            */
            
            let tapHastag = UITapGestureRecognizer(target: self, action: #selector(ViewController.myMethodToHandleTap(_:)))
            tapHastag.numberOfTapsRequired = 1
            cell.CaptionVideofield.addGestureRecognizer(tapHastag)
            
            cell.configureCell(post, indexPath: indexPath.row)
            
            cell.lblUserName.tag = indexPath.row
            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.viewProfileUser(_:)))
            tap.numberOfTapsRequired = 1
            cell.lblUserName.userInteractionEnabled = true
            cell.lblUserName.addGestureRecognizer(tap)
            
            
            return cell
        } else {
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if videoPlayNow >= 0 {
            let nsIndexPath = NSIndexPath(forRow: videoPlayNow, inSection: 0)
            //if let cell = tableView.cellForRowAtIndexPath(nsIndexPath) {
            if tableView.cellForRowAtIndexPath(nsIndexPath) == nil {
                pauseAllVideo()
            }
        }
        /*if videoPlayNow == indexPath.row {
            pauseAllVideo()
        }*/
    }
    
    var timer = NSTimer()
    var checkTimerLoadVideo = true;
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y >= 0 {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        if checkTimerLoadVideo {
            checkTimerLoadVideo = false
            timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: false)
        }
    }

    
    func update() {
        if let cells = tableView.visibleCells as? [UITableViewCell] where cells != [] {
            checkTimerLoadVideo = true
            var cell: UITableViewCell
            
            let indexPath: Int!
            if cells.count == 3 {
                indexPath = tableView.indexPathForCell(cells[1])!.row
                cell = cells[1]
            } else if cells.count == 2 {
                let maxYcell = cells[0].frame.maxY
                let minY = tableView.bounds.minY
                let maxY = tableView.bounds.maxY
                let rangeScreen = maxY - minY
                
                if maxYcell >= maxY - rangeScreen/2 {
                    indexPath = tableView.indexPathForCell(cells[0])!.row
                    cell = cells[0]
                } else {
                    indexPath = tableView.indexPathForCell(cells[1])!.row
                    cell = cells[1]
                }
                
            } else if cells.count == 1 {
                indexPath = tableView.indexPathForCell(cells[0])!.row
                cell = cells[0]
            } else {
                indexPath = tableView.indexPathForCell(cells[0])!.row
                cell = cells[0]
            }
            playVideoNow(cell,indexPath: indexPath)
        }
    }
    
    func playVideoNow(cell: UITableViewCell, indexPath: Int) {
        if let post = posts[indexPath] as? Post {
            if videoPlayNow != indexPath{
                pauseAllVideo()
                playVideo(cell, post: post)
                videoPlayNow = indexPath
            } else {
                print("agian")
            }
        }
    }
    
    func playVideo(cell: UITableViewCell, post: Post) {
        let videoPath = post.videoPath
        let fullPath = DataService.instance.documentPathForFilename(videoPath)
        let nsUrl = NSURL(string: fullPath)
        
        PLAYER_NOW =  AVPlayer(URL: nsUrl!)
        
        let witdthPlayVideo = self.view.frame.size.width
        let uiview = UIView(frame: CGRectMake(0, 63, witdthPlayVideo, witdthPlayVideo))
        uiviewVideo = uiview
        uiviewVideo.backgroundColor = UIColor.darkGrayColor()
        uiviewVideo.tag = 99
        uiviewVideo.alpha = 0
        
        cell.addSubview(uiviewVideo)
    
        playerController.view.frame = uiviewVideo.bounds
        playerController.view.sizeToFit()
        playerController.view.alpha = 0.0
        
        playerController.showsPlaybackControls = false
        playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        
        uiviewVideo.insertSubview(playerController.view, atIndex: 0)
        playerController.player = PLAYER_NOW
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(ViewController.delayPlayVideo), userInfo: nil, repeats: false)
        
        loopVideo(PLAYER_NOW, post: post)
        
        let uiviewTapVideo = UIView(frame: CGRectMake(0, 63, witdthPlayVideo, witdthPlayVideo))
        cell.addSubview(uiviewTapVideo)
        self.view.bringSubviewToFront(uiviewTapVideo)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapToVideo(_:)))
        gesture.numberOfTapsRequired = 1
        uiviewTapVideo.userInteractionEnabled = true
        uiviewTapVideo.addGestureRecognizer(gesture)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapToVideo(_:)))
        doubleTap.numberOfTapsRequired = 2
        uiviewTapVideo.userInteractionEnabled = true
        uiviewTapVideo.addGestureRecognizer(doubleTap)
    }
    
    func delayPlayVideo() {
        playerController.view.alpha = 1.0
        uiviewVideo.alpha = 1.0
        PLAYER_NOW.play()
        if (PLAYER_NOW.rate != 0 && PLAYER_NOW.error == nil) {
            
        } else {
            print("player.error \(PLAYER_NOW.error)")
        }
    }
    
    private func loopVideo(videoPlayer: AVPlayer, post: Post) {
        Observer = NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil) { notification in
            videoPlayer.seekToTime(kCMTimeZero)
            videoPlayer.play()
            
            print("loop video :\(videoPlayer)")
            Alamofire.request(.PUT, URL_PUT_VIEW_POST(post.postId))
        }
    }
 
    func onPostsLoaded() {
        posts = DataService.instance.loadingPost
        tableView.reloadData()
    }
    /*
    @IBAction func btnCameraACTION(sender: UIButton) {
        //pauseAllVideo()
    }*/
    func pauseAllVideo() {
        tableView.viewWithTag(99)?.removeFromSuperview()
        PLAYER_NOW.pause()
        PLAYER_NOW = AVPlayer()
        if Observer != nil {
            NSNotificationCenter.defaultCenter().removeObserver(Observer)
        }
    }
    
    func viewComment(sender: UIButton) {
        //pauseAllVideo()
        let commentUrl = posts[sender.tag].postId
        
        if let viewCommentVC = storyboard!.instantiateViewControllerWithIdentifier("ViewCommentVC") as? ViewCommentVC {
            
            viewCommentVC.post_id = commentUrl
            self.navigationController?.showViewController(viewCommentVC, sender: nil)
            //presentViewController(viewCommentVC, animated: true, completion: nil)
        }
        //self.performSegueWithIdentifier("ViewCommentVC", sender: commentUrl)
    }
    
    func likePost(sender: UIButton) {
        print("like post")
        let post = posts[sender.tag]
        let postId = post.postId
        post.isLikePost = !post.isLikePost
        
        Alamofire.request(.PUT, URL_PUT_LIKE_POST(postId, isLike: post.isLikePost))
    }
   
    func sharePost(sender: UIButton) {
        /*let shareContent = "co gi hot"
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
        */
        let textToShare = "Swift is awesome!  Check out this website about it!"
        
        if let myWebsite = NSURL(string: "http://www.google.com/") {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    var isDouleTap = false
    func tapToVideo(sender: UITapGestureRecognizer) {
        isDouleTap = false
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.checkTapOrDouleTap), userInfo: nil, repeats: false)
    }
    
    func checkTapOrDouleTap() {
        if isDouleTap == false {
            if ((PLAYER_NOW.rate != 0) && (PLAYER_NOW.error == nil)) {
                PLAYER_NOW.pause()
            }else {
                PLAYER_NOW.play()
            }
        }
    }
    
    func doubleTapToVideo(sender: UITapGestureRecognizer) {
        isDouleTap = true
        
        let locationTap = sender.locationInView(sender.view)
        let imageName = "loved"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        let widthIcon: CGFloat = 80.0
        
        imageView.frame = CGRect(x: locationTap.x - widthIcon/2, y: locationTap.y - widthIcon/2, width: widthIcon, height: widthIcon)
        
        sender.view?.addSubview(imageView)
        
        UIView.animateWithDuration(0.5, delay: 0, options: [.Repeat, .Autoreverse, .CurveEaseOut], animations: {
            imageView.frame.size.width = 90
            imageView.frame.size.height = 90
        }, completion: nil)
        UIView.animateWithDuration(2) {
            imageView.alpha = 0.0
        }
        
        PLAYER_NOW.play()
        
        let postId = posts[videoPlayNow].postId
        if posts[videoPlayNow].isLikePost == false {
            posts[videoPlayNow].isLikePost = true
            Alamofire.request(.PUT, URL_PUT_LIKE_POST(postId, isLike: true))
        }
        
    }
    
    func viewProfileUser(sender: UITapGestureRecognizer) {
        let tag = sender.view!.tag
        let user = posts[tag]
        let userId = user.userId
       
        if let profileVC = storyboard!.instantiateViewControllerWithIdentifier("ProfileVC") as? ProfileVC {
            profileVC.userId = userId
            profileVC.userAvatar = user.userAvatar
            profileVC.userName = user.userName
            
            self.navigationController?.showViewController(profileVC, sender: nil)
        }
    }
    
    func myMethodToHandleTap(sender: UITapGestureRecognizer) {
        let myTextView = sender.view as! UITextView
        let layoutManager = myTextView.layoutManager
        
        var location = sender.locationInView(myTextView)
        location.x -= myTextView.textContainerInset.left;
        location.y -= myTextView.textContainerInset.top;
        
        let characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: myTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if characterIndex < myTextView.textStorage.length {
            
            let attributeName = "Hashtag"
            let attributeValue = myTextView.attributedText.attribute(attributeName, atIndex: characterIndex, effectiveRange: nil) as? String
            if let value = attributeValue {
                print("You tapped on \(attributeName) and the value is: \(value)")
                let dataPass = value
                
                if let showExploreVC = storyboard!.instantiateViewControllerWithIdentifier("ShowExploreVC") as? ShowExploreVC {
                    showExploreVC.type = "hashtag"
                    showExploreVC.data = dataPass
                    showExploreVC.cateName = dataPass
                    
                    self.navigationController?.showViewController(showExploreVC, sender: nil)
                }
            }
            
        }
    }
}

