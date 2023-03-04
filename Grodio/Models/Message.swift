//
//  Message.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-07-02.
//  Copyright © 2022 USR. All rights reserved.
//

import Foundation
import UIKit

public struct Message: Codable {

    let senderUsername: String?
    let message: String?
    let creationDate: Date?
    
    init(_senderUsername: String?, _message: String?, _creationDate: Date?) {
        self.senderUsername = _senderUsername
        self.message = _message
        self.creationDate = _creationDate
    }
    
    func equals (compareTo msg: Message) -> Bool{
            return
                self.senderUsername == msg.senderUsername &&
                self.message == msg.message &&
                self.creationDate == msg.creationDate
        }
    
    // if message creation date is oldern than a year, then return in "YY/MM/dd" format
    // else if data is less than a day old then return in format of HH MM SS with abbreviated units
    // else return the creation date in the format "MM/dd"
    public func getCreatedDateInChatTime() -> String {
        
        guard let messageDate = self.creationDate else {
            return ""
        }
        
        if getYearsBetweenDates(from: messageDate, to: Date()) > 0 {//if msg older than an year return full date
            return getDateFormattedStringInYMD(date: messageDate)
        }
         
        switch getDateTimeInterval(date: messageDate) {
        case 0...60://seconds
            return getDateFormattedStringInUnits(date: messageDate, allowedUnits: .second) + " ago"
        case 61..<3600://minutes
            return getDateFormattedStringInUnits(date: messageDate, allowedUnits: .minute) + " ago"
        case 3600...86400://hours
            return getDateFormattedStringInUnits(date: messageDate, allowedUnits: .hour) + " ago"
        default:
            return getDateFormattedStringInMD(date: messageDate)//only month and date
        }
    }
    
    
    private func getDaysBetweenDates(from: Date, to: Date) -> Int{
        
        return Calendar.current.dateComponents([.day], from: from, to: to).day ?? 2
    }
    
    private func getYearsBetweenDates(from: Date, to: Date) -> Int{
        return Calendar.current.dateComponents([.year], from: from, to: to).year ?? 2
    }
    
    private func getDateFormattedStringInUnits(date: Date, allowedUnits: NSCalendar.Unit) -> String{
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = allowedUnits
        formatter.unitsStyle = .abbreviated
        
        let formattedString = formatter.string(from: Date().timeIntervalSince(date))
        
        return formattedString ?? ""
    }
    
    private func getDateFormattedStringInYMD(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        return dateFormatter.string(from: date)
    }
    
    private func getDateFormattedStringInMD(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        return dateFormatter.string(from: date)
    }
    
    private func getDateTimeInterval(date: Date) -> Int{
        return Int(Date().timeIntervalSince(date))
    }
}

