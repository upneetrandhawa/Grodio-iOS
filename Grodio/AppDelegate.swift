//
//  AppDelegate.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-06-23.
//  Copyright © 2021 USR. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseFirestoreSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //let firebaseDB;
    var window: UIWindow?
    var savedShortCutItem: UIApplicationShortcutItem?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("\(#fileID) \(#function)")
        window = UIWindow()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //try audioSession.setCategory(AVAudioSession.Category.playback)
            //try audioSession.setCategory(.playback)
            try audioSession.setCategory(.playback, options: .mixWithOthers)
            try audioSession.setActive(true)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        FirebaseApp.configure()
        //var firebaseDB = Firestore.firestore()
        
        if let shortCutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            
            
            savedShortCutItem = shortCutItem
        }
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("\(#fileID) \(#function)")
        
        //set our flag for the next app launch
        
        LocalStorage.sharedInstance.isNewSession = true
        LocalStorage.sharedInstance.isLocallyAuthenicated = false
        LocalStorage.sharedInstance.updateDataToLocalStorage(updateType: .NEW_SESSION)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        print("\(#fileID) \(#function): shortCutItem type = \(shortcutItem.type)")
        
        savedShortCutItem = shortcutItem
            
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("\(#fileID) \(#function)")
        
        if let shortCutItem = savedShortCutItem {
            handleShortCutItemPressed(shortCutItem)
        }
    }
    
    func handleShortCutItemPressed(_ shortcutItem: UIApplicationShortcutItem){
        print("\(#fileID) \(#function): shortCutItem type = \(shortcutItem.type)")
        
        switch shortcutItem.type {
        case "QuickAction.CreateGroup":
            let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createGroupView") as UIViewController
            // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
            destViewController.modalTransitionStyle = .flipHorizontal
            DispatchQueue.main.async { [unowned self] in
                self.window?.rootViewController?.present(destViewController, animated: true, completion: nil)
            }
            savedShortCutItem = nil
        case "QuickAction.JoinGroup":
            let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "joinGroupView") as UIViewController
            // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
            destViewController.modalTransitionStyle = .flipHorizontal
            DispatchQueue.main.async { [unowned self] in
                self.window?.rootViewController?.present(destViewController, animated: true, completion: nil)
            }
            savedShortCutItem = nil
        default:
            print("\(#fileID) \(#function): default")
        }
    }


}

