//
//  LoginVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/30/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var uivBackground: UIView!
    @IBOutlet weak var uivLogin: MaterialView!
    
    @IBOutlet weak var uivSignup: MaterialView!
    @IBOutlet weak var txtSignupEmail: UITextField!
    @IBOutlet weak var txtSignupUsername: UITextField!
    @IBOutlet weak var txtSignupPassword: UITextField!
    
    @IBOutlet weak var txtInputEmail: UITextField!
    @IBOutlet weak var txtInputPass: UITextField!
    
    private var video: Video!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.addSubview(FBSDKLoginButton.init(frame: CGRectMake(0,0,180,40)))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        playVideoBackground()
        self.uivLogin.alpha = 0
        
        if NSUserDefaults.standardUserDefaults().valueForKey(ACCESS_TOKEN_KEY) != nil {
            ACCESS_TOKEN = NSUserDefaults.standardUserDefaults().valueForKey(ACCESS_TOKEN_KEY)! as! String
            video.stopVideo()
            performSegueWithIdentifier("FirstFollowVC", sender: nil)
        }
        
        UIView.animateWithDuration(1.5) {
            self.uivLogin.alpha = 0.9
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        video.stopVideo()
    }
    
    func playVideoBackground() {
        if let path = NSBundle.mainBundle().pathForResource("beach", ofType: "mp4") {
            let urlVideo = NSURL(fileURLWithPath: path)
            video = Video(pathVideo: urlVideo, UIViewVideo: uivBackground, loop: true)
            video.isMuteVideo = true
        } else {
            print("Can't load path Video!")
        }
    }
    
    @IBAction func btnLoginFacebook(sender: UIButton) {
        let Facebooklogin = FBSDKLoginManager()
        
        //Facebooklogin.logInWithReadPermissions(["email", "public_profile", "user_friends"]) { (FbResult: FBSDKLoginManagerLoginResult!, FbError: NSError!) in
        
        Facebooklogin.logInWithReadPermissions(["email", "public_profile", "user_friends"], fromViewController: self, handler: { (FbResult: FBSDKLoginManagerLoginResult!, FbError: NSError!) in
            
            if FbError != nil {
                print("Facebook Login fail \(FbError)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                let userFbId = FBSDKAccessToken.currentAccessToken().userID
                
                print("Successfully login with Facebook user_id \(userFbId) accessToken \(accessToken)")
                
                FBSDKGraphRequest(graphPath: "me?fields=id,name,email,gender", parameters: nil).startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, fbResult: AnyObject!, error: NSError!) in
                    
                    if error != nil {
                        print(error.debugDescription)
                    } else {
                        print(fbResult)
                        let urlPost = URL_LOGIN_FACEBOOK
                        Alamofire.request(.POST, urlPost, parameters: ["accessToken": accessToken, "data" : fbResult]).responseJSON { response in
                            
                            if let res = response.result.value as? Dictionary<String, AnyObject> {
                                print("data login \(res)")
                                ACCESS_TOKEN = res["token"] as? String
                                let uid = res["id"] as! Int
                                USER_ID = "\(uid)"
                                if let arFollow = res["following"] as? [Int] {
                                    if arFollow.count == 0 {
                                        self.saveAccessToken(true)
                                    } else {
                                        self.saveAccessToken(false)
                                    }
                                } else {
                                    self.saveAccessToken(true)
                                }
                            }
                        }
                    }
                })
            }
        })
    }
    
    func saveAccessToken(isFirstLogin: Bool) {
        print("ACCESS_TOKEN_KEY \(ACCESS_TOKEN)")
        NSUserDefaults.standardUserDefaults().setObject(ACCESS_TOKEN!, forKey: ACCESS_TOKEN_KEY)
        NSUserDefaults.standardUserDefaults().setObject(USER_ID!, forKey: USER_ID_KEY)
        
        NSUserDefaults.standardUserDefaults().synchronize()
        
        if isFirstLogin {
            dispatch_async(dispatch_get_main_queue()) {
                [unowned self] in
                self.video.stopVideo()
                self.performSegueWithIdentifier("FirstFollowVC", sender: USER_ID)
            }
        } else {
            if let newFeedVC = storyboard!.instantiateViewControllerWithIdentifier("FollowVCToNewfeedsVC") as? TabBarController {
                presentViewController(newFeedVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func btnLoginEmail(sender: UIButton) {
        if txtInputEmail.text == "" || txtInputPass.text == ""{
            print("error")
            ShowErrorInputLoginEmail("Vui lòng điền đúng email và mật khẩu để đăng nhập nhé <3")
        } else {
            print("no error")
            let username = txtInputEmail.text!
            let password = txtInputPass.text!
            var isDoneSignup = true
            
            Alamofire.request(.POST, URL_SIGNIN, parameters: ["username": username, "password" : password]).response(completionHandler: { (rq: NSURLRequest?, res: NSHTTPURLResponse?, data: NSData?, error: NSError?) in
                print("res \(res)")
                if res?.statusCode == 401 {
                    self.ShowErrorInputLoginEmail("Email hoặc password không đúng, xem lại đi nhóe <3")
                    isDoneSignup = false
                } else if res?.statusCode == 400 {
                    isDoneSignup = false
                } else if res?.statusCode == 200 {
                    isDoneSignup = true
                }
                
            }).responseJSON(completionHandler: { response in
                if isDoneSignup {
                    if let res = response.result.value as? Dictionary<String, AnyObject> {
                        if let data = res["user"] as? Dictionary<String, AnyObject> {
                            ACCESS_TOKEN = data["token"] as? String
                            USER_ID = data["id"] as? String
                            print("USER_ID \(USER_ID)")
                            self.saveAccessToken(false)
                        }
                    }
                } else {
                    if let res = response.result.value as? Dictionary<String, AnyObject> {
                        if let message = res["message"] as? String {
                            self.ShowErrorInputLoginEmail("Có lỗi xảy ra, vui lòng thử lại: \(message)")
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func btnSignupEmail(sender: UIButton) {
        uivSignup.hidden = true
        uivSignup.center.x = self.view.frame.width * 2

        UIView.animateWithDuration(0.5, animations: { 
            self.uivLogin.center.x = -self.view.frame.width
            self.uivSignup.center.x = self.view.center.x
            self.uivSignup.hidden = false
        }) { (true) in
                self.uivLogin.hidden = true
        }
    }
    
    @IBAction func btnBackToLogin(sender: UIButton) {
        self.uivLogin.hidden = true
        
        UIView.animateWithDuration(0.5, animations: {
            self.uivLogin.center.x = self.view.center.x
            self.uivSignup.center.x = self.view.frame.width * 2
            self.uivLogin.hidden = false
        }) { (true) in
            self.uivSignup.hidden = true
        }
        
    }
    
    @IBAction func btnSignUp(sender: UIButton) {
        let email = txtSignupEmail.text!
        let pass = txtSignupPassword.text!
        let username = txtSignupUsername.text!
        if email == "" || pass == "" || username == "" {
            ShowErrorInputLoginEmail("Vui lòng điền đúng và đầy đủ thông tin nhé <3")
        } else {
            let whitespace = NSCharacterSet.whitespaceCharacterSet()
            let range = email.rangeOfCharacterFromSet(whitespace)
            let range2 = username.rangeOfCharacterFromSet(whitespace)
            var isDoneSignup = true
            
            // range will be nil if no whitespace is found
            if range != nil || range2 != nil{
                ShowErrorInputLoginEmail("Email và username không thể có ký tự trắng!")
            } else {
                Alamofire.request(.POST, URL_SIGNUP, parameters: ["email" : email, "password" : pass, "username" : username]).response(completionHandler: { (rq: NSURLRequest?, res: NSHTTPURLResponse?, data: NSData?, error: NSError?) in
                    if res?.statusCode == 400 {
                        isDoneSignup = false
                    } else {
                        isDoneSignup = true
                    }
                    
                }).responseJSON(completionHandler: { response in
                    if isDoneSignup {
                        if let res = response.result.value as? Dictionary<String, AnyObject> {
                            if let data = res["user"] as? Dictionary<String, AnyObject> {
                                ACCESS_TOKEN = data["token"] as? String
                                USER_ID = data["id"] as? String
                                print("USER_ID \(USER_ID)")
                                self.saveAccessToken(true)
                            }
                        }
                    } else {
                        if let res = response.result.value as? Dictionary<String, AnyObject> {
                            if let message = res["message"] as? String {
                                self.ShowErrorInputLoginEmail("Có lỗi xảy ra, vui lòng thử lại: \(message)")
                            }
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func forgetPassword(sender: UIButton) {
        let email = txtInputEmail.text!
        let alert = UIAlertController(title: "Thông báo", message: "Bạn đã quên mật khẩu đăng nhập? Chúng tôi biết bạn đang rất lo lắng nhưng hãy yên tâm, bạn có muốn lấy lại mật khẩu qua email: \(email)", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Lấy lại mật khẩu qua email", style: UIAlertActionStyle.Default, handler: { action in
            Alamofire.request(.POST, URL_FORGET_PASSWORD, parameters: ["email" : email]).response(completionHandler: { (rq: NSURLRequest?, res: NSHTTPURLResponse?, data: NSData?, error: NSError?) in
                if res?.statusCode == 400 {
                    self.ShowErrorInputLoginEmail("Đã có lỗi xảy ra, vui lòng thử lại nhóe!")
                } else {
                    let message = "Vui lòng kiểm tra email \(email) để lấy lại mật khẩu nhé, hẹn gặp lại <3"
                    let alert = UIAlertController(title: "Hoàn Thành", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            })
            
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FirstFollowVC" {
            if let FirstFollowVC = segue.destinationViewController as? FirstFollowVC {
                if let user_id = sender as? String {
                    FirstFollowVC.user_id = user_id
                }
            }
        }
    }
    
    func ShowErrorInputLoginEmail(message: String) {
        // create the alert
        let alert = UIAlertController(title: "Lỗi mất rồi :(", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func hideKeyboard(){
        txtInputEmail.resignFirstResponder()
        txtInputPass.resignFirstResponder()
        txtSignupUsername.resignFirstResponder()
        txtSignupEmail.resignFirstResponder()
        txtSignupPassword.resignFirstResponder()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        hideKeyboard()
    }
    
}
