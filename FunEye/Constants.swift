//
//  Constants.swift
//  social network for iOS9 with
//
//  Created by Lê Thanh Tùng on 3/18/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

let SHADOW_COLOR: CGFloat = 157.0 / 255.0
let PATH_SAVE_MUSIC = "music_save"
let PATH_SAVE_VIDEO = "video_save"
let PATH_SAVE_RCORDING_VIDEO = "recording_video_save"

let COLOR_FUNEYE: UIColor = UIColor(red: 100/255, green: 53/255, blue: 201/255, alpha: 1.0)

var PLAYER_NOW = AVPlayer()

func createTempPath(typePath: String) -> NSURL {
    let rand = arc4random()%1000
    let tempPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("\(typePath)_\(rand)").URLByAppendingPathExtension("mp4").absoluteString
    if NSFileManager.defaultManager().fileExistsAtPath(tempPath) {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(tempPath)
        } catch { }
    }
    return NSURL(string: tempPath)!
}

func timeAgoSinceDateString(time: String) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    if let date = dateFormatter.dateFromString(time) {
        return timeAgoSinceDate(date, numericDates: true)
    } else {
      return " "
    }
}

func deleteAllSavePathLocal(path: String) {
    let docsDir =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    
    let fileManager = NSFileManager.defaultManager()
    
    do {
        let files = try fileManager.contentsOfDirectoryAtPath(docsDir)
        var recordings = files.filter( { (name: String) -> Bool in
            return name.hasPrefix(path)
        })
        for i in 0 ..< recordings.count {
            let path = docsDir + "/" + recordings[i]
            
            print("removing \(path)")
            do {
                try fileManager.removeItemAtPath(path)
            } catch let error as NSError {
                NSLog("could not remove \(path)")
                print(error.localizedDescription)
            }
        }
        
    } catch let error as NSError {
        print("could not get contents of directory at \(docsDir)")
        print(error.localizedDescription)
    }
    
}

func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
    let calendar = NSCalendar.currentCalendar()
    let now = NSDate()
    let earliest = now.earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:NSDateComponents = calendar.components([NSCalendarUnit.Minute , NSCalendarUnit.Hour , NSCalendarUnit.Day , NSCalendarUnit.WeekOfYear , NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Second], fromDate: earliest, toDate: latest, options: NSCalendarOptions())
    
    if (components.year >= 2) {
        return "\(components.year)y"
    } else if (components.year >= 1){
        if (numericDates){
            return "1y"
        } else {
            return "Last year"
        }
    } else if (components.month >= 2) {
        return "\(components.month)m"
    } else if (components.month >= 1){
        if (numericDates){
            return "1m"
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear >= 2) {
        return "\(components.weekOfYear)w"
    } else if (components.weekOfYear >= 1){
        if (numericDates){
            return "1w"
        } else {
            return "Last week"
        }
    } else if (components.day >= 2) {
        return "\(components.day) d"
    } else if (components.day >= 1){
        if (numericDates){
            return "1d"
        } else {
            return "Yesterday"
        }
    } else if (components.hour >= 2) {
        return "\(components.hour)h"
    } else if (components.hour >= 1){
        if (numericDates){
            return "1h"
        } else {
            return "An hour ago"
        }
    } else if (components.minute >= 2) {
        return "\(components.minute)p"
    } else if (components.minute >= 1){
        if (numericDates){
            return "1p"
        } else {
            return "A minute ago"
        }
    } else if (components.second >= 3) {
        return "\(components.second)s"
    } else {
        return "mới toanh"
    }
    
}