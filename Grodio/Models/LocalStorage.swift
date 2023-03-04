//
//  LocalStorage.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-08-29.
//  Copyright © 2022 USR. All rights reserved.
//

import Foundation


public class LocalStorage: Codable {
    var currentUsername = ""//variable storing current user's name
    var userLogins = [userLogin]()//sorted by most recently used
    var isLocallyAuthenicated = false//flag use to verify if user had authenticated locally with biometrics or passcode
    var isNewSession = true//flag use to verify if the app has been closed after its launch
    
    static let sharedInstance: LocalStorage = {
        var localStorage = LocalStorage()
        
        if let localStorageObject = UserDefaults.standard.data(forKey: DefaultsKeys.localStorageObjectKey) {
            //User object exists, which means this is not the first ever launch
            print("\(#fileID) : \(#function): local storage found!! : ")
            
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode userObject
                localStorage = try decoder.decode(LocalStorage.self, from: localStorageObject)

                } catch {
                    print("\(#fileID) : \(#function): local storafe found!! : Unable to Decode (\(error))")
                }
            
            
        }
        else {
            localStorage = LocalStorage()
            
            do {
                // Create JSON Encoder
                let encoder = JSONEncoder()

                // Encode Note
                let encodedLocalStorage = try encoder.encode(user)

                // Write/Set Data
                UserDefaults.standard.set(encodedLocalStorage, forKey: DefaultsKeys.localStorageObjectKey)
                
                print("\(#fileID) : \(#function): local storage updated!! and added to User Defaults")

            } catch {
                print("\(#fileID) : \(#function): Unable to Encode local storage (\(error))")
            }
            
        }
        
        return localStorage
    }()
    
    struct userLogin: Codable {
        var username:String
        var password:String
        var lastUsed = Date()
    }
    
    public struct groupLogin: Codable {
        var groupname:String
        var pin:String
        var lastUsed = Date()
    }
    
    enum updateTypes: Int, Codable {
        case USER_LOGIN
        case GROUP_LOGIN
        case AUTHENTICATION
        case NEW_SESSION
    }
    
    public func addUserLogin(_username: String, _password: String){
        print("\(#fileID) : \(#function):")
        
        var found = false
        
        for currUserLogin in self.userLogins {
            if currUserLogin.username == _username {
                found = true
            }
        }
        
        if !found{
            self.userLogins.append(userLogin(username: _username, password: _password))
        }
        
        currentUsername = _username
    }
    
    func userSelected(arrayType : updateTypes, index: Int) {
        
        if arrayType == .USER_LOGIN {
            self.userLogins[index].lastUsed = Date()
            currentUsername = self.userLogins[index].username
        }
    }
    
    func updateDataToLocalStorage(updateType: updateTypes){
        print("\(#fileID) : \(#function): ")
        
        if updateType == .USER_LOGIN {
            self.userLogins.sort(by: { $0.lastUsed > $1.lastUsed })
        }
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode Note
            let encodedLocalStorage = try encoder.encode(self)

            // Write/Set Data
            UserDefaults.standard.set(encodedLocalStorage, forKey: DefaultsKeys.localStorageObjectKey)
            
            print("\(#fileID) : \(#function): local storage updated!!")

        } catch {
            print("\(#fileID) : \(#function): Unable to Encode local storage (\(error))")
        }
        
    }
}
