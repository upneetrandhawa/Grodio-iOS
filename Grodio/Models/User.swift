//
//  User.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-06-28.
//  Copyright © 2022 USR. All rights reserved.
//

import Foundation

public struct User: Codable {

    let username: String?
    let password: String?
    let creationDate: Date?
    
    var groupsJoined: [Group]

}
