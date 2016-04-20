//
//  FollowVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/7/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import AddressBook
import Contacts
import MessageUI
import Alamofire

class FollowVC: UIViewController, MFMessageComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var followTable: UITableView!
    
    var friends = [Friend]()
    var friendsContacts = [Friend]()
    var friendsFunner = [Friend]()
    var friendsFacebook = [Friend]()
    
    let authorizationStatus = CNContactStore.authorizationStatusForEntityType(.Contacts)
    let contacts: CNContactStore = CNContactStore()
    
    var refreshControl: UIRefreshControl!
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var nextPage = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        followTable.delegate = self
        followTable.dataSource = self
        
        suggestFriendFromFunners(nextPage)
        
        setupRefreshControl()
    }
    
    func setupRefreshControl() {
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Load new post")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        followTable.addSubview(self.refreshControl)
    }
    
    func refresh(sender:AnyObject) {
        print("load new data refresh")
        self.refreshControl.endRefreshing()
    }
    
    func suggestFriendFromFunners(nextPage: Int) {
        let url = URL_SUGGEST_FRIENDS_FROM_FUNNERS(nextPage)
        print("url \(url)")
        Alamofire.request(.GET, url).responseJSON { response in
            print("res \(response)")
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                    for json in jsons {
                        let friend = Friend(dictionary: json)
                        self.friendsFunner.append(friend)
                        self.friends = self.friendsFunner
                    }
                    
                    self.followTable.reloadData()
                }
                
                if let isNext = res["isNext"] as? Bool where isNext == true {
                    self.nextPage += 1
                    self.refreshControl.endRefreshing()
                } else {
                    self.refreshControl.endRefreshing()
                    self.refreshControl.removeFromSuperview()
                    
                }
                
                self.indicator.stopAnimating()
            }
        }
    }
    
    func suggestFriendFromFacebook() {
        let url = URL_GET_FRIEND_FOLLOW
        print("url \(url)")
        Alamofire.request(.GET, url).responseJSON { response in
            print("res \(response)")
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                    for json in jsons {
                        let friend = Friend(dictionary: json)
                        self.friendsFacebook.append(friend)
                        self.friends = self.friendsFacebook
                    }
                    
                    self.followTable.reloadData()
                }
                
                if let isNext = res["isNext"] as? Bool where isNext == true {
                    self.nextPage += 1
                    self.refreshControl.endRefreshing()
                } else {
                    self.refreshControl.endRefreshing()
                    self.refreshControl.removeFromSuperview()
                    
                }
                
                self.indicator.stopAnimating()
            }
        }
    }
    
    func suggestFriendFromContacts() {
        checkAuthorizationContacts()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friends.count > 10 {
            return 10
        } else {
            return friends.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("FollowCell") as? FollowCell {
            let friend = friends[indexPath.row]
            
            cell.btnFollowFriends.tag = indexPath.row
            cell.btnFollowFriends.addTarget(self, action: #selector(self.followFriendsACTION(_:)), forControlEvents: .TouchUpInside)
            
            cell.configureCell(friend)
            return cell
        } else {
            return FollowCell()
        }
    }
    
    func followFriendsACTION(sender: UIButton) {
        let tag = sender.tag
        friends[tag].followFriends()
        followTable.reloadData()
    }
    
    func checkAuthorizationContacts() {
        switch authorizationStatus {
        case .Denied, .Restricted:
            print("Denied")
            openSettings()
        case .Authorized:
            print("Authorized")
            readPeopleFromAddressBook()
        case .NotDetermined:
            print("Not Determined")
            promptForAddressBookRequestAccess()
        }
    }
    
    func promptForAddressBookRequestAccess() {
        contacts.requestAccessForEntityType(.Contacts) { (granted: Bool, error: NSError?) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    print("Just denied")
                } else {
                    print("Just authorized")
                    self.readPeopleFromAddressBook()
                }
            }
        }
    }
    
    func readPeopleFromAddressBook() {
        let toFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: toFetch)
        do{
            try contacts.enumerateContactsWithFetchRequest(request) {
                contact, stop in
                print(contact.givenName)
                print(contact.familyName)
                print(contact.identifier)
                var phoneNumber: String = ""
                for phone in contact.phoneNumbers {
                    if phone.label == CNLabelPhoneNumberMobile {
                        let newPhone = (phone.value as! CNPhoneNumber).stringValue
                        phoneNumber = self.removeSpecialCharsFromString(newPhone)
                        print("phoneNumber222 \(phoneNumber)")
                        break
                    }
                }
                let name = contact.givenName + contact.familyName
                let friend = Friend(name: name, id: phoneNumber, avatarUrl: nil, message: "contacts")
                self.friendsContacts.append(friend)
                self.friends = self.friendsContacts
                self.followTable.reloadData()
            }
        } catch let err{
            print(err)
        }
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("0123456789".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func btnInviteFriendsViaSMS(sender: UIButton) {
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Ê vào quẩy với tui trên Funeye không? http://funeye.net";
        //messageVC.recipients = ["Enter Nguyen Ngoc Dung"]
        messageVC.messageComposeDelegate = self;
        
        self.presentViewController(messageVC, animated: false, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue :
            print("message canceled")
            
        case MessageComposeResultFailed.rawValue :
            print("message failed")
            
        case MessageComposeResultSent.rawValue :
            print("message sent")
            
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnInviteFriendsViaEmail(sender: UIButton) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        //mailComposerVC.setToRecipients(["nurdin@gmail.com"])
        mailComposerVC.setSubject("Ê vào quẩy với tui trên Funeye không?")
        mailComposerVC.setMessageBody("Cùng tôi trải nghiệm Funeye nhé? http://funeye.net", isHTML: false)
        
        return mailComposerVC
    }
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func sgmChangeValue(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            if friendsFunner.count == 0 {
                suggestFriendFromFunners(nextPage)
            } else {
                friends = friendsFunner
                followTable.reloadData()
            }
            
        } else if sender.selectedSegmentIndex == 1 {
            if friendsFacebook.count == 0 {
                suggestFriendFromFacebook()
            } else {
                friends = friendsFacebook
                followTable.reloadData()
            }
        } else if sender.selectedSegmentIndex == 2 {
            if friendsContacts.count == 0 {
                suggestFriendFromContacts()
            } else {
                friends = friendsContacts
                followTable.reloadData()
            }
        }
    }
    
}
