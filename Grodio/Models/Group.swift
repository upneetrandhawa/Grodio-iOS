//
//  Group.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-06-28.
//  Copyright © 2022 USR. All rights reserved.
//

import Foundation

public struct Group: Codable {

    let groupName: String?
    let pin: String?
    
    var songURL: String?
    var songName: String?
    var songStartTime: Int?
    
    var isPlaying: Bool?
    var masterSync: Bool?
    var lastTimeSongPlaybackWasStarted: Date?
    
    var lastMessage: Message?
    
    let creationDate: Date?
    
    var usersCurrentlyJoined: Int? = 0
    var usernamesCurrentlyJoined: [String]?
    
    var createdByUsername: String?

}

