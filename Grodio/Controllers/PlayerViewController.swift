//
//  PlayerViewController.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-07-01.
//  Copyright © 2021 USR. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Firebase
import FirebaseFirestoreSwift

public var group:Group?

class PlayerViewController: UIViewController , UIDocumentPickerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var groupNameBackgroundContainerView: UIView!
    @IBOutlet weak var groupNameFrontView: UIView!
    
    @IBOutlet weak var speakerTopView: UIView!
    @IBOutlet weak var speakerBottomView: UIView!
    
    @IBOutlet weak var songBackgroundContainerView: UIView!
    @IBOutlet weak var songFrontView: UIView!
    
    @IBOutlet weak var chooseSongFrontView: UIView!
    
    @IBOutlet weak var currentDurationView: UIView!
    @IBOutlet weak var totalDurationView: UIView!
    
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var chooseBroadcastSongButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var seekBackwardButton: UIButton!
    @IBOutlet weak var seekForwardButton: UIButton!
    @IBOutlet weak var masterOutputButton: UIButton!
    @IBOutlet weak var masterSyncButton: UIButton!
    
    @IBOutlet weak var groupNoUsersCurrentlyJoinedLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var songPlayingNameLabel: UILabel!
    @IBOutlet weak var songPlaybackCurrentDuration: UILabel!
    @IBOutlet weak var songPlaybackTotalDuration: UILabel!
    @IBOutlet weak var statusTextView: UITextView!
    
    @IBOutlet weak var chosenSongTextView: UITextView!
    
    @IBOutlet weak var songSlider: UISlider!
    @IBOutlet weak var volumeSlider: UISlider!
    
    let volumeView = MPVolumeView(frame: CGRect.zero)
    
    var audioPlayer: AVPlayer?
    var audioPlayerItem:AVPlayerItem?
    var chosenFileUrl: URL?
    
    var songName:String?
    
    var isMasterOutputEnabled = true
    
    var firebaseDB:Firestore?
    var firebaseDBGroupsRef:CollectionReference?
    var firebaseStorage:Storage?
    var firebaseStorageSongsRef:StorageReference?
    var firestoreGroupDocumentListener:ListenerRegistration?
    
    let seekDuration: Float64 = 15;
    
    var localStorage = LocalStorage.sharedInstance
    
    var songNameLabelMarqueeTimer:Timer? = Timer()//Timer used for marquee , right to left effect for the label
    
    var statusBarStyle = UIStatusBarStyle.default { didSet { setNeedsStatusBarAppearanceUpdate() } }
    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }
    
    var groupChatUnreadMessagesCount = 0 //counter which counts the unread messages in the chat
    
    var isThisViewVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("\(#fileID) \(#function)")
        //set statusbarstyle
        setStatusBarColor(traitCollection: traitCollection)
        
        guard let _ = group else {
            print("\(#fileID) \(#function): group object error")
            addToStatusLabel(str: "error restart app")
            return
        }
        
        initFirebase()
        
        setupViews()
        
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume",
            options: NSKeyValueObservingOptions.new, context: nil)
        
       
        
        
    }    
    
    override func viewDidDisappear(_ animated: Bool) {
        print("\(#fileID) \(#function)")
        firestoreGroupDocumentListener?.remove()
        if songNameLabelMarqueeTimer != nil {
            songNameLabelMarqueeTimer?.invalidate()
            songNameLabelMarqueeTimer = nil
        }
        //incrementOrDecrementUsersCurrentlyJoined(increment: false)
        updateUserSubscriptionToGroup(add: false)
        
        isThisViewVisible = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("\(#fileID) \(#function)")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("\(#fileID) \(#function)")
        
        //reset the counter
        groupChatUnreadMessagesCount = 0
        //update the menu button
        addMenuToMoreButton()
        
        isThisViewVisible = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("\(#fileID) \(#function)")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // handle theme change here.
            print("\(#fileID) : \(#function): ")
            
            
            //set statusbarstyle
            setStatusBarColor(traitCollection: traitCollection)
            
            backgroundView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            groupNameBackgroundContainerView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            groupNameFrontView.addBorder(cornerRadius: 5.0, borderWidth: 5.0, borderColor: UIColor.systemBackground.cgColor)
            
            songBackgroundContainerView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            songFrontView.addBorder(cornerRadius: 10.0, borderWidth: 5.0, borderColor: UIColor.systemBackground.cgColor)
            
            chooseSongFrontView.addBorder(cornerRadius: 7.5, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            chooseBroadcastSongButton.addBorder(cornerRadius: 10.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            closeButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            moreButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            playPauseButton.addBorder(cornerRadius: 25.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            seekForwardButton.addBorder(cornerRadius: 25.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            seekBackwardButton.addBorder(cornerRadius: 25.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            masterSyncButton.addBorder(cornerRadius: 25.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            masterOutputButton.addBorder(cornerRadius: 25.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            currentDurationView.addBorder(cornerRadius: 5.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            totalDurationView.addBorder(cornerRadius: 5.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            chosenSongTextView.addBorder(cornerRadius: 10.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            totalDurationView.addBorder(cornerRadius: 5.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            songSlider.addBorder(cornerRadius: 10.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            volumeSlider.addBorder(cornerRadius: 10.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            groupNameBackgroundContainerView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
            
            groupNameFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
            
            songBackgroundContainerView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
            
            songFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
            
            chooseSongFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
            
            closeButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 4.0), shadowRadius: 1.0)
            
            moreButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 4.0), shadowRadius: 1.0)
            
            playPauseButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
            
            seekBackwardButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
            
            seekForwardButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
            
            masterSyncButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
            
            masterOutputButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
            
            chooseBroadcastSongButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 3.0), shadowRadius: 1.0)
            
            songSlider.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
            
            volumeSlider.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
            
            }
    }
    
    
    func initFirebase(){
        print("\(#fileID) \(#function)")
        
        firebaseDB = Firestore.firestore()
        firebaseDBGroupsRef = firebaseDB?.collection("groups")
        firebaseStorage = Storage.storage()
        firebaseStorageSongsRef = firebaseStorage?.reference().child("songs")
    }
    
    func setupViews(){
        print("\(#fileID) \(#function)")
        
        //set corner radius and borders for our views
        backgroundView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        groupNameBackgroundContainerView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        groupNameFrontView.addBorder(cornerRadius: 5.0, borderWidth: 5.0, borderColor: UIColor.systemBackground.cgColor)
        
        songBackgroundContainerView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        songFrontView.addBorder(cornerRadius: 10.0, borderWidth: 5.0, borderColor: UIColor.systemBackground.cgColor)
        
        chooseSongFrontView.addBorder(cornerRadius: 7.5, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        speakerTopView.addBorder(cornerRadius: 7.0, borderWidth: 5.0, borderColor: UIColor.systemGreen.cgColor)
        
        speakerBottomView.addBorder(cornerRadius: 10.0, borderWidth: 5.0, borderColor: UIColor.systemGreen.cgColor)
        
        chooseBroadcastSongButton.addBorder(cornerRadius: 10.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        closeButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        moreButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        playPauseButton.addBorder(cornerRadius: 25.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        seekForwardButton.addBorder(cornerRadius: 25.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        seekBackwardButton.addBorder(cornerRadius: 25.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        masterSyncButton.addBorder(cornerRadius: 25.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        masterOutputButton.addBorder(cornerRadius: 25.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        currentDurationView.addBorder(cornerRadius: 5.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        totalDurationView.addBorder(cornerRadius: 5.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        chosenSongTextView.addBorder(cornerRadius: 10.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        songSlider.addBorder(cornerRadius: 10.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        volumeSlider.addBorder(cornerRadius: 10.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        //add dots to speakerFrontView
        speakerTopView.addCircleImageToAView(tintColor: UIColor.systemBackground)
        speakerBottomView.addCircleImageToAView(tintColor: UIColor.systemBackground)
        
        //add shadow
        groupNameBackgroundContainerView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
        
        groupNameFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
        
        songBackgroundContainerView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
        
        songFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
        
        chooseSongFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
        
        closeButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 4.0), shadowRadius: 1.0)
        
        moreButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 4.0), shadowRadius: 1.0)
        
        playPauseButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
        
        seekBackwardButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
        
        seekForwardButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
        
        masterSyncButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
        
        masterOutputButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
        
        chooseBroadcastSongButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 3.0), shadowRadius: 1.0)
        
        songSlider.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
        
        volumeSlider.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
        
        //System Volume view
        volumeView.isHidden = false
        volumeView.alpha = 0.01
        self.view.addSubview(volumeView)
        
        chooseBroadcastSongButton.setTitle(ButtonTitles.chooseSong, for: .normal)
        
        startSongNameLabelMarqueeEffect()
        
        updateViewWithFirebaseData(_group: group!)
        
        attachListenerToFirestoreDocumentAndGetUpdates()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            //self.incrementOrDecrementUsersCurrentlyJoined(increment: true)
            self.updateUserSubscriptionToGroup(add: true)
        }
        
        addMenuToMoreButton()
        
    }
    
    func setStatusBarColor(traitCollection: UITraitCollection){
        print("\(#fileID) \(#function)")
        
        switch traitCollection.userInterfaceStyle {
            case .unspecified: statusBarStyle = .default
            case .light: statusBarStyle = .lightContent
            case .dark: statusBarStyle = .darkContent
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        print("\(#fileID) \(#function)")
            if keyPath == "outputVolume" {
                updatePLayerVolumeAndVolumeSlider(AVAudioSession.sharedInstance().outputVolume)
            }
    }
    
    @objc func marqueeEffectForSongNameLabel(){
        
        guard let player = audioPlayer else {
            return
        }
        //if label text char count is 1 then reset it to the original songName
        if let labelText = songPlayingNameLabel.text, labelText.count < 2{
            songPlayingNameLabel.text = group?.songName
            if songNameLabelMarqueeTimer != nil {
                songNameLabelMarqueeTimer?.invalidate()
                songNameLabelMarqueeTimer = nil
            }
            Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.startSongNameLabelMarqueeEffect), userInfo: nil, repeats: false)
            return
        }
        //else remove the first character of the current text in the label and then display the updated string
        let str = songPlayingNameLabel.text!
        let indexSecond = str.index(str.startIndex, offsetBy: 1)
        songPlayingNameLabel.text = String(str.suffix(from: indexSecond))
      }
    
    @objc func startSongNameLabelMarqueeEffect(){
        if songNameLabelMarqueeTimer != nil {
            songNameLabelMarqueeTimer?.invalidate()
            songNameLabelMarqueeTimer = nil
        }
            self.songNameLabelMarqueeTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.marqueeEffectForSongNameLabel), userInfo: nil, repeats: true)
    }
    
    func addMenuToMoreButton(){
        print("\(#fileID) : \(#function): ")
        
        let chatAction = UIAction(title: "Group Chat",
                                       image: UIImage(systemName: "message")?.withTintColor(.systemGreen,
                                       renderingMode: .alwaysOriginal),
                                       discoverabilityTitle: (self.groupChatUnreadMessagesCount == 0) ? nil : String(self.groupChatUnreadMessagesCount) + " unread",
                                       attributes: [],
                                       state: .off,
                                       handler: { (action) -> Void in
                                        print("\(#fileID) : \(#function): chatAction pressed")
                                        self.vibrate(style: .soft)
                                        
                                        let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "groupChatView") as UIViewController
                                        
                                        destViewController.modalTransitionStyle = .coverVertical
                                        self.present(destViewController, animated: true, completion: nil)
                                        
                                        self.groupChatUnreadMessagesCount = 0
                                        self.addMenuToMoreButton()
            
        })
        
        let groupSettingsAction = UIAction(title: "Group Settings",
                                       image: UIImage(systemName: "gearshape")?.withTintColor(.systemGreen,
                                       renderingMode: .alwaysOriginal),
                                       attributes: [],
                                       state: .off,
                                       handler: { (action) -> Void in
                                        print("\(#fileID) : \(#function): groupSettingsAction pressed")
                                        self.vibrate(style: .soft)
                                        
                                        //let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "groupSettingsView") as UIViewController
                                        
                                        //destViewController.modalTransitionStyle = .coverVertical
                                       //self.present(destViewController, animated: true, completion: nil)
            
        })
        
        let elements: [UIAction] = [chatAction]
        
        let menu:UIMenu = UIMenu(title: "Menu", children: elements)
        
        if #available(iOS 14.0, *) {
            moreButton.showsMenuAsPrimaryAction = true
            moreButton.menu = menu
        }
    }
    
    
    func updateViewWithFirebaseData(_group : Group) {
        print("\(#fileID) \(#function)")
        
        group = _group
        
        songName = group?.songName
        
        //update group label
        groupNameLabel.text = group?.groupName?.capitalized
        
        //update
        groupNoUsersCurrentlyJoinedLabel.text = String(group?.usersCurrentlyJoined ?? 0)
        
        //init audioPlayer
        initAudioPlayer((group?.songURL))

        if let playStartTime = group?.songStartTime, let songPlayTime = group?.lastTimeSongPlaybackWasStarted{
            //songSlider.value = Float(playStartTime)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                
                if let play = group?.isPlaying {

                    if play {
                        self.addToStatusLabel(str: "song being broadcasted")
                    }
                    else {
                        if let songUrl = group?.songURL {
                            if songUrl.isEmpty || songUrl == "" {
                                self.addToStatusLabel(str: "choose a song below")
                            }
                            else {
                                self.addToStatusLabel(str: "song selected but broadcasting paused")
                            }
                        }
                    }
                    self.playPauseStateChanged(play)
                }
                self.seekSongToAValue(playStartTime, songPlayTime)
            }
        }
    }
    
    func attachListenerToFirestoreDocumentAndGetUpdates(){
        print("\(#fileID) \(#function)")
        
//        guard let _group = group, let groupName = _group.groupName else {
//            print("\(#fileID) \(#function): error with group object")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
//                self.addToStatusLabel(str: "error getting data, relaunch app")
//            }
//            return
//        }
//
        firestoreGroupDocumentListener =  firebaseDBGroupsRef?.document((group?.groupName)!).addSnapshotListener(includeMetadataChanges: true
            , listener: { (documentSnapshot, error) in
                
                guard let document = documentSnapshot else {
                    print("\(#fileID) \(#function): Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("\(#fileID) \(#function): Document data was empty.")
                    return
                }

                
                if let snapshot = documentSnapshot {
                    do {
                        if let updatedGroup = try snapshot.data(as: Group.self) {
                            print("\(#fileID) \(#function): CUSTOM updatedGroup = \(updatedGroup)")
                            
                            let source = snapshot.metadata.hasPendingWrites ? "Local" : "Server"
                            
                            if source != "Server"{
                                print("\(#fileID) \(#function): Source is \(source) : returning")
                                return
                            }
                            print("\(#fileID) \(#function): \(source) data: \(snapshot.data() ?? [:])")
                            
                            //check if usersCurrentlyJoined has changed
//                            guard let updatedGroupUsersCurrentlyJoined = updatedGroup.usersCurrentlyJoined else {
//                                print("\(#fileID) \(#function): error retrieving data from server : usersCurrentlyJoined")
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
//                                    self.addToStatusLabel(str: "error getting data, relaunch app")
//                                }
//                                return
//                            }
//
//                            if group?.usersCurrentlyJoined != updatedGroupUsersCurrentlyJoined {
//                                print("\(#fileID) \(#function): usersCurrentlyJoined changed")
//                                DispatchQueue.main.asyncAfter(deadline: .now()){
//                                    self.usersCurrentlyJoinedChanged(newValue: updatedGroupUsersCurrentlyJoined)
//                                }
//                            }
                            
                            //check if usersCurrentlyJoinedusernamesCurrentlyJoinedhas changed
                            guard let updatedGroupUsernamesCurrentlyJoined = updatedGroup.usernamesCurrentlyJoined else {
                                print("\(#fileID) \(#function): error retrieving data from server : usernamesCurrentlyJoined")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                    self.addToStatusLabel(str: "error getting data, relaunch app")
                                }
                                return
                            }
                            
                            if group?.usernamesCurrentlyJoined != updatedGroupUsernamesCurrentlyJoined {
                                print("\(#fileID) \(#function): usernamesCurrentlyJoined changed")
                                DispatchQueue.main.asyncAfter(deadline: .now()){
                                    self.usernamesCurrentlyJoinedChanged(newArray: updatedGroupUsernamesCurrentlyJoined)
                                }
                            }
                            
                            //check if songURL is changed
                            if group?.songURL != updatedGroup.songURL{
                                print("\(#fileID) \(#function): songURL changed")
                                DispatchQueue.main.asyncAfter(deadline: .now()){
                                    self.addToStatusLabel(str: "broadcasting song changed")
                                    self.updateViewWithFirebaseData(_group: updatedGroup)
                                }
                                return
                            }
                            
                            //check if masterSync is changed
                            guard let updatedGroupMasterSync = updatedGroup.masterSync else {
                                print("\(#fileID) \(#function): error retrieving data from server : masterSync")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                    self.addToStatusLabel(str: "error getting data, relaunch app")
                                }
                                return
                            }
                            if group?.masterSync != updatedGroupMasterSync{
                                print("\(#fileID) \(#function): masterSync changed")
                                DispatchQueue.main.asyncAfter(deadline: .now()){
                                    self.masterSyncChanged(updatedGroupMasterSync)
                                }
                            }
                            
                            //check if isPlaying is changed
                            guard let updatedGroupIsPlaying = updatedGroup.isPlaying else {
                                print("\(#fileID) \(#function): error retrieving data from server : isPlaying")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                    self.addToStatusLabel(str: "error getting data, relaunch app")
                                }
                                return
                            }
                            var isPlayingChanged = true
                            if group?.isPlaying != updatedGroupIsPlaying{
                                print("\(#fileID) \(#function): isPlaying changed")
                                
                                DispatchQueue.main.asyncAfter(deadline: .now()){
                                    if updatedGroupIsPlaying {
                                        self.addToStatusLabel(str: "broadcast was resumed")
                                    }
                                    else{
                                        self.addToStatusLabel(str: "broadcast was paused")
                                    }
                                    self.playPauseStateChanged(updatedGroupIsPlaying)
                                    group?.isPlaying = updatedGroupIsPlaying
                                }
                            }
                            else {
                                isPlayingChanged = false
                            }
                            
                            //check if lastTimeSongPlaybackWasStarted is changed
                            guard let updatedGroupLastTimeSongPlaybackWasStarted = updatedGroup.lastTimeSongPlaybackWasStarted else {
                                print("\(#fileID) \(#function): error retrieving data from server : lastTimeSongPlaybackWasStarted")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                    self.addToStatusLabel(str: "error getting data, relaunch app")
                                }
                                return
                            }
                            
                            if group?.lastTimeSongPlaybackWasStarted != updatedGroupLastTimeSongPlaybackWasStarted && group?.songURL != "" {
                                print("\(#fileID) \(#function): lastTimeSongPlaybackWasStarted changed")
                                
                                guard let updatedGroupStartTime:Int = updatedGroup.songStartTime else {
                                    print("\(#fileID) \(#function): error retrieving data from server : songStartTime")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                        self.addToStatusLabel(str: "error getting data, relaunch app")
                                    }
                                    return
                                }
                                
                                self.seekSongToAValue(updatedGroupStartTime, updatedGroupLastTimeSongPlaybackWasStarted)
                                
                                if !isPlayingChanged && updatedGroupLastTimeSongPlaybackWasStarted != group?.creationDate{
                                    if let oldSongStartTime = group?.songStartTime {
                                        if updatedGroupStartTime < oldSongStartTime {
                                            print("\(#fileID) \(#function): broadcast was sought backward")
                                            self.addToStatusLabel(str: "broadcast was sought backward")
                                        }
                                        else {
                                            print("\(#fileID) \(#function): broadcast was sought forward")
                                            self.addToStatusLabel(str: "broadcast was sought forward")
                                        }
                                    }
                                }
                                group?.songStartTime = updatedGroupStartTime
                                group?.lastTimeSongPlaybackWasStarted = updatedGroupLastTimeSongPlaybackWasStarted
                            }
                            
                            //check if lastMessage has changed
                            if let updatedGrouplastMessage = updatedGroup.lastMessage {
//                                print("\(#fileID) \(#function): error retrieving data from server : lastMessage")
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
//                                    self.addToStatusLabel(str: "error getting data, relaunch app")
//                                }
//                                return
                                
                                if let localLastMessage = group?.lastMessage {
                                    if !localLastMessage.equals(compareTo: updatedGrouplastMessage) {
                                        print("\(#fileID) \(#function): lastMessage changed")
                                        
                                        if updatedGrouplastMessage.senderUsername != user?.username && self.isThisViewVisible{//if the msg sent isnt from the current user
//                                          //show the badge of the more button
                                            
                                            // modify badge value of chat
                                            self.groupChatUnreadMessagesCount += 1
                                            
                                            //update menu of the more button with the unread chat messages
                                            self.addMenuToMoreButton()
                                        }
                                    }
                                }
                            }
                            
                        }
                    } catch let error as NSError {
                        print("\(#fileID) \(#function): error: \(error.localizedDescription)")
                    }
                }
                else {
                    print("\(#fileID) \(#function): snapshot doesnt exist")
                }
            })
    }
    
    @IBAction func chooseBroadcastSongButtonPressed(_ sender: UIButton) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
        //incrementOrDecrementUsersCurrentlyJoined(increment: true)
        //return
        
        if sender.title(for: .normal) == ButtonTitles.broadcastSong {
            broadcastSongButtonPressed(self)
            
            return
        }
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("\(#fileID) \(#function)")
        
        let fileURL = urls[0]
        
        if let oldFileURL = chosenFileUrl {
            if oldFileURL == fileURL {//same as the one being played
                addToStatusLabel(str: "song already being broadcasted")
                chooseBroadcastSongButton.setTitle(ButtonTitles.chooseSong, for: .normal)
                return
            }
        }
        chosenFileUrl = fileURL
        
        chosenSongTextView.text = fileURL.lastPathComponent
        
        chooseBroadcastSongButton.setTitle(ButtonTitles.broadcastSong, for: .normal)
        
        print("\(#fileID) \(#function): file type = \(fileURL.pathExtension)")
        
        addToStatusLabel(str: "you chose " + fileURL.lastPathComponent)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            self.addToStatusLabel(str: "press Broadcast song to broadcast")
        }
    }
    
    func initAudioPlayer(_ urlString:String?){
        print("\(#fileID) \(#function): url = \(String(describing: urlString))")
        
        guard let _ = urlString else {
            print("\(#fileID) \(#function): urlString error")
            return
        }
        
        let urlFromString = URL(string: urlString!)
        
        guard let url = urlFromString else {
            print("\(#fileID) \(#function): urlFromString error")
            return
        }
        
        addToStatusLabel(str: "beginning stream")
        
        audioPlayerItem = AVPlayerItem(url: url)
        
        if let _ = audioPlayer?.currentItem {
            print("\(#fileID) \(#function): replacing playing item")
            //playPauseButtonPressed(self)
            audioPlayer?.replaceCurrentItem(with: audioPlayerItem)
        }
        else {
            print("\(#fileID) \(#function): first init with a playing item")
            audioPlayer = AVPlayer(playerItem: audioPlayerItem)
        }
        
        if let player = audioPlayer {
            
            let songDurationInSeconds: Float64 = CMTimeGetSeconds((player.currentItem?.asset.duration)!)
            
            player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
                if player.currentItem?.status == .readyToPlay {
                    
                    let currentPlaybackTime = CMTimeGetSeconds(player.currentTime())
                    let songDurationLeft = songDurationInSeconds - currentPlaybackTime
                    
                    if !self.songSlider.isTracking {
                        //print("\(#fileID) \(#function): slider tracking = \(self.songSlider.isHighlighted), updating slider")
                        self.songSlider.setValue(Float(currentPlaybackTime), animated: false)
                    }
                    self.songPlaybackCurrentDuration.text = self.getTimeIntervalFromSeconds(seconds: Float64(currentPlaybackTime))
                    self.songPlaybackTotalDuration.text = "-" + self.getTimeIntervalFromSeconds(seconds: Float64(songDurationLeft))
                    
                    
                }
            })
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerFinishedPlayingSong(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayerItem)
            
            // Get the default notification center instance.
            NotificationCenter.default.addObserver(self,
                               selector: #selector(handleAudioSessionInterruption),
                               name: AVAudioSession.interruptionNotification,
                               object: AVAudioSession.sharedInstance())
            
            setupAudioPlaybackControlsAndMetadata()
            
            setupRemoteTransportControls()
            
            setupInfoCenterMetadata()
            
            self.vibrate(style: .soft)
            
            addToStatusLabel(str: "broadcast ready")
        }
        else {
            self.vibrate(style: .heavy)
            addToStatusLabel(str: "audio player error")
        }
        
        
    }
    
    func setupAudioPlaybackControlsAndMetadata(){
        print("\(#fileID) \(#function)")
        
        if let player = audioPlayer {
            
            songPlayingNameLabel.text = group?.songName
            
            //enable sliders
            songSlider.isEnabled = true
            volumeSlider.isEnabled = true
            
            //enable buttons
            seekBackwardButton.isEnabled = true
            seekForwardButton.isEnabled = true
            playPauseButton.isEnabled = true
            masterOutputButton.isEnabled = true
            masterSyncButton.isEnabled = true
            
            updatePLayerVolumeAndVolumeSlider(AVAudioSession.sharedInstance().outputVolume)
            
            let songDurationInSeconds: Float64 = CMTimeGetSeconds((audioPlayerItem?.asset.duration)!)
            let currentPlaybackTime: Float64 = CMTimeGetSeconds(player.currentTime())
            
            songPlaybackCurrentDuration.text = getTimeIntervalFromSeconds(seconds: currentPlaybackTime)
            songPlaybackTotalDuration.text = getTimeIntervalFromSeconds(seconds: songDurationInSeconds)
            
            songSlider.value = 0
            songSlider.maximumValue = Float(songDurationInSeconds)
            
            playPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
            
        }
    }
    
    func setupRemoteTransportControls() {
        print("\(#fileID) \(#function)")
        
        if let _ = audioPlayer {
            // Get the shared MPRemoteCommandCenter
            let commandCenter = MPRemoteCommandCenter.shared()
            
            commandCenter.playCommand.isEnabled = true
            commandCenter.pauseCommand.isEnabled = true
            commandCenter.skipForwardCommand.isEnabled = true
            commandCenter.skipForwardCommand.preferredIntervals = [15]
            commandCenter.skipBackwardCommand.isEnabled = true
            commandCenter.skipBackwardCommand.preferredIntervals = [15]
            commandCenter.changePlaybackPositionCommand.isEnabled = true
            
            // Add handler for Play Command
            commandCenter.playCommand.addTarget { [unowned self] event in
                print("\(#fileID) \(#function): playCommand")
                self.playPauseButtonPressed(self)
                return .success
            }
            
            // Add handler for Pause Command
            commandCenter.pauseCommand.addTarget { [unowned self] event in
                print("\(#fileID) \(#function): pauseCommand")
                self.playPauseButtonPressed(self)
                return .success
            }
            
            // Add handler for seek Forward Command
            commandCenter.skipForwardCommand.addTarget { [unowned self] event in
                print("\(#fileID) \(#function): skipForwardCommand")
                self.seekForwardButtonPressed(self)
                return .success
            }
            
            // Add handler for seek Backward Command
            commandCenter.skipBackwardCommand.addTarget { [unowned self] event in
                print("\(#fileID) \(#function): skipBackwardCommand")
                self.seekBackwardButtonPressed(self)
                return .success
            }
            
            // Add handler for change Playback Position Command
            commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
                print("\(#fileID) \(#function): changePlaybackPositionCommand")
                let seconds = (event as? MPChangePlaybackPositionCommandEvent)?.positionTime ?? 0
                
                if let _ = audioPlayer {
                    firebaseDBGroupsRef?.document((group?.groupName)!).updateData([
                        "songStartTime": Int(seconds),
                        "lastTimeSongPlaybackWasStarted": FieldValue.serverTimestamp()
                    ], completion: { (error) in
                        if let err = error {
                                print("\(#fileID) \(#function): Error updating data = \(err)")
                            } else {
                                print("\(#fileID) \(#function): Document successfully written!")
                            }
                    })
                }
                
                return .success
            }
        }
    }
    
    func setupInfoCenterMetadata(){
        print("\(#fileID) \(#function)")
        let songInfo: [String: Any] = [
            MPMediaItemPropertyTitle: group?.songName ?? "Song Name",
            MPMediaItemPropertyArtist: group?.songName ?? "Song Name",
            MPNowPlayingInfoPropertyElapsedPlaybackTime: 0,
            MPNowPlayingInfoPropertyPlaybackRate: 0,
            MPMediaItemPropertyPlaybackDuration: audioPlayer?.currentItem?.asset.duration.seconds ?? .zero,
        ]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
    }
    
    func incrementOrDecrementUsersCurrentlyJoined(increment: Bool) {
        
        guard let groupName = group?.groupName, let currUserJoined = group?.usersCurrentlyJoined else {
            return
        }
        print("\(#fileID) \(#function): groupName = ", groupName, ", currUserJoined = ", currUserJoined)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.firebaseDBGroupsRef?.document(groupName).updateData([
                "usersCurrentlyJoined": (increment) ? FieldValue.increment(Int64(1)) : FieldValue.increment(Int64(-1))
            ], completion: { (error) in
                if let err = error {
                        print("\(#fileID) \(#function): Error updating data = \(err)")
                    } else {
                        print("\(#fileID) \(#function): Document successfully written!")
                    }
            })
        }
        
    }
    
    func updateUserSubscriptionToGroup(add: Bool) {//true for add and false for delete
        print("\(#fileID) \(#function): add = \(add)")
        
        guard let groupName = group?.groupName, let currUserJoined = group?.usersCurrentlyJoined, let username = user?.username, let usernamesCurrentlyJoined = group?.usernamesCurrentlyJoined else {
            return
        }
        print("\(#fileID) \(#function): groupName = ", groupName, ", currUserJoined = ", currUserJoined)
        
        
        
        if add {
            var updatedUsernamesCurrentlyJoined: [String] = usernamesCurrentlyJoined
            updatedUsernamesCurrentlyJoined.append(username)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.firebaseDBGroupsRef?.document(groupName).updateData([
                    "usersCurrentlyJoined": FieldValue.increment(Int64(1)),
                    "usernamesCurrentlyJoined": updatedUsernamesCurrentlyJoined
                ], completion: { (error) in
                    if let err = error {
                            print("\(#fileID) \(#function): Error updating data = \(err)")
                        } else {
                            print("\(#fileID) \(#function): Document successfully written!")
                        }
                })
            }
        }
        else {
            
            DispatchQueue.global(qos: .userInteractive).async {
                var updatedUsernamesCurrentlyJoined: [String] = usernamesCurrentlyJoined
                updatedUsernamesCurrentlyJoined = updatedUsernamesCurrentlyJoined.filter {$0 != username}
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.firebaseDBGroupsRef?.document(groupName).updateData([
                        "usersCurrentlyJoined": FieldValue.increment(Int64(-1)),
                        "usernamesCurrentlyJoined": updatedUsernamesCurrentlyJoined
                    ], completion: { (error) in
                        if let err = error {
                                print("\(#fileID) \(#function): Error updating data = \(err)")
                            } else {
                                print("\(#fileID) \(#function): Document successfully written!")
                            }
                    })
                }
                
            }
            
        }
        
        
        
    }
    
    func usersCurrentlyJoinedChanged(newValue: Int) {
        print("\(#fileID) \(#function): newValue = \(newValue)")
        
        group?.usersCurrentlyJoined = newValue
        
        //set animations to groupNoUsersCurrentlyJoinedLabel when value is updated
        let animation: CATransition = CATransition()
        animation.duration = 0.8
        animation.type = CATransitionType.fade
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        groupNoUsersCurrentlyJoinedLabel.layer.add(animation, forKey: "changeTextTransition")
        
        
        groupNoUsersCurrentlyJoinedLabel.text = String(newValue)
    }
    
    func usernamesCurrentlyJoinedChanged(newArray: [String]) {
        print("\(#fileID) \(#function): newArray count = \(newArray.count)")
        
        if newArray.count > group?.usernamesCurrentlyJoined?.count ?? 0 {
            
            let newUsersJoinedCount = newArray.count - (group?.usernamesCurrentlyJoined?.count ?? 0)
            let newJoinedUsernames: [String] = Array(newArray[(newArray.count - newUsersJoinedCount) ..< newArray.count ])
            
            print("\(#fileID) \(#function): newUsersUsernames = \(newJoinedUsernames)")
            
            for username in newJoinedUsernames {
                print("\(#fileID) \(#function): username = \(username)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.addToStatusLabel(str: username + " joined in")
                }
                
            }
        }
        
        group?.usernamesCurrentlyJoined = newArray
        
        //set usersCurrentlyJoined
        let newValue = newArray.count
        group?.usersCurrentlyJoined = newValue
        
        //set animations to groupNoUsersCurrentlyJoinedLabel when value is updated
        let animation: CATransition = CATransition()
        animation.duration = 0.8
        animation.type = CATransitionType.fade
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        groupNoUsersCurrentlyJoinedLabel.layer.add(animation, forKey: "changeTextTransition")
        
        
        groupNoUsersCurrentlyJoinedLabel.text = String(newValue)
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
        if let player = audioPlayer {
            
            print("\(#fileID) \(#function): player rate = \(player.rate)")
            
            firebaseDBGroupsRef?.document((group?.groupName)!).updateData([
                "isPlaying": (Int(player.rate) == 1) ? false : true,
                "songStartTime": Int(CMTimeGetSeconds(player.currentTime())),
                "lastTimeSongPlaybackWasStarted": FieldValue.serverTimestamp()
            ], completion: { (error) in
                if let err = error {
                        print("\(#fileID) \(#function): Error updating data = \(err)")
                    } else {
                        print("\(#fileID) \(#function): Document successfully written!")
                    }
            })
        }
    }
    
    func playPauseStateChanged(_ playerToBePlayed: Bool) {
        print("\(#fileID) \(#function): playerToBePlayed = \(playerToBePlayed)")
        
        if let player = audioPlayer {
            
            if playerToBePlayed {
                player.play()
                playPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
                
                let songInfo: [String: Any] = [
                    MPMediaItemPropertyTitle: group?.songName ?? "Song Name",
                    MPMediaItemPropertyArtist: group?.songName ?? "Song Name",
                    MPNowPlayingInfoPropertyElapsedPlaybackTime: CMTimeGetSeconds(player.currentTime()),
                    MPNowPlayingInfoPropertyPlaybackRate: 1,
                    MPMediaItemPropertyPlaybackDuration: audioPlayer?.currentItem?.asset.duration.seconds ?? .zero,
                ]
                MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
            }
            else {
                player.pause()
                playPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
                let songInfo: [String: Any] = [
                    MPMediaItemPropertyTitle: group?.songName ?? "Song Name",
                    MPMediaItemPropertyArtist: group?.songName ?? "Song Name",
                    MPNowPlayingInfoPropertyElapsedPlaybackTime: CMTimeGetSeconds(player.currentTime()),
                    MPNowPlayingInfoPropertyPlaybackRate: 1,
                    MPMediaItemPropertyPlaybackDuration: audioPlayer?.currentItem?.asset.duration.seconds ?? .zero,
                ]
                MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
            }
        }
    }
    
    @IBAction func seekBackwardButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
        if let player = audioPlayer{
            let songCurrentPlaybackTime = CMTimeGetSeconds(player.currentTime())
            
            let newPlaybackTime =  songCurrentPlaybackTime - seekDuration < 0 ? 0 : songCurrentPlaybackTime - seekDuration
            
            firebaseDBGroupsRef?.document((group?.groupName)!).updateData([
                "songStartTime": Int(newPlaybackTime),
                "lastTimeSongPlaybackWasStarted": FieldValue.serverTimestamp()
            ], completion: { (error) in
                if let err = error {
                        print("\(#fileID) \(#function): Error updating data = \(err)")
                    } else {
                        print("\(#fileID) \(#function): Document successfully written!")
                    }
            })
        }
    }
    
    @IBAction func seekForwardButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
        if let player = audioPlayer{
            let songCurrentPlaybackTime = CMTimeGetSeconds(player.currentTime())
            let songDurationInSeconds: Float64 = CMTimeGetSeconds((player.currentItem?.asset.duration)!)
            
            let newPlaybackTime = songCurrentPlaybackTime + seekDuration > songDurationInSeconds ? songDurationInSeconds : songCurrentPlaybackTime + seekDuration
            
            firebaseDBGroupsRef?.document((group?.groupName)!).updateData([
                "songStartTime": Int(newPlaybackTime),
                "lastTimeSongPlaybackWasStarted": FieldValue.serverTimestamp()
            ], completion: { (error) in
                if let err = error {
                        print("\(#fileID) \(#function): Error updating data = \(err)")
                    } else {
                        print("\(#fileID) \(#function): Document successfully written!")
                    }
            })
        }
    }
    
    func seekSongToAValue(_ seconds: Int, _ timeSeekWasRequested: Date) {
        print("\(#fileID) \(#function): seconds = \(seconds)")
        
        //calculate seek val
        let secondsDiff:Int? = Calendar.current.dateComponents([.second], from: timeSeekWasRequested, to: Timestamp.init().dateValue()).second ?? 0
        
        print("\(#fileID) \(#function): secondsDiff = \(String(describing: secondsDiff))")
        
        let seekValue = secondsDiff! + seconds
        
        print("\(#fileID) \(#function): seekValue = \(seekValue)")
        
        if let player = audioPlayer {
            
            player.seek(to: CMTimeMake(value: Int64(seekValue), timescale: 1))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let songInfo: [String: Any] = [
                    MPMediaItemPropertyTitle: group?.songName ?? "Song Name",
                    MPMediaItemPropertyArtist: group?.songName ?? "Song Name",
                    MPNowPlayingInfoPropertyElapsedPlaybackTime: CMTimeGetSeconds(player.currentTime()),
                    MPNowPlayingInfoPropertyPlaybackRate: 1,
                    MPMediaItemPropertyPlaybackDuration: self.audioPlayer?.currentItem?.asset.duration.seconds ?? .zero,
                ]
                MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
            }
        }
    }
    
    @objc func playerFinishedPlayingSong( _ myNotification:NSNotification){
        print("\(#fileID) \(#function)")
        if let _ = audioPlayer {
            
            firebaseDBGroupsRef?.document((group?.groupName)!).updateData([
                "isPlaying": false,
                "songStartTime": 0,
                "lastTimeSongPlaybackWasStarted": FieldValue.serverTimestamp()
            ], completion: { (error) in
                if let err = error {
                        print("\(#fileID) \(#function): Error updating data = \(err)")
                    } else {
                        print("\(#fileID) \(#function): Document successfully written!")
                        
                        self.addToStatusLabel(str: "broadcast finished")
                        self.addToStatusLabel(str: "press play or choose another song")
                    }
            })
        }
    }
    
    @objc func handleAudioSessionInterruption(notification: Notification) {
        print("\(#fileID) \(#function)")
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }

        // Switch over the interruption type.
        switch type {

        case .began:
            // An interruption began. Update the UI as necessary.
            print("\(#fileID) \(#function): began")
            
            self.closeButtonPressed(self)

        case .ended:
           // An interruption ended. Resume playback, if appropriate.
            print("\(#fileID) \(#function): ended")
            
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // An interruption ended. Resume playback.
                print("\(#fileID) \(#function): ended shouldResume")
                
            } else {
                // An interruption ended. Don't resume playback.
            }

        default: ()
        }
    }

    @IBAction func songSliderValueChanged(_ sender: Any) {
        print("\(#fileID) \(#function): value = \(Int(songSlider.value))")
        
        self.vibrate(style: .soft)
        
        if audioPlayer != nil {
            
            firebaseDBGroupsRef?.document((group?.groupName)!).updateData([
                "songStartTime": Int(songSlider.value),
                "lastTimeSongPlaybackWasStarted": FieldValue.serverTimestamp()
            ], completion: { (error) in
                if let err = error {
                        print("\(#fileID) \(#function): Error updating data = \(err)")
                    } else {
                        print("\(#fileID) \(#function): Document successfully written!")
                    }
            })
        }
    }
    
    
    
    @IBAction func volumeSliderValueChanged(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
        setSystemValue(volumeSlider.value)
    }
    
    func setSystemValue(_ value:Float){
        print("\(#fileID) \(#function): value = \(value)")
        (volumeView.subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(value, animated: false)
    }
    
    @objc func systemVolumeChanged(_ notification: NSNotification){
        print("\(#fileID) \(#function)")
        
        if let volume = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
            updatePLayerVolumeAndVolumeSlider(volume)
        }
    }
    
    func updatePLayerVolumeAndVolumeSlider(_ value:Float){
        print("\(#fileID) \(#function): value = \(value)")
        
        if let player = audioPlayer {
            player.volume = value
            volumeSlider.value = value
            
            if value == volumeSlider.minimumValue {
                volumeSlider.minimumValueImage = UIImage(systemName: "speaker.slash")
            }
            else if value == volumeSlider.maximumValue{
                volumeSlider.minimumValueImage = UIImage(systemName: "speaker.3")
            }
            else if value >= ((volumeSlider.maximumValue - volumeSlider.minimumValue)*2/3){
                volumeSlider.minimumValueImage = UIImage(systemName: "speaker.2")
            }
            else if value <= ((volumeSlider.maximumValue - volumeSlider.minimumValue)*1/3){
                volumeSlider.minimumValueImage = UIImage(systemName: "speaker")
            }
            else {
                volumeSlider.minimumValueImage = UIImage(systemName: "speaker.1")
            }
        }
    }
    
    func broadcastSongButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        if let _ = chosenFileUrl {
            chooseBroadcastSongButton.setTitle(ButtonTitles.chooseSong, for: .normal)
            
            //statusLabel.text = "broadcasting song"
            
            addToStatusLabel(str: "broadcasting song")
            
            chosenSongTextView.text = " choose a song"
            
            uploadSongToFirebaseStorage()
        }
        
    }
    
    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
        if let player = audioPlayer {
            player.replaceCurrentItem(with: nil)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moreButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)

        let message = NSLocalizedString("Menu", comment: "Choose")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alert.view.tintColor = .systemGreen

        alert.addAction(UIAlertAction(title: "Group Chat", style: .default) { [unowned self] _ in
            //group = nil

            let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "groupChatView") as UIViewController

            destViewController.modalTransitionStyle = .coverVertical
            self.present(destViewController, animated: true, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

//        alert.addAction(UIAlertAction(title: "Group Settings", style: .default) { [unowned self] _ in
//
//            let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "groupSettingsView") as UIViewController
//
//            destViewController.modalTransitionStyle = .coverVertical
//            self.present(destViewController, animated: true, completion: nil)
//        })

        //alert.popoverPresentationController?.barButtonItem = sender as! UIBarButtonItem

        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func masterOutputButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function): isMasterOutputEnabled = \(isMasterOutputEnabled)")
        
        self.vibrate(style: .soft)
        
        if let player = audioPlayer {
            
            isMasterOutputEnabled = !isMasterOutputEnabled
            
            let value = isMasterOutputEnabled
            
            print("\(#fileID) \(#function): new isMasterOutputEnabled = \(isMasterOutputEnabled)")
            
            player.volume = value ? volumeSlider.value : 0
            
            songSlider.isEnabled = value
            volumeSlider.isEnabled = value
            seekBackwardButton.isEnabled = value
            seekForwardButton.isEnabled = value
            playPauseButton.isEnabled = value
            chooseBroadcastSongButton.isEnabled = value
            
            songSlider.alpha = value ? 1 : 0.5
            volumeSlider.alpha = value ? 1 : 0.5
            seekBackwardButton.alpha = value ? 1 : 0.5
            seekForwardButton.alpha = value ? 1 : 0.5
            playPauseButton.alpha = value ? 1 : 0.5
            chooseBroadcastSongButton.alpha = value ? 1 : 0.5
            
            if let masterSyncOn = group?.masterSync {
                if !masterSyncOn {
                    masterSyncButton.isEnabled = value
                    masterSyncButton.alpha = value ? 1 : 0.5
                }
            }
            
            masterOutputButton.tintColor = value ? .systemGreen : .systemRed
            
            print("\(#fileID) \(#function): DONEEEEEE")
            
            let status = value ? "master output enabled" : "master output disabled"
            addToStatusLabel(str: status)
        }
    }
    
    
    
    func masterSyncChanged(_ on:Bool){
        print("\(#fileID) \(#function): on = \(on)")
        
        if on {
            print("\(#fileID) \(#function): on")
            masterSyncButton.rotate()
            addToStatusLabel(str: "master sync initiated")
            group?.masterSync = true
            isMasterOutputEnabled = true
            masterOutputButtonPressed(self)
        }
        else {
            print("\(#fileID) \(#function): off")
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isMasterOutputEnabled = false
                self.masterOutputButtonPressed(self)
                group?.masterSync = false
                self.addToStatusLabel(str: "master sync finished")
                self.masterSyncButton.stopRotating()
            }
        }
    }
    
    @IBAction func masterSyncButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
        if let player = audioPlayer {
            
            if Int(player.rate) != 1 {
                addToStatusLabel(str: "master sync finished")
                return
            }
            
            //send sync on update
            print("\(#fileID) \(#function): setting masterSync true")
            firebaseDBGroupsRef?.document((group?.groupName)!).updateData([
                "masterSync": true,
                "isPlaying": (Int(player.rate) == 1) ? false : true,
                "songStartTime": Int(CMTimeGetSeconds(player.currentTime())),
                "lastTimeSongPlaybackWasStarted": FieldValue.serverTimestamp()
            ], completion: { (error) in
                if let err = error {
                    print("\(#fileID) \(#function): Error updating data = \(err)")
                } else {
                    print("\(#fileID) \(#function): Document successfully written!: masterSync set true")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        //send sync off update
                        print("\(#fileID) \(#function): setting masterSync false 1")
                        self.firebaseDBGroupsRef?.document((group?.groupName)!).updateData([
                            "masterSync": false,
                            "isPlaying": (Int(player.rate) == 1) ? false : true,
                            "songStartTime": Int(CMTimeGetSeconds(player.currentTime())),
                            "lastTimeSongPlaybackWasStarted": FieldValue.serverTimestamp()
                        ], completion: { (error) in
                            if let err = error {
                                print("\(#fileID) \(#function): Error updating data = \(err)")
                            } else {
                                print("\(#fileID) \(#function): Document successfully written!: masterSync set false 1")
                            }
                        })
                    }
                }
            })
        }
    }
    
    func getTimeIntervalFromSeconds(seconds: Float64) -> String {
        //print("getTimeIntervalFromSeconds()")
        
        let interval = Int(seconds)
        let s = interval % 60
        let m = (interval / 60) % 60
        let h = (interval / 3600)
        
        if interval > 3600 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }
    
    func uploadSongToFirebaseStorage(){
        
        print("\(#fileID) \(#function)")
        
        addToStatusLabel(str: "uploading song...")
        
        var metadata = StorageMetadata()
        
        switch chosenFileUrl?.pathExtension {
        case "mp3":
            metadata.contentType = "audio/mp3"
        case "m4a":
            metadata.contentType = "audio/m4a"
        case "wav":
            metadata.contentType = "audio/wav"
        case "aac":
            metadata.contentType = "audio/aac"
        case "flac":
            metadata.contentType = "audio/flac"
        default:
            metadata.contentType = "audio/mpeg"
        }
        
        print("\(#fileID) \(#function): audio format = \(String(describing: chosenFileUrl?.pathExtension))")
        print("\(#fileID) \(#function): firebase metadata = \(String(describing: metadata.contentType))")
        
        let songNameToBeUploaded:String = self.chosenFileUrl?.lastPathComponent.components(separatedBy: ".")[0] ?? ""
        
        let songRef = firebaseStorageSongsRef?.child(group?.groupName ?? "generic").child(songNameToBeUploaded)
        
        print("\(#fileID) \(#function): firebase song ref = \(String(describing: songRef?.fullPath))")
        
        let uploadTask = songRef?.putFile(from: chosenFileUrl!, metadata: metadata, completion: { metadata, error in
            
            if let err = error {
                print("\(#fileID) \(#function): uploadTask: error = \(err.localizedDescription)")
                self.addToStatusLabel(str: "error uploading song")
            }
            
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print("\(#fileID) \(#function): uploadTask: metadata error")
                self.addToStatusLabel(str: "error uploading song")
                return
              }
               // You can also access to download URL after upload.
            songRef?.downloadURL { (url, error) in
                guard let downloadURL = url else {
                  // Uh-oh, an error occurred!
                    print("\(#fileID) \(#function): uploadTask: downloadUrl error")
                    self.addToStatusLabel(str: "error uploading song")
                  return
                }
                print("\(#fileID) \(#function): uploadTask: downloadUrl = \(downloadURL.absoluteString)")
                
                self.deleteFileFromFirebaseStorage(group?.songName ?? "")
                
                self.firebaseDBGroupsRef?.document((group?.groupName)!).updateData([
                    "songURL": downloadURL.absoluteString,
                    "songName": songNameToBeUploaded,
                    "songStartTime": 0,
                    "lastTimeSongPlaybackWasStarted": FieldValue.serverTimestamp()
                ], completion: { (error) in
                    if let err = error {
                            print("\(#fileID) \(#function): Error updating data = \(err)")
                        } else {
                            print("\(#fileID) \(#function): Document successfully written!")
                            self.addToStatusLabel(str: "upload done")
                        }
                })
              }
        })
        // Add a progress observer to an upload task
        let observer = uploadTask?.observe(.progress) { snapshot in
          // A progress event occured
            
            
            if let fractionCompleted = snapshot.progress?.fractionCompleted {
                
                print("\(#fileID) \(#function): uploadTask progress : \(fractionCompleted)")
                
                let completion = Double(round(1000*(Double(fractionCompleted)*100))/1000)
                
                self.addToStatusLabel(str: "upload completed : \(completion)%")
                
            }
        }
        
        
    }
    
    func addToStatusLabel(str: String){
        print("\(#fileID) \(#function): str = \(str)")
        
        guard let text = self.statusTextView.text else {
            print("\(#fileID) \(#function): str = \(str), returning")
            return
        }
        
        if let masterSyncOn = group?.masterSync {
            if masterSyncOn == true{
                return
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            if text == "" {
                self.statusTextView.text = str            }
            else {
                self.statusTextView.text = text + "\n" + str            }
            
            self.statusTextView.scrollRangeToVisible(NSMakeRange(self.statusTextView.text.count - 1,1))
            
            self.vibrate(style: .soft)
        }
        
    }
    
    func deleteFileFromFirebaseStorage(_ name:String) {
        print("\(#fileID) \(#function): name = \(name)")
        
        
        firebaseStorageSongsRef?.child(group?.groupName ?? "generic").child(name).delete { error in
            if let error = error {
                print("\(#fileID) \(#function): delete error")
            } else {
                print("\(#fileID) \(#function): delete successfull")
            }
        }
    }
    
    
}

