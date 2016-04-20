//
//  ExploreVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/6/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire

class ExploreVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableviewCategories: UITableView!
    @IBOutlet weak var tableviewSearch: UITableView!
    
    @IBOutlet weak var uivTrending: UIView!
    @IBOutlet weak var uivContainerSearchResult: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var topics = [Dictionary<String, AnyObject?>]()
    var searchDataPeople = [Friend]()
    var searchDataPosts = [Post]()
    var searchDataHashtag = [Dictionary<String, String>]()
    
    let typeSearch: [String] = ["article", "user", "hashtag"]
    var indexSearch: Int = 0
    
    var refreshControl: UIRefreshControl!
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableviewCategories.delegate = self
        tableviewCategories.dataSource = self
        
        tableviewSearch.delegate = self
        tableviewSearch.dataSource = self
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.Done
        
        setupRefreshControl()
        
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
        loadCotegory()
        loadTrending()
        
        let hashtag1 = ["name": "#hot", "count": "3"]
        searchDataHashtag.append(hashtag1)
        let hashtag2 = ["name": "#dau", "count": "5"]
        searchDataHashtag.append(hashtag2)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func loadCotegory() {
        print(URL_GET_CATEGORIES)
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
                        self.indicator.stopAnimating()
                        self.tableviewCategories.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                } else {
                    print("Load topic follow \(response)")
                }
            }
        }
    }
    
    func loadTrending() {
        Alamofire.request(.GET, URL_GET_TRENDING).responseJSON { response in
            if response.result.error != nil {
                print("error load follow \(response.result.error)")
            } else {
                if let res = response.result.value as? Dictionary<String, AnyObject> {
                    if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                        for (index, json) in jsons.enumerate() {
                            let width = self.view.frame.size.width / 2 - 8 - 2
                            var frame: CGRect
                            var x: CGFloat
                            var y: CGFloat!
                            
                            let check = index % 2
                            if check == 0 {
                                y = CGFloat(index * 25 / 2 + index * 4 / 2)
                                x = 0
                            } else {
                                y = CGFloat((index - 1) * 25 / 2 + (index - 1) * 4 / 2)
                                x = width + 4
                            }
                            
                            frame = CGRectMake(x, y, width, 25.0)
                            let btnTrend = UIButton(frame: frame)
                            if let trend = json["_id"] as? String {
                                btnTrend.setTitle(trend, forState: .Normal)
                            } else {
                                continue
                            }
                            
                            btnTrend.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
                            btnTrend.titleLabel!.font =  UIFont(name: "HelveticaNeue-Thin", size: 14)
                            btnTrend.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
                            btnTrend.layer.cornerRadius = 3.0
                            
                            btnTrend.addTarget(self, action: #selector(self.btnChooseTrend(_:)), forControlEvents: .TouchUpInside)
                            
                            self.uivTrending.addSubview(btnTrend)
                        }
                    }
                }
            }
        }
    }
    
    func btnChooseTrend(sender: UIButton) {

        let data = sender.titleForState(.Normal)
        if let showExploreVC = storyboard!.instantiateViewControllerWithIdentifier("ShowExploreVC") as? ShowExploreVC {
            showExploreVC.type = "hashtag"
            showExploreVC.data = data
            showExploreVC.cateName = data
            
            self.navigationController?.showViewController(showExploreVC, sender: nil)
        }
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Load new post")
        refreshControl.addTarget(self, action: #selector(ViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableviewCategories.addSubview(self.refreshControl)
    }
    
    func refresh(sender:AnyObject)
    {
        loadCotegory()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableviewCategories {
            return topics.count
        } else {
            if indexSearch == 0 {
                return searchDataPosts.count
            } else if indexSearch == 1 {
                return searchDataPeople.count
            } else if indexSearch == 2 {
                return searchDataHashtag.count
            } else {
                return searchDataPeople.count
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("ExploreCell") as? ExploreCell {

            let topic = topics[indexPath.row]
            cell.configureCell(topic)
            cell.btnChooseCategory.tag = indexPath.row
            cell.btnChooseCategory.addTarget(self, action: #selector(self.btnChooseCategoryACTION(_:)), forControlEvents: .TouchUpInside)
            
            return cell
        
        } else if let cell = tableView.dequeueReusableCellWithIdentifier("ShowSearchCell") as? ShowSearchCell {
            if indexSearch == 0 {
                let post = searchDataPosts[indexPath.row]
                print(post)
                cell.imgVideoThumb.tag = indexPath.row
                cell.imgVideoThumb.userInteractionEnabled = true
                
                let tapVideoThumb = UITapGestureRecognizer(target: self, action: #selector(ExploreVC.tappedVideoThumb(_:)))
                tapVideoThumb.numberOfTapsRequired = 1
                cell.imgVideoThumb.addGestureRecognizer(tapVideoThumb)
                
                let tapUsername = UITapGestureRecognizer(target: self, action: #selector(ExploreVC.myMethodToHandleTap(_:)))
                tapUsername.numberOfTapsRequired = 1
                cell.textViewData.addGestureRecognizer(tapUsername)
                
                cell.configureCellPost(post)
            } else if indexSearch == 1 {
                let friend = searchDataPeople[indexPath.row]
                
                let tapUsername = UITapGestureRecognizer(target: self, action: #selector(ExploreVC.myMethodToHandleTap(_:)))
                tapUsername.numberOfTapsRequired = 1
                cell.textViewData.addGestureRecognizer(tapUsername)
                
                cell.configureCellUser(friend, tag: indexPath.row)
            } else if indexSearch == 2 {
                let hashtag = searchDataHashtag[indexPath.row]
                print("hashtag \(hashtag)")
                cell.configureCellHashtag(hashtag["name"]!, count: hashtag["count"]!)
            }
        
            return cell
        } else {
            return ExploreCell()
        }
    }
    
    @IBAction func btnMenuQuickACTION(sender: UIButton) {
        let tag = sender.tag
        var cateId: String!
        var cateName: String!
        
        if tag == 1 {
            cateId = "created"
            cateName = "Mới Toanh"
        } else if tag == 2 {
            cateId = "hot"
            cateName = "Hot"
        } else if tag == 3 {
            cateId = "featured"
            cateName = "Trào lưu"
        }
        if let showExploreVC = storyboard?.instantiateViewControllerWithIdentifier("ShowExploreVC") as? ShowExploreVC {
            showExploreVC.type = "hot"
            showExploreVC.data = cateId
            showExploreVC.cateName = cateName
            self.navigationController?.showViewController(showExploreVC, sender: nil)
        }
        //performSegueWithIdentifier("ShowExploreVC", sender: cateId)
    }
    
    func btnChooseCategoryACTION(sender: UIButton) {
        let tag = sender.tag
        performSegueWithIdentifier("ShowExploreVC", sender: tag)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowExploreVC" {
            if let showExploreVC = segue.destinationViewController as? ShowExploreVC {
                if let dataSender = sender as? Int {
                    showExploreVC.type = "category"
                    if let cateId = topics[dataSender]["_id"] as? Int {
                        showExploreVC.data = "\(cateId)"
                    }
                    if let name = topics[dataSender]["name"] as? String {
                        showExploreVC.cateName = name
                    }
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
        print("search button click")
        let lower = searchBar.text!.lowercaseString
        getDataSearch(lower, page: 1)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
        uivContainerSearchResult.hidden = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.barTintColor = UIColor.whiteColor()
        self.view.backgroundColor = UIColor.whiteColor()
        
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.darkTextColor()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        uivContainerSearchResult.hidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.barTintColor = COLOR_FUNEYE
        self.searchBar.tintColor = UIColor.whiteColor()
        
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        
        let buttonInsideSearchBar = searchBar.valueForKey("cancelButton") as? UIButton
        buttonInsideSearchBar?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        self.view.backgroundColor = COLOR_FUNEYE
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            print("search nil")
        } else {
            let lower = searchBar.text!.lowercaseString
            //getDataSearch(lower, page: 1)
        }
    }
    
    func getDataSearch(text: String, page: Int) {
        indicator.startAnimating()
        let type = typeSearch[indexSearch]
        let url = URL_SEARCH(type, text: text, page: page)
        print("url search \(url)")
        Alamofire.request(.GET, url).responseJSON { response in
            if response.result.error != nil {
                print("error load follow \(response.result.error)")
            } else {
                if let res = response.result.value as? Dictionary<String, AnyObject> {
                    if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                        if jsons.count == 0 {
                            print("data search empty")
                        } else {
                            self.searchDataPosts = []
                            self.searchDataPeople = []
                            for json in jsons {
                                //print(json)
                                if self.indexSearch == 0 {
                                    let post = Post(dictionary: json)
                                    print(post.caption)
                                    self.searchDataPosts.append(post)
                                } else if self.indexSearch == 1 {
                                    let friend = Friend(dictionary: json)
                                    self.searchDataPeople.append(friend)
                                }
                            }
                        }
                        self.indicator.stopAnimating()
                        self.tableviewSearch.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func sgmChangeValue(sender: UISegmentedControl) {
        indexSearch = sender.selectedSegmentIndex
        if searchBar.text == nil || searchBar.text == "" {
            print("search nil 2")
        } else {
            let text = searchBar.text!.lowercaseString
            getDataSearch(text, page: 1)
        }
    }
    
    func tappedVideoThumb(sender: UITapGestureRecognizer) {
        let tag = sender.view?.tag
        let postId = searchDataPosts[tag!].postId
        if let viewSinglePostVC = storyboard!.instantiateViewControllerWithIdentifier("ViewSinglePostVC") as? ViewSinglePostVC {
            viewSinglePostVC.postId = postId
            viewSinglePostVC.isViewNextComment = false
            
            self.navigationController?.showViewController(viewSinglePostVC, sender: nil)
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
            
            let attributeName = "username"
            let attributeValue = myTextView.attributedText.attribute(attributeName, atIndex: characterIndex, effectiveRange: nil) as? String
            if let value = attributeValue {
                print("You tapped on \(attributeName) and the value is: \(value)")
                let dataPass = value
                if let profileVC = storyboard!.instantiateViewControllerWithIdentifier("ProfileVC") as? ProfileVC {
                    profileVC.userId = dataPass
                    self.navigationController?.showViewController(profileVC, sender: nil)
                }
            }
        }
    }
    
    func followFriendsACTION(sender: UIButton) {
        let tag = sender.tag
        searchDataPeople[tag].followFriends()
        tableviewSearch.reloadData()
    }
}
