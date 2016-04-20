//
//  CameraVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/28/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire

class CameraVC: UIViewController, AVCaptureFileOutputRecordingDelegate {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var loadingRecrodingView: UIView!
    
    @IBOutlet weak var showMusicView: UIView!
    @IBOutlet weak var lblMusicView: UILabel!
    
    @IBOutlet weak var btnRecording: UIButton!
    
    var captureSession : AVCaptureSession?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var videoNSURLs = [NSURL]()
    var arrayAudio = [NSURL]()
    
    var dataPass = [String: [NSURL]]()
//    var dataPass: [String: [NSURL]] = ["video" : [NSURL], "audio" : [NSURL]]
    
    var movieOutput = AVCaptureMovieFileOutput()
    var cameraSwitch = false
    
    var timer: NSTimer!
    var widthLoadingRecording: CGFloat = 0.0
    var timeLoading = 10
    var rangeGrowth: CGFloat = 0.0
    var isTimeOver = false
    
    var audioMusicNSURL: NSURL!
    var audioMusicAvplayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*btnRecording.layer.cornerRadius = btnRecording.layer.frame.width / 2
        btnRecording.clipsToBounds = true*/
        setupCamera()
        LoadNsurlFromUrl("https://www.linkme.vn/images/tamsu2.mp3")
    }
    
    override func viewDidAppear(animated: Bool) {
        previewLayer?.frame = cameraView.bounds
        
    }
    
    @IBAction func btnRecordingPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            print("ennd press")
            btnRecording.imageView!.image = UIImage(named: "record")
            btnRecording.clipsToBounds = true
            stopRecording()
            pauseAudioMuSic()
        } else if sender.state == UIGestureRecognizerState.Began {
            playAudioMuSic()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(CameraVC.updateProgress), userInfo: nil, repeats: true)
            
            btnRecording.imageView!.image = UIImage(named: "record_active")
            btnRecording.clipsToBounds = true
            
            movieOutput.startRecordingToOutputFileURL(createTempPath(PATH_SAVE_RCORDING_VIDEO), recordingDelegate: self)
            
            print("start press")
        }
    }
    
    
    @IBAction func btnBackVC(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupCamera() {
        
        captureSession = AVCaptureSession()
        
        /*captureSession?.stopRunning()
        previewLayer?.removeFromSuperlayer()*/
        //captureSession?.sessionPreset = AVCaptureSessionPresetMedium
        captureSession?.sessionPreset = AVCaptureSessionPreset640x480
        
        //captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        var backCamera:AVCaptureDevice! = nil
        
        if cameraSwitch == false {
            backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        } else {
            backCamera = self.cameraWithPosition(AVCaptureDevicePosition.Front)
        }
        
        var error : NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
            
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if (error == nil && captureSession?.canAddInput(input) != nil){
            
            captureSession?.addInput(input)
            movieOutput.movieFragmentInterval = kCMTimeInvalid
            captureSession?.addOutput(movieOutput)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            
            let bounds = self.view.bounds
            print(bounds)
            print("width \(CGRectGetMidX(bounds))")
            print(CGRectGetMidY(bounds))
            
            
            previewLayer?.bounds = bounds
            previewLayer?.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
            print(previewLayer?.position)
            
            cameraView.layer.addSublayer(previewLayer!)
            
            captureSession?.startRunning()
            
        }
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if (error != nil)
        {
            print("Unable to save video to the iPhone  \(error.localizedDescription)")
        }
        else
        {
            // save video to photo album
            print("done recording video \(outputFileURL)")
            videoNSURLs.append(outputFileURL)
            
            if isTimeOver {
                passDataToVC()
            } else {
                print("chua het gio recording")
            }
        }
    }
    
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice {
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if(device.position == position){
                return device as! AVCaptureDevice
            }
        }
        return AVCaptureDevice()
    }
    
    func stopRecording(){
        movieOutput.stopRecording()
        audioMusicAvplayer.stop()
        if movieOutput.recording {
            
        }
        timer.invalidate()
    }
    
    func updateProgress() {
        let widthUiview = loadingRecrodingView.frame.size.width
        let heightUiview = loadingRecrodingView.frame.size.height
        rangeGrowth = widthUiview / (CGFloat(timeLoading) * 20)
        widthLoadingRecording += rangeGrowth
        
        if widthLoadingRecording <= widthUiview {
            let loadingRecordingFrame : CGRect = CGRectMake(0,0,widthLoadingRecording,heightUiview)
            let loadingRecordingView : UIView = UIView(frame: loadingRecordingFrame)
            loadingRecordingView.backgroundColor = UIColor(red: 100/255, green: 53/255, blue: 201/255, alpha: 1.0)
            
            for subview in loadingRecrodingView.subviews {
                subview.removeFromSuperview()
            }
            loadingRecrodingView.addSubview(loadingRecordingView)
        } else {
            stopRecording()
            isTimeOver = true
        }
    }
    
    @IBAction func nextToReviewVideoVC() {
        //let urlVideo = "day la url cua video do nhe"
        passDataToVC()
    }
    
    func passDataToVC(){
        dataPass["video"] = videoNSURLs
        arrayAudio.append(audioMusicNSURL)
        dataPass["audio"] = arrayAudio
        
        performSegueWithIdentifier("ReviewVideoVC", sender: dataPass)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ReviewVideoVC" {
            if let reviewVideoVC = segue.destinationViewController as? ReviewVideoVC {
                if let dctUrl = sender as? Dictionary<String, [NSURL]> {
                    //print("data pass 3 \(dataPass)")
                    reviewVideoVC.dataPass = dctUrl
                }
            }
        }
    }
    
 
    func LoadNsurlFromUrl(url: String){
        deleteAllSavePathLocal(PATH_SAVE_MUSIC)
        var localPath: NSURL!
        var nameFileMusic: String!
        Alamofire.download(.GET, url, destination: { (temporaryURL, response) in
            let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            nameFileMusic = response.suggestedFilename
            let pathComponent = "\(PATH_SAVE_MUSIC)\(NSDate.timeIntervalSinceReferenceDate()).mp3"
            
            
            localPath = directoryURL.URLByAppendingPathComponent(pathComponent)
            return localPath!
        }).response { (request, response, data, error) in
            
            if error == nil && localPath != nil{
                print("Downloaded file to \(localPath!)")
                self.audioMusicNSURL = localPath
                
                do {
                    self.audioMusicAvplayer = try AVAudioPlayer(contentsOfURL: localPath)
                    self.audioMusicAvplayer.prepareToPlay()
                    self.lblMusicView.text = nameFileMusic
                } catch let err as NSError {
                    print("error play mysic \(err.debugDescription)")
                }
            } else {
                print("error download: \(error.debugDescription)")
            }
        }
    }
    
    func playAudioMuSic() {
        audioMusicAvplayer.play()
    }
    
    func pauseAudioMuSic() {
        audioMusicAvplayer.pause()
    }
    
    
}
