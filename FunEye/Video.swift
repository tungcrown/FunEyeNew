//
//  Video.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/30/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//
import UIKit
import AVKit
import AVFoundation

class Video {
    
    private var _pathVideo: NSURL!
    private var _videoAVPlpayer: AVPlayer!
    private var _uiviewVideo: UIView!
    private var _isMuteVideo: Bool = false
    private var _isLoopVideo: Bool = true
    
    private var _Observer: NSObjectProtocol!
    
    var videoAVPlayer: AVPlayer {
        return _videoAVPlpayer
    }
    
    var pathVideo: NSURL {
        return _pathVideo
    }
    
    var isMuteVideo: Bool {
        get {
            return _isMuteVideo
        }
        set {
            self._isMuteVideo = newValue
            muteVideo()
        }
    }
    
    init(pathVideo: NSURL, UIViewVideo: UIView, loop: Bool) {
        self._pathVideo = pathVideo
        self._uiviewVideo = UIViewVideo
        self._isLoopVideo = loop
        
        _videoAVPlpayer = AVPlayer(URL: _pathVideo)
        let playerController = AVPlayerViewController()
        
        playerController.view.frame = _uiviewVideo.bounds
        playerController.view.sizeToFit()
        
        playerController.showsPlaybackControls = false
        playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        _uiviewVideo.addSubview(playerController.view)
        playerController.player = _videoAVPlpayer
        
        playVideo()
    }
    
    private func muteVideo() {
        self._videoAVPlpayer.muted = _isMuteVideo
    }

    private func loopVideo(videoPlayer: AVPlayer) {
        self._Observer = NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil) { notification in
            videoPlayer.seekToTime(kCMTimeZero)
            videoPlayer.play()
            
            print("loop video \(self._pathVideo) :\(videoPlayer)")
        }
    }
    
    private func removeLoopVideo() {
        if self._Observer != nil {
            NSNotificationCenter.defaultCenter().removeObserver(self._Observer)
        }
    }
    
    func playVideo() {
        if _videoAVPlpayer != nil {
            _videoAVPlpayer.play()
            if _isLoopVideo {
                loopVideo(_videoAVPlpayer)
            }
        }
    }
    
    func pauseVideo() {
        if _videoAVPlpayer != nil {
            _videoAVPlpayer.pause()
        }
    }
    
    func stopVideo() {
        _videoAVPlpayer.seekToTime(kCMTimeZero)
        _videoAVPlpayer.pause()
        removeLoopVideo()
    }
}