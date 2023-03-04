//
//  DeviceLocalAuthentication.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-08-30.
//  Copyright © 2022 USR. All rights reserved.
//

import UIKit
import LocalAuthentication

class DeviceLocalAuthentication{
    
    var isAuthenticatedLocally = LocalStorage.sharedInstance.isLocallyAuthenicated
    
    static let sharedInstance = DeviceLocalAuthentication()
    
    func authenticate(functionToBeCalledWhenDone: @escaping (Bool) -> Void){
        print("\(#fileID) \(#function)")
        
        //if the user has already been authenticated in the current app session then return true
        if !LocalStorage.sharedInstance.isNewSession && LocalStorage.sharedInstance.isLocallyAuthenicated {
            functionToBeCalledWhenDone(true)
            return
        }
        let context = LAContext()
        
        var error: NSError?

        // Check for biometric authentication
        // permissions
        let permissions = context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        )

        if permissions {
            // Proceed to authentication
            let reason = "Authenticate to skip entering passwords for Groups and Logins"
            
            context.evaluatePolicy(
                // .deviceOwnerAuthentication allows
                // biometric or passcode authentication
                .deviceOwnerAuthentication,
                localizedReason: reason
            ) { success, error in
                self.setAuthenticationFlag(isAuthenticated: success)
                functionToBeCalledWhenDone(success)
            }
        }
        else {
            // Handle permission denied or error
            setAuthenticationFlag(isAuthenticated: false)
            functionToBeCalledWhenDone(false)
        }
        
        
    }
    
    func setAuthenticationFlag(isAuthenticated: Bool){
        print("\(#fileID) \(#function)")
        
        self.isAuthenticatedLocally = isAuthenticated
        
        LocalStorage.sharedInstance.isLocallyAuthenicated = self.isAuthenticatedLocally
        LocalStorage.sharedInstance.updateDataToLocalStorage(updateType: .AUTHENTICATION)
        
    }
    
    func getIsAuthenticatedLocally() -> Bool {
        return LocalStorage.sharedInstance.isLocallyAuthenicated
    }
}
